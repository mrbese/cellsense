import SwiftUI

struct MathBreakdownView: View {
    let result: PaybackResult
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.02, green: 0.04, blue: 0.06)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Header
                        HStack {
                            Text(result.battery.icon)
                                .font(.title)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(result.battery.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Payback Mathematical Breakdown")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        
                        // Section 1: Rate Differential (for purchase) or Lease structure
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Rate Differential")
                                .font(.subheadline.bold())
                                .foregroundColor(Color(red: 0.0, green: 0.83, blue: 0.67))
                                .padding(.horizontal, 4)
                            
                            let details = result.components.arbitrage.details
                            VStack(spacing: 8) {
                                mathRow(label: "Summer peak rate", value: "$\(String(format: "%.3f", details.summerPeakRate))/kWh")
                                mathRow(label: "Summer off-peak rate", value: "$\(String(format: "%.3f", details.summerOffPeakRate))/kWh")
                                mathRow(label: "Summer differential", value: "$\(String(format: "%.3f", details.summerDifferential))/kWh", highlight: true)
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                mathRow(label: "Winter peak rate", value: "$\(String(format: "%.3f", details.winterPeakRate))/kWh")
                                mathRow(label: "Winter off-peak rate", value: "$\(String(format: "%.3f", details.winterOffPeakRate))/kWh")
                                mathRow(label: "Winter differential", value: "$\(String(format: "%.3f", details.winterDifferential))/kWh", highlight: true)
                            }
                            .padding(14)
                            .background(Color(white: 0.08))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 16)
                        
                        // Section 2: Upfront Net Cost
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Upfront Calculations")
                                .font(.subheadline.bold())
                                .foregroundColor(Color(red: 0.0, green: 0.83, blue: 0.67))
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 8) {
                                if result.type == "lease" {
                                    mathRow(label: "Installation fee", value: "$\(result.systemCost.formatted())")
                                    mathRow(label: "Net System Cost", value: "$\(result.netSystemCost.formatted())", highlight: true)
                                } else {
                                    mathRow(label: "Average installed cost", value: "$\(result.systemCost.formatted())")
                                    if result.taxCreditAmount > 0 {
                                        mathRow(label: "Federal Tax Credit (30%)", value: "-$\(result.taxCreditAmount.formatted())")
                                    }
                                    if result.vppUpfrontIncentive > 0 {
                                        mathRow(label: "VPP Upfront Incentive", value: "-$\(result.vppUpfrontIncentive.formatted())")
                                    }
                                    mathRow(label: "Net System Cost", value: "$\(result.netSystemCost.formatted())", highlight: true)
                                }
                            }
                            .padding(14)
                            .background(Color(white: 0.08))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 16)
                        
                        // Section 3: Annual Savings
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Annual Savings Breakdown")
                                .font(.subheadline.bold())
                                .foregroundColor(Color(red: 0.0, green: 0.83, blue: 0.67))
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 8) {
                                mathRow(label: "TOU Arbitrage", value: "+$\(result.components.arbitrage.annualSavings.formatted())/yr")
                                mathRow(label: "VPP Program Earnings", value: "+$\(result.components.vpp.annualEarnings.mid.formatted())/yr")
                                mathRow(label: "Backup Outage Value", value: "+$\(result.components.backup.annualValue.formatted())/yr")
                                
                                if result.components.arbitrage.nem3Bonus > 0 {
                                    mathRow(label: "NEM 3.0 export bonus", value: "+$\(result.components.arbitrage.nem3Bonus.formatted())/yr")
                                }
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                let totalAnn = result.components.arbitrage.totalAnnual + Int(result.components.vpp.annualEarnings.mid) + result.components.backup.annualValue
                                mathRow(label: "Total Annual Value", value: "+$\(totalAnn.formatted())/yr", highlight: true)
                            }
                            .padding(14)
                            .background(Color(white: 0.08))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 16)
                        
                        // Section 4: Payback Formula
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Payback Period Formula")
                                .font(.subheadline.bold())
                                .foregroundColor(Color(red: 0.0, green: 0.83, blue: 0.67))
                                .padding(.horizontal, 4)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                if result.type == "lease" {
                                    Text("Payback Months = Installation Fee ÷ Monthly Savings")
                                        .font(.caption2.monospaced())
                                        .foregroundColor(.gray)
                                    
                                    HStack {
                                        Text("$\(result.systemCost) ÷ $\(result.monthlyLeaseCost ?? 0 + (result.monthlySavingsVsUtility ?? 0))")
                                            .font(.body.bold())
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(result.paybackMonths) months")
                                            .font(.body.bold())
                                            .foregroundColor(Color(red: 0.0, green: 0.83, blue: 0.67))
                                    }
                                } else {
                                    Text("Payback Years = Net System Cost ÷ Total Annual Savings")
                                        .font(.caption2.monospaced())
                                        .foregroundColor(.gray)
                                    
                                    HStack {
                                        let totalAnn = result.components.arbitrage.totalAnnual + Int(result.components.vpp.annualEarnings.mid) + result.components.backup.annualValue
                                        Text("$\(result.netSystemCost.formatted()) ÷ $\(totalAnn.formatted())")
                                            .font(.body.bold())
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text(result.paybackYears.isFinite ? "\(String(format: "%.1f", result.paybackYears)) years" : "Infinite")
                                            .font(.body.bold())
                                            .foregroundColor(Color(red: 0.0, green: 0.83, blue: 0.67))
                                    }
                                }
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                mathRow(label: "10-Year Return on Investment", value: result.roi.isFinite ? "\(Int(round(result.roi)))%" : "Infinite")
                            }
                            .padding(14)
                            .background(Color(white: 0.08))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Math Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.0, green: 0.83, blue: 0.67))
                }
            }
        }
    }
    
    private func mathRow(label: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(highlight ? .white : .gray)
            Spacer()
            Text(value)
                .font(.caption.bold())
                .foregroundColor(highlight ? Color(red: 0.0, green: 0.83, blue: 0.67) : .white)
        }
    }
}
