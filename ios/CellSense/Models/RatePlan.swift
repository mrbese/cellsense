import Foundation

public struct TimeWindow: Codable, Hashable {
    public let hours: [Int]
    public let rate: Double
}

public struct SeasonInfo: Codable, Hashable {
    public let peak: TimeWindow?
    public let partialPeak: TimeWindow?
    public let offPeak: TimeWindow
    public let superOffPeak: TimeWindow?
}

public struct Seasons: Codable, Hashable {
    public let summer: SeasonInfo
    public let winter: SeasonInfo
}

public struct SeasonRates: Codable, Hashable {
    public let peak: Double
    public let offPeak: Double
}

public struct Nem3ExportRates: Codable, Hashable {
    public let summer: SeasonRates
    public let winter: SeasonRates
}

public struct RatePlan: Codable, Identifiable, Hashable {
    public let id: String
    public let utilityId: String
    public let name: String
    public let description: String
    public let seasons: Seasons
    public let baseServiceCharge: Double
    public let demandCharge: Double?
    public let nem3ExportRates: Nem3ExportRates?
    public let accPlusAdder: Double?
    public let weekdaysOnly: Bool?
}
