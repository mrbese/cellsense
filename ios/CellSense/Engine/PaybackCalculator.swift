import Foundation

public struct ProjectionPoint: Codable, Identifiable, Hashable {
    public var id: Int { year }
    public let year: Int
    public let savings: Int
    public let cumulative: Int
    public let positive: Bool
}

public struct BackupComponent: Codable, Hashable {
    public let annualValue: Int
}

public struct PaybackResultComponents: Codable, Hashable {
    public let arbitrage: ArbitrageResult
    public let vpp: VPPResult
    public let backup: BackupComponent
}

public struct PaybackResult: Codable, Identifiable, Hashable {
    public var id: String { battery.id }
    
    public let battery: Battery
    public let type: String
    public let systemCost: Int
    public let netSystemCost: Int
    public let taxCreditAmount: Int
    public let vppUpfrontIncentive: Int
    public let paybackYears: Double
    public let paybackMonths: Int
    public let totalSavings: Int
    public let netBenefit: Int
    public let roi: Double // ROI percentage or Double.infinity
    
    // Lease-specific fields
    public let monthlyLeaseCost: Int?
    public let energyRate: Double?
    public let monthlySavingsVsUtility: Int?
    public let annualSavings: Int?
    
    // Components and Projection
    public let components: PaybackResultComponents
    public var projection: [ProjectionPoint] = []
    public var computedBadge: String?
}

public struct CalculationOptions {
    public let hasSolar: Bool
    public let participateInVpp: Bool
    public let applyTaxCredit: Bool
    public let backupAnnualValue: Int
    public let analysisYears: Int
    public let monthlyBill: Double
    
    public init(
        hasSolar: Bool,
        participateInVpp: Bool,
        applyTaxCredit: Bool,
        backupAnnualValue: Int,
        analysisYears: Int = 10,
        monthlyBill: Double
    ) {
        self.hasSolar = hasSolar
        self.participateInVpp = participateInVpp
        self.applyTaxCredit = applyTaxCredit
        self.backupAnnualValue = backupAnnualValue
        self.analysisYears = analysisYears
        self.monthlyBill = monthlyBill
    }
}

public final class PaybackCalculator {
    public static func calculatePurchasePayback(
        battery: Battery,
        utilityId: String,
        ratePlan: RatePlan,
        options: CalculationOptions
    ) -> PaybackResult {
        let arbitrage = ArbitrageCalculator.calculate(
            ratePlan: ratePlan,
            battery: battery,
            hasSolar: options.hasSolar,
            analysisYears: options.analysisYears
        )
        
        let vpp = VPPCalculator.calculate(
            utilityId: utilityId,
            battery: battery,
            participateInVpp: options.participateInVpp,
            analysisYears: options.analysisYears
        )
        
        let annualSavings = Double(arbitrage.totalAnnual) + Double(vpp.annualEarnings.mid) + Double(options.backupAnnualValue)
        
        var systemCost = Double(battery.avgInstalledCost)
        var taxCreditAmount = 0.0
        
        if options.applyTaxCredit && options.hasSolar && battery.federalTaxCreditEligible {
            taxCreditAmount = systemCost * battery.federalTaxCreditRate
            systemCost -= taxCreditAmount
        }
        
        let vppUpfront = Double(vpp.upfrontIncentive)
        systemCost -= vppUpfront
        systemCost = max(0.0, systemCost)
        
        let paybackYears = annualSavings > 0.0 ? systemCost / annualSavings : Double.infinity
        
        let totalSavings10yr = annualSavings * Double(options.analysisYears)
        let netBenefit = totalSavings10yr - systemCost
        
        let roi: Double
        if systemCost > 0.0 {
            roi = (netBenefit / systemCost) * 100.0
        } else {
            roi = netBenefit > 0.0 ? Double.infinity : 0.0
        }
        
        var result = PaybackResult(
            battery: battery,
            type: "purchase",
            systemCost: battery.avgInstalledCost,
            netSystemCost: Int(round(systemCost)),
            taxCreditAmount: Int(round(taxCreditAmount)),
            vppUpfrontIncentive: Int(vppUpfront),
            paybackYears: round(paybackYears * 10.0) / 10.0,
            paybackMonths: Int(round(paybackYears * 12.0)),
            totalSavings: Int(round(totalSavings10yr)),
            netBenefit: Int(round(netBenefit)),
            roi: roi,
            monthlyLeaseCost: nil,
            energyRate: nil,
            monthlySavingsVsUtility: nil,
            annualSavings: nil,
            components: PaybackResultComponents(
                arbitrage: arbitrage,
                vpp: vpp,
                backup: BackupComponent(annualValue: options.backupAnnualValue)
            )
        )
        
        result.projection = buildYearlyProjection(
            result: result,
            arbitrage: arbitrage,
            vpp: vpp,
            backupValue: Double(options.backupAnnualValue),
            years: options.analysisYears
        )
        
        return result
    }
    
