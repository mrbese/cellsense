import Foundation

public struct EarningsBounds: Codable, Hashable {
    public let min: Double
    public let max: Double
    public let mid: Double
}

public struct VPPProgram: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let utilityIds: [String]
    public let type: String
    public let payPerKwh: Double?
    public let estimatedEventsPerYear: Int?
    public let estimatedAnnualPerUnit: Double?
    public let estimatedAnnualEarnings: EarningsBounds
    public let notes: String
    public let upfrontPerUnit: Double?
    public let maxUpfrontPerHousehold: Double?
    public let annualPerUnit: Double?
    public let payPerKwSummer: Double?
    public let maxDispatchesPerSummer: Int?
    public let monthlyPerUnit: Double?
    public let sellbackRatePerKwh: Double?
    public let rebatePerKw: Double?
    public let maxRebate: Double?
    public let annualCredits: Double?
}
