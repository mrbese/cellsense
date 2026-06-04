import Foundation
import Observation

@Observable
public final class CalculationModel {
    // Form Inputs
    public var selectedUtility: Utility? = nil {
        didSet {
            if let utility = selectedUtility {
                let plans = DataManager.shared.getRatePlans(forUtilityId: utility.id)
                selectedRatePlan = plans.first
                recalculateKwh()
            }
        }
    }
    public var selectedRatePlan: RatePlan? = nil
    public var monthlyBill: Double = 200.0 {
        didSet {
            recalculateKwh()
        }
    }
    public var hasSolar: Bool = false
    
    // Home details
    public var homeSize: Double = 2000.0
    public var occupants: Int = 3
    public var hasEV: Bool = false {
        didSet {
            recalculateKwh()
        }
    }
    public var hasPool: Bool = false {
        didSet {
            recalculateKwh()
        }
    }
    public var hvacType: String = "gas" // gas, heatpump, electric
    public var dailyKwh: Double = 22.0
    
    // Priorities
    public var backupValue: Double = 200.0
    public var includeVpp: Bool = true
    public var applyITC: Bool = true
    
    // Results
    public var results: [PaybackResult] = []
    
    public init() {
        // Default select PG&E
        if let firstUtility = DataManager.shared.utilities.first {
            self.selectedUtility = firstUtility
            let plans = DataManager.shared.getRatePlans(forUtilityId: firstUtility.id)
            self.selectedRatePlan = plans.first
        }
        recalculateKwh()
    }
    
    public func recalculateKwh() {
        guard let utility = selectedUtility else { return }
        let rate = utility.avgBlendedRate > 0.0 ? utility.avgBlendedRate : 0.15
        var monthlyKwh = monthlyBill / rate
        if hasEV { monthlyKwh += 400.0 }
        if hasPool { monthlyKwh += 200.0 }
        dailyKwh = round(monthlyKwh / 30.0)
    }
    
    public func runCalculation() {
        guard let utility = selectedUtility, let ratePlan = selectedRatePlan else { return }
        let options = CalculationOptions(
            hasSolar: hasSolar,
            participateInVpp: includeVpp,
            applyTaxCredit: applyITC,
            backupAnnualValue: Int(backupValue),
            monthlyBill: monthlyBill
        )
        results = PaybackCalculator.calculateAll(
            batteries: DataManager.shared.batteries,
            utility: utility,
            ratePlan: ratePlan,
            options: options
        )
    }
}
