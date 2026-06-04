import Foundation
import Vision
import UIKit

public final class BillParser {
    public static let shared = BillParser()
    
    private init() {}
    
    public struct ParseResult {
        public let amount: Double?
        public let utilityId: String?
        public let ratePlanId: String?
    }
    
    public func parseImage(_ image: UIImage, completion: @escaping (ParseResult) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(ParseResult(amount: nil, utilityId: nil, ratePlanId: nil))
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                print("Vision error: \(error!)")
                completion(ParseResult(amount: nil, utilityId: nil, ratePlanId: nil))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(ParseResult(amount: nil, utilityId: nil, ratePlanId: nil))
                return
            }
            
            // Gather all recognized strings
            var recognizedStrings: [String] = []
            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    recognizedStrings.append(topCandidate.string)
                }
            }
            
            let result = self.analyzeText(recognizedStrings)
            completion(result)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("Failed to perform Vision request: \(error)")
                completion(ParseResult(amount: nil, utilityId: nil, ratePlanId: nil))
            }
        }
    }
    
    public func analyzeText(_ strings: [String]) -> ParseResult {
        let fullText = strings.joined(separator: "\n")
        print("--- EXTRACTED OCR TEXT ---")
        print(fullText)
        print("---------------------------")
        
        // 1. Identify Utility
        var matchedUtilityId: String? = nil
        let utilities = DataManager.shared.utilities
        
        // Check for specific utility names or abbreviations
        for utility in utilities {
            // Check direct name / shortname
            if fullText.localizedCaseInsensitiveContains(utility.shortName) || 
               fullText.localizedCaseInsensitiveContains(utility.name) {
                matchedUtilityId = utility.id
                break
            }
            
            // Special mappings
            if utility.id == "pge" && (fullText.localizedCaseInsensitiveContains("pacific gas") || fullText.localizedCaseInsensitiveContains("pg&e")) {
                matchedUtilityId = "pge"
                break
            }
            if utility.id == "sce" && (fullText.localizedCaseInsensitiveContains("southern california edison") || fullText.localizedCaseInsensitiveContains("sce")) {
                matchedUtilityId = "sce"
                break
            }
            if utility.id == "sdge" && (fullText.localizedCaseInsensitiveContains("san diego gas") || fullText.localizedCaseInsensitiveContains("sdg&e")) {
                matchedUtilityId = "sdge"
                break
            }
        }
        
        // 2. Identify Rate Plan
        var matchedRatePlanId: String? = nil
        let targetUtilityId = matchedUtilityId ?? "pge" // Fallback to pge to search rates if utility not recognized
        let ratePlans = DataManager.shared.getRatePlans(forUtilityId: targetUtilityId)
        
        for plan in ratePlans {
            // Match plan ID or name
            let planSearchKeys = [
                plan.id,
                plan.name,
                plan.id.replacingOccurrences(of: "-", with: " "),
                // shorthand matches e.g. "E-TOU-C"
                plan.id.split(separator: "-").suffix(2).joined(separator: "-").uppercased(),
                plan.id.split(separator: "-").last?.uppercased() ?? ""
            ]
            
            for key in planSearchKeys {
                if !key.isEmpty && key.count > 2 && fullText.localizedCaseInsensitiveContains(key) {
                    matchedRatePlanId = plan.id
                    break
                }
            }
            if matchedRatePlanId != nil { break }
        }
        
        // 3. Extract Amount Due
        var matchedAmount: Double? = nil
        
        // Regular expressions to search for prices near keywords or general bills
        // Keywords that typically precede a bill amount
        let billKeywords = [
            "total due", "amount due", "current charges", "new charges", 
            "total amount due", "balance due", "please pay", "total electric charges"
        ]
        
        // Let's scan line-by-line first to find keywords
        for (index, line) in strings.enumerated() {
            let lowerLine = line.lowercased()
            let containsKeyword = billKeywords.contains { lowerLine.contains($0) }
            
            if containsKeyword {
                // Check the current line for a price, or subsequent lines (up to 2 lines down)
                let searchRange = index...(min(index + 2, strings.count - 1))
                for searchIndex in searchRange {
                    let searchLine = strings[searchIndex]
                    if let val = self.extractPrice(from: searchLine) {
                        matchedAmount = val
                        break
                    }
                }
            }
            if matchedAmount != nil { break }
        }
        
        // If not found near keywords, fallback to finding the largest price in the entire text (since bills are usually the largest charge on the statement)
        if matchedAmount == nil {
            var prices: [Double] = []
            for line in strings {
                if let val = self.extractPrice(from: line) {
                    // Ignore very large numbers that might be account numbers (e.g. > 2000) or very small ones (< 10)
                    if val > 10.0 && val < 2500.0 {
                        prices.append(val)
                    }
                }
            }
            // Often the largest charge is the total bill
            matchedAmount = prices.max()
        }
        
        return ParseResult(amount: matchedAmount, utilityId: matchedUtilityId, ratePlanId: matchedRatePlanId)
    }
    
    private func extractPrice(from text: String) -> Double? {
        // Regex to match $XX.XX or XX.XX
        // Matches $123.45, 123.45, $1,234.45 etc
        let pattern = #"(?:\$)?\s*([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{2}))"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        
        let range = NSRange(text.startIndex..., in: text)
        if let match = regex.firstMatch(in: text, options: [], range: range) {
            if let dollarRange = Range(match.range(at: 1), in: text) {
                let cleanedStr = text[dollarRange].replacingOccurrences(of: ",", with: "")
                return Double(cleanedStr)
            }
        }
        
        // Try simple number match if no decimal but preceded by $
        let simplePattern = #"\$\s*([0-9]+)"#
        if let simpleRegex = try? NSRegularExpression(pattern: simplePattern, options: []) {
            if let match = simpleRegex.firstMatch(in: text, options: [], range: range) {
                if let dollarRange = Range(match.range(at: 1), in: text) {
                    return Double(text[dollarRange])
                }
            }
        }
        
        return nil
    }
}
