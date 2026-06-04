import Foundation

public struct Utility: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let shortName: String
    public let state: String
    public let type: String
    public let ratePlanIds: [String]
    public let vppProgramIds: [String]
    public let avgOutageHoursPerYear: Double
    public let avgBlendedRate: Double
    public let hasNem3: Bool
}
