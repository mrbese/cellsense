import SwiftUI

struct UtilityStepView: View {
    @Bindable var model: CalculationModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header description
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Utility")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text("Select your electric utility and current rate plan")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 10)
            
            // Utility Selection Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Utility Company")
                    .font(.footnote.bold())
                    .foregroundColor(.gray)
                
                Picker("Utility", selection: $model.selectedUtility) {
                    Text("Select utility...").tag(nil as Utility?)
                    ForEach(DataManager.shared.utilities) { utility in
                        Text(utility.name).tag(utility as Utility?)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(white: 0.15))
                .cornerRadius(8)
                .accentColor(.white)
            }
            
            // Rate Plan Selection Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Rate Plan")
                    .font(.footnote.bold())
                    .foregroundColor(.gray)
                
                Picker("Rate Plan", selection: $model.selectedRatePlan) {
                    if let utility = model.selectedUtility {
                        let plans = DataManager.shared.getRatePlans(forUtilityId: utility.id)
                        ForEach(plans) { plan in
                            Text(plan.name).tag(plan as RatePlan?)
                        }
                    } else {
                        Text("Select a utility first...").tag(nil as RatePlan?)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(white: 0.15))
                .cornerRadius(8)
                .accentColor(.white)
                .disabled(model.selectedUtility == nil)
            }
            
            // Average Monthly Bill
            VStack(alignment: .leading, spacing: 8) {
                Text("Avg Monthly Bill")
                    .font(.footnote.bold())
                    .foregroundColor(.gray)
                
                HStack(spacing: 8) {
                    Text("$")
                        .foregroundColor(.white)
                        .font(.body.bold())
                    
                    TextField("200", value: $model.monthlyBill, format: .number)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color(white: 0.15))
                .cornerRadius(8)
                
                Text("Before taxes and fees")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            // Solar Panels Toggle
            VStack(alignment: .leading, spacing: 8) {
                Text("Solar Panels?")
                    .font(.footnote.bold())
                    .foregroundColor(.gray)
                
                Toggle(isOn: $model.hasSolar) {
                    Text("I have rooftop solar")
                        .foregroundColor(.white)
                }
                .tint(Color(red: 0.0, green: 0.83, blue: 0.67))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(white: 0.15))
                .cornerRadius(8)
            }
            
            // Conditional NEM 3.0 Callout
            if model.hasSolar, let utility = model.selectedUtility, utility.hasNem3 {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text("☀️")
                        Text("NEM 3.0 Detected")
                            .font(.subheadline.bold())
                            .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0)) // Golden solar yellow
                    }
                    
                    Text("Your utility uses NEM 3.0 (Net Billing Tariff). Solar export rates average ~$0.05-0.08/kWh midday — much lower than retail. A battery lets you store solar and sell at peak rates instead, dramatically improving your ROI.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineSpacing(4)
                }
                .padding(14)
                .background(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.08))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.2), lineWidth: 1)
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
}
