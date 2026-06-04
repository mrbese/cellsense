import Foundation

public final class DataManager {
    public static let shared = DataManager()
    
    public var batteries: [Battery] = []
    public var utilities: [Utility] = []
    public var ratePlans: [RatePlan] = []
    public var vppPrograms: [VPPProgram] = []
    
    private init() {
        loadData()
    }
    
    private func loadData() {
        self.batteries = loadJSON(filename: "batteries") ?? []
        self.utilities = loadJSON(filename: "utilities") ?? []
        self.ratePlans = loadJSON(filename: "ratePlans") ?? []
        self.vppPrograms = loadJSON(filename: "vppPrograms") ?? []
    }
    
    private func loadJSON<T: Decodable>(filename: String) -> T? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("⚠️ Could not find \(filename).json in bundle")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("❌ Failed to decode \(filename).json: \(error)")
            return nil
        }
    }
    
    public func getRatePlans(forUtilityId utilityId: String) -> [RatePlan] {
        return ratePlans.filter { $0.utilityId == utilityId }
    }
    
    public func getVppPrograms(forUtilityId utilityId: String) -> [VPPProgram] {
        return vppPrograms.filter { $0.utilityIds.contains(utilityId) || $0.utilityIds.contains("*") }
    }
    
    public func getBattery(byId id: String) -> Battery? {
        return batteries.first { $0.id == id }
    }
}
