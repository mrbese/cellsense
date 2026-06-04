import Foundation

public struct YearlyBreakdown: Codable, Hashable {
    public let year: Int
    public let savings: Int
    public let cumulative: Int
}

public struct ArbitrageDetails: Codable, Hashable {
    public let summerDailyArbitrage: Double
    public let winterDailyArbitrage: Double
    public let summerPeakRate: Double
    public let summerOffPeakRate: Double
    public let winterPeakRate: Double
    public let winterOffPeakRate: Double
    public let summerDifferential: Double
    public let winterDifferential: Double
    public let capacity: Double
    public let efficiency: Double
}

public struct ArbitrageResult: Codable, Hashable {
    public let annualSavings: Int
    public let nem3Bonus: Int
    public let totalAnnual: Int
    public let yearlyBreakdown: [YearlyBreakdown]
    public let details: ArbitrageDetails
}

public final class ArbitrageCalculator {
    public static func getLowestChargeRate(ratePlan: RatePlan, season: String) -> Double {
        let info = season == "summer" ? ratePlan.seasons.summer : ratePlan.seasons.winter
        let offPeak = info.offPeak.rate
        if let superOffPeak = info.superOffPeak?.rate {
            return min(offPeak, superOffPeak)
        }
        return offPeak
    }
    
    public static func calculate(
        ratePlan: RatePlan,
        battery: Battery,
        hasSolar: Bool = false,
        cyclesPerDay: Double = 1.0,
        degradationPerYear: Double = 0.02,
        analysisYears: Int = 10
    ) -> ArbitrageResult {
        let efficiency = battery.roundTripEfficiency
        let capacity = battery.usableCapacityKwh
        
        let summerDays = 122.0
        let winterDays = 243.0
        
        let summerPeak = ratePlan.seasons.summer.peak?.rate ?? ratePlan.seasons.summer.offPeak.rate
        let summerOffPeak = getLowestChargeRate(ratePlan: ratePlan, season: "summer")
        let winterPeak = ratePlan.seasons.winter.peak?.rate ?? ratePlan.seasons.winter.offPeak.rate
        let winterOffPeak = getLowestChargeRate(ratePlan: ratePlan, season: "winter")
        
        let summerDailyArbitrage = max(0.0, (summerPeak - summerOffPeak) * capacity * efficiency * cyclesPerDay)
        let winterDailyArbitrage = max(0.0, (winterPeak - winterOffPeak) * capacity * efficiency * cyclesPerDay)
        
        let weekdayFactor = ratePlan.weekdaysOnly == true ? (5.0 / 7.0) : 1.0
        
        let year1 = (summerDailyArbitrage * summerDays + winterDailyArbitrage * winterDays) * weekdayFactor
        
        var yearlyBreakdown: [YearlyBreakdown] = []
        var cumulative = 0.0
        for y in 0..<analysisYears {
            let degradationFactor = pow(1.0 - degradationPerYear, Double(y))
            let yearSavings = year1 * degradationFactor
            cumulative += yearSavings
            yearlyBreakdown.append(YearlyBreakdown(
                year: y + 1,
                savings: Int(round(yearSavings)),
                cumulative: Int(round(cumulative))
            ))
        }
        
        var nem3Bonus = 0.0
        if hasSolar, let exportRates = ratePlan.nem3ExportRates {
            let summerExportRate = exportRates.summer.offPeak
            let winterExportRate = exportRates.winter.offPeak
            
            let summerNem3Daily = max(0.0, (summerPeak - summerExportRate) * capacity * efficiency) - summerDailyArbitrage
            let winterNem3Daily = max(0.0, (winterPeak - winterExportRate) * capacity * efficiency) - winterDailyArbitrage
            
            nem3Bonus = max(0.0,
                (max(0.0, summerNem3Daily) * summerDays + max(0.0, winterNem3Daily) * winterDays) * weekdayFactor
            )
        }
        
        let details = ArbitrageDetails(
            summerDailyArbitrage: summerDailyArbitrage,
            winterDailyArbitrage: winterDailyArbitrage,
            summerPeakRate: summerPeak,
            summerOffPeakRate: summerOffPeak,
            winterPeakRate: winterPeak,
            winterOffPeakRate: winterOffPeak,
            summerDifferential: summerPeak - summerOffPeak,
            winterDifferential: winterPeak - winterOffPeak,
            capacity: capacity,
            efficiency: efficiency
        )
        
        return ArbitrageResult(
            annualSavings: Int(round(year1)),
            nem3Bonus: Int(round(nem3Bonus)),
            totalAnnual: Int(round(year1 + nem3Bonus)),
            yearlyBreakdown: yearlyBreakdown,
            details: details
        )
    }
}
