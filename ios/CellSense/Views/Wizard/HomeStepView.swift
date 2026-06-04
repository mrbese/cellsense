import SwiftUI

struct HomeStepView: View {
    @Bindable var model: CalculationModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header description
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Home")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text("Help us estimate your energy profile")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 10)
            
            // Home Size and Occupants Grid
            HStack(spacing: 16) {
                // Home Size
                VStack(alignment: .leading, spacing: 8) {
                    Text("Home Size")
                        .font(.footnote.bold())
                        .foregroundColor(.gray)
                    
                    HStack {
                        TextField("2000", value: $model.homeSize, format: .number)
                            .keyboardType(.numberPad)
                            .foregroundColor(.white)
                        Text("sq ft")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color(white: 0.15))
                    .cornerRadius(8)
                }
                
                // Occupants
                VStack(alignment: .leading, spacing: 8) {
                    Text("Occupants")
                        .font(.footnote.bold())
                        .foregroundColor(.gray)
                    
                    Picker("Occupants", selection: $model.occupants) {
                        ForEach(1...5, id: \.self) { num in
                            Text(num == 5 ? "5+ people" : "\(num) \(num == 1 ? "person" : "people")").tag(num)
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
            }
            
            // Additional Loads
            VStack(alignment: .leading, spacing: 8) {
                Text("Additional Loads")
                    .font(.footnote.bold())
                    .foregroundColor(.gray)
                
                VStack(spacing: 12) {
                    Toggle(isOn: $model.hasEV) {
                        Text("🚗 Electric Vehicle")
                            .foregroundColor(.white)
                    }
                    .tint(Color(red: 0.0, green: 0.83, blue: 0.67))
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    Toggle(isOn: $model.hasPool) {
                        Text("🏊 Pool / Spa")
                            .foregroundColor(.white)
                    }
                    .tint(Color(red: 0.0, green: 0.83, blue: 0.67))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(white: 0.15))
                .cornerRadius(8)
            }
            
            // HVAC Type
            VStack(alignment: .leading, spacing: 8) {
                Text("HVAC Type")
                    .font(.footnote.bold())
                    .foregroundColor(.gray)
                
                Picker("HVAC Type", selection: $model.hvacType) {
                    Text("Gas Furnace + AC").tag("gas")
                    Text("Electric Heat Pump").tag("heatpump")
                    Text("All Electric").tag("electric")
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 2)
            }
            
            // Est. Daily Usage
            VStack(alignment: .leading, spacing: 8) {
                Text("Est. Daily Usage")
                    .font(.footnote.bold())
                    .foregroundColor(.gray)
                
                HStack {
                    TextField("22", value: $model.dailyKwh, format: .number)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                    Text("kWh/day")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color(white: 0.15))
                .cornerRadius(8)
                
                Text("Auto-calculated from your bill, but editable")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }
}
