import Foundation

public struct VPPResultDetails: Codable, Hashable {
    public let programName: String
    public let programType: String
    public let notes: String
    public let capacityScale: Double
}

public struct VPPResult: Codable, Hashable {
    public let annualEarnings: EarningsBounds
    public let upfrontIncentive: Int
    public let program: VPPProgram?
    public let totalOverPeriod: Int
    public let details: VPPResultDetails
}

public final class VPPCalculator {
    public static func estimateVppEarnings(
        utilityId: String,
        batteryCapacityKwh: Double,
        batteryPowerKw: Double
    ) -> (earnings: EarningsBounds, program: VPPProgram?, upfront: Double) {
        let programs = DataManager.shared.getVppPrograms(forUtilityId: utilityId)
        
        let specific = programs.first { $0.id != "generic-vpp" }
        let program = specific ?? programs.first { $0.id == "generic-vpp" }
        
        guard let prog = program else {
            return (EarningsBounds(min: 0, max: 0, mid: 0), nil, 0.0)
        }
        
        var minE = prog.estimatedAnnualEarnings.min
        var maxE = prog.estimatedAnnualEarnings.max
        var midE = prog.estimatedAnnualEarnings.mid
        
        if prog.type == "capacity-based", let payPerKw = prog.payPerKwSummer {
            let base = payPerKw * batteryPowerKw
            minE = round(base * 0.7)
            maxE = round(base * 1.1)
            midE = round(base * 0.9)
        } else if prog.type == "event-based", let payPerKwh = prog.payPerKwh {
            let events = Double(prog.estimatedEventsPerYear ?? 15)
            let avgDischarge = batteryCapacityKwh * 0.5
            let base = payPerKwh * avgDischarge * events
            minE = round(base * 0.5)
            maxE = round(base * 1.2)
            midE = round(base * 0.8)
        }
        
        let upfront = prog.upfrontPerUnit ?? 0.0
        return (EarningsBounds(min: minE, max: maxE, mid: midE), prog, upfront)
    }
    
    public static func calculate(
        utilityId: String,
        battery: Battery,
        participateInVpp: Bool = true,
        analysisYears: Int = 10
    ) -> VPPResult {
        if !participateInVpp {
            return VPPResult(
                annualEarnings: EarningsBounds(min: 0, max: 0, mid: 0),
                upfrontIncentive: 0,
                program: nil,
                totalOverPeriod: 0,
                details: VPPResultDetails(
                    programName: "Disabled",
                    programType: "none",
                    notes: "VPP participation disabled by user",
                    capacityScale: 0.0
                )
            )
        }
        
        let est = estimateVppEarnings(
            utilityId: utilityId,
            batteryCapacityKwh: battery.usableCapacityKwh,
            batteryPowerKw: battery.continuousPowerKw
        )
        
        let capacityScale: Double
        if est.program?.id == "generic-vpp" {
            capacityScale = battery.usableCapacityKwh >= 10.0 ? 1.0 :
                (battery.usableCapacityKwh >= 5.0 ? 0.8 : 0.5)
        } else {
            capacityScale = 1.0
        }
        
        let scaledEarnings = EarningsBounds(
            min: round(est.earnings.min * capacityScale),
            max: round(est.earnings.max * capacityScale),
            mid: round(est.earnings.mid * capacityScale)
        )
        
        let upfront = Int(est.upfront)
        let totalOverPeriod = Int(scaledEarnings.mid * Double(analysisYears)) + upfront
        
        return VPPResult(
            annualEarnings: scaledEarnings,
            upfrontIncentive: upfront,
            program: est.program,
            totalOverPeriod: totalOverPeriod,
            details: VPPResultDetails(
                programName: est.program?.name ?? "No specific program",
                programType: est.program?.type ?? "estimated",
                notes: est.program?.notes ?? "",
                capacityScale: capacityScale
            )
        )
    }
}