    public static func calculateLeasePayback(
        battery: Battery,
        utility: Utility,
        monthlyBill: Double,
        options: CalculationOptions
    ) -> PaybackResult {
        let months = Double(options.analysisYears * 12)
        let currentTotalCost = monthlyBill * months
        
        let installFee = Double(battery.installationFee ?? 695)
        let monthlyMembership = Double(battery.monthlyFee) * months
        
        let blendedRate = utility.avgBlendedRate > 0.0 ? utility.avgBlendedRate : 0.15
        let energyCost = (battery.allInRate ?? 0.145) * (monthlyBill / blendedRate) * months
        
        let basePowerTotalCost = installFee + monthlyMembership + energyCost
        
        let vpp = VPPCalculator.calculate(
            utilityId: utility.id,
            battery: battery,
            participateInVpp: options.participateInVpp,
            analysisYears: options.analysisYears
        )
        
        let vppTotal = Double(vpp.annualEarnings.mid * Double(options.analysisYears))
        let backupTotal = Double(options.backupAnnualValue * options.analysisYears)
        
        let totalSavings = currentTotalCost - basePowerTotalCost + vppTotal + backupTotal
        let monthlySavings = totalSavings / months
        
        let paybackMonths = monthlySavings > 0.0 ? ceil(installFee / monthlySavings) : Double.infinity
        let paybackYears = paybackMonths / 12.0
        
        let roi: Double
        if installFee > 0.0 {
            roi = (totalSavings / installFee) * 100.0
        } else {
            roi = totalSavings > 0.0 ? Double.infinity : 0.0
        }
        
        // Setup arbitrage dummy result for consistency in UI display
        let dummyArb = ArbitrageResult(
            annualSavings: Int(round(currentTotalCost / Double(options.analysisYears) - (monthlyMembership + energyCost) / Double(options.analysisYears))),
            nem3Bonus: 0,
            totalAnnual: Int(round(currentTotalCost / Double(options.analysisYears) - (monthlyMembership + energyCost) / Double(options.analysisYears))),
            yearlyBreakdown: [],
            details: ArbitrageDetails(
                summerDailyArbitrage: 0,
                winterDailyArbitrage: 0,
                summerPeakRate: 0,
                summerOffPeakRate: 0,
                winterPeakRate: 0,
                winterOffPeakRate: 0,
                summerDifferential: 0,
                winterDifferential: 0,
                capacity: battery.usableCapacityKwh,
                efficiency: battery.roundTripEfficiency
            )
        )
        
        var result = PaybackResult(
            battery: battery,
            type: "lease",
            systemCost: Int(installFee),
            netSystemCost: Int(installFee),
            taxCreditAmount: 0,
            vppUpfrontIncentive: 0,
            paybackYears: round(paybackYears * 10.0) / 10.0,
            paybackMonths: Int(paybackMonths),
            totalSavings: Int(round(totalSavings)),
            netBenefit: Int(round(totalSavings)),
            roi: roi,
            monthlyLeaseCost: battery.monthlyFee,
            energyRate: battery.allInRate,
            monthlySavingsVsUtility: Int(round(monthlySavings)),
            annualSavings: Int(round(totalSavings / Double(options.analysisYears))),
            components: PaybackResultComponents(
                arbitrage: dummyArb,
                vpp: vpp,
                backup: BackupComponent(annualValue: options.backupAnnualValue)
            )
        )
        
        result.projection = buildYearlyProjection(
            result: result,
            arbitrage: dummyArb,
            vpp: vpp,
            backupValue: Double(options.backupAnnualValue),
            years: options.analysisYears
        )
        
        return result
    }
    
    public static func buildYearlyProjection(
        result: PaybackResult,
        arbitrage: ArbitrageResult,
        vpp: VPPResult,
        backupValue: Double,
        years: Int
    ) -> [ProjectionPoint] {
        var projection: [ProjectionPoint] = []
        var cumulative = -Double(result.netSystemCost)
        
        for y in 1...years {
            let yearNet: Double
            if result.type == "lease" {
                yearNet = Double(result.netBenefit + result.systemCost) / Double(years)
            } else {
                let arbYear: Double
                if y - 1 < arbitrage.yearlyBreakdown.count {
                    arbYear = Double(arbitrage.yearlyBreakdown[y - 1].savings)
                } else {
                    arbYear = Double(arbitrage.totalAnnual)
                }
                yearNet = arbYear + Double(vpp.annualEarnings.mid) + backupValue
            }
            
            cumulative += yearNet
            projection.append(ProjectionPoint(
                year: y,
                savings: Int(round(yearNet)),
                cumulative: Int(round(cumulative)),
                positive: cumulative >= 0.0
            ))
        }
        return projection
    }
    
    public static func calculateAll(
        batteries: [Battery],
        utility: Utility,
        ratePlan: RatePlan,
        options: CalculationOptions
    ) -> [PaybackResult] {
        var results = batteries.map { battery -> PaybackResult in
            if battery.pricingModel == "lease" {
                return calculateLeasePayback(
                    battery: battery,
                    utility: utility,
                    monthlyBill: options.monthlyBill,
                    options: options
                )
            } else {
                return calculatePurchasePayback(
                    battery: battery,
                    utilityId: utility.id,
                    ratePlan: ratePlan,
                    options: options
                )
            }
        }
        
        // Badges: Fastest Payback (among purchase models)
        let purchaseResults = results.filter { $0.type == "purchase" }
        if let fastest = purchaseResults.min(by: { $0.paybackYears < $1.paybackYears }) {
            if let idx = results.firstIndex(where: { $0.battery.id == fastest.battery.id }) {
                results[idx].computedBadge = "Fastest Payback"
            }
        }
        
        // Best Value (among all)
        if let bestValue = results.max(by: { $0.netBenefit < $1.netBenefit }) {
            if let idx = results.firstIndex(where: { $0.battery.id == bestValue.battery.id }) {
                if let oldBadge = results[idx].computedBadge {
                    results[idx].computedBadge = oldBadge + " • Best Value"
                } else {
                    results[idx].computedBadge = "Best 10-Year Value"
                }
            }
        }
        
        // Sort by payback years (shortest first), with lease models at the end
        results.sort { (a, b) -> Bool in
            if a.type != b.type {
                return a.type == "purchase"
            }
            if a.paybackYears == b.paybackYears {
                return false
            }
            if !a.paybackYears.isFinite && b.paybackYears.isFinite {
                return false
            }
            if a.paybackYears.isFinite && !b.paybackYears.isFinite {
                return true
            }
            return a.paybackYears < b.paybackYears
        }
        
        return results
    }
}
