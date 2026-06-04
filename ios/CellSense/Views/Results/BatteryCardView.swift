import SwiftUI

struct BatteryCardView: View {
    let result: PaybackResult
    let onShowMath: () -> Void
    
    // Parse hex colors from JS definitions
    private var accentColor: Color {
        Color(hex: result.battery.color)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Optional Badge
            if let badge = result.computedBadge ?? result.battery.badge {
                Text(badge.uppercased())
                    .font(.caption2.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(accentColor)
                    .cornerRadius(4)
            }
            
            // Header: Icon + Name
            HStack(spacing: 12) {
                Text(result.battery.icon)
                    .font(.title)
                    .padding(8)
                    .background(accentColor.opacity(0.15))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.battery.shortName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(result.type == "lease" ? "Lease Model" : "$\(result.systemCost.formatted()) installed")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            
            // Payback Display
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(paybackDisplayValue)
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(paybackDisplayUnit)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Text("Payback Period")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Savings Rows
            VStack(spacing: 8) {
                savingsRow(label: "TOU Arbitrage", value: result.components.arbitrage.annualSavings, color: Color(red: 0.0, green: 0.83, blue: 0.67))
                savingsRow(label: "VPP Earnings", value: Int(result.components.vpp.annualEarnings.mid), color: Color(red: 0.96, green: 0.62, blue: 0.04))
                savingsRow(label: "Backup Value", value: result.components.backup.annualValue, color: Color(red: 0.55, green: 0.36, blue: 0.96))
                
                if result.components.arbitrage.nem3Bonus > 0 {
                    savingsRow(label: "NEM 3.0 Bonus", value: result.components.arbitrage.nem3Bonus, color: Color(red: 0.23, green: 0.51, blue: 0.96))
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // 10-Yr Net Benefit
            HStack {
                Text("10-Yr Net Benefit")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                Spacer()
                Text("\(result.netBenefit >= 0 ? "+" : "")$\(result.netBenefit.formatted())")
                    .font(.headline.bold())
                    .foregroundColor(result.netBenefit >= 0 ? Color(red: 0.0, green: 0.83, blue: 0.67) : Color.red)
            }
            
            // Details Toggle Button
            Button(action: onShowMath) {
                HStack {
                    Text("▼ Show Math")
                        .font(.footnote.bold())
                    Spacer()
                }
                .foregroundColor(.gray)
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color(white: 0.09).opacity(0.85))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(accentColor.opacity(0.3), lineWidth: 1.5)
        )
    }
    
    private var paybackDisplayValue: String {
        let isLease = result.type == "lease"
        if result.paybackYears > 20 {
            return "20+"
        } else if isLease && result.paybackYears < 1 {
            return "\(max(1, Int(round(result.paybackYears * 12.0))))"
        } else {
            return String(format: "%.1f", result.paybackYears)
        }
    }
    
    private var paybackDisplayUnit: String {
        let isLease = result.type == "lease"
        if result.paybackYears > 20 {
            return "years to payback"
        } else if isLease && result.paybackYears < 1 {
            let months = max(1, Int(round(result.paybackYears * 12.0)))
            return months == 1 ? "month to recoup install" : "months to recoup install"
        } else {
            return "years to payback"
        }
    }
    
    private func savingsRow(label: String, value: Int, color: Color) -> some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
            Text("+$\(value)/yr")
                .font(.caption.bold())
                .foregroundColor(.white)
        }
    }
}

// Helper Color hex parser
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 1)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
