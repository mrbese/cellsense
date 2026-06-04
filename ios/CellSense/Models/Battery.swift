import Foundation

public struct Battery: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let shortName: String
    public let manufacturer: String
    public let capacityKwh: Double
    public let usableCapacityKwh: Double
    public let continuousPowerKw: Double
    public let peakPowerKw: Double
    public let roundTripEfficiency: Double
    public let warrantyYears: Int
    public let chemistry: String
    public let pricingModel: String
    public let equipmentCost: Int
    public let avgInstalledCost: Int
    public let installationIncluded: Bool
    public let monthlyFee: Int
    public let federalTaxCreditEligible: Bool
    public let federalTaxCreditRate: Double
    public let stackableUnits: Int
    public let expandable: Bool
    public let expansionUnitCost: Int?
    public let expansionUnitCapacityKwh: Double?
    public let requiresProfessionalInstall: Bool
    public let integratedInverter: Bool
    public let solarInputKw: Double
    public let color: String
    public let icon: String
    public let highlights: [String]
    public let badge: String?
    
    // Installation fees for lease systems (Base Power specific)
    public let installationFee: Int?
    public let installationFeeDouble: Int?
    public let monthlyFeeDouble: Int?
    public let energyRate: Double?
    public let avgDeliveryCharge: Double?
    public let allInRate: Double?
    public let contractMonths: Int?
    public let doubleCapacityKwh: Double?

    public struct NetCost {
        public let upfront: Int
        public let monthly: Int
        public let type: String
    }

    public func getNetCost(withTaxCredit: Bool = true, withSolar: Bool = true) -> NetCost {
        if pricingModel == "lease" {
            return NetCost(
                upfront: installationFee ?? 695,
                monthly: monthlyFee,
                type: "lease"
            )
        }
        
        var cost = Double(avgInstalledCost)
        if withTaxCredit && withSolar && federalTaxCreditEligible {
            cost = cost * (1.0 - federalTaxCreditRate)
        }
        return NetCost(
            upfront: Int(round(cost)),
            monthly: 0,
            type: "purchase"
        )
    }
}
