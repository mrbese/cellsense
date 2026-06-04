import SwiftUI

struct PrioritiesStepView: View {
    @Bindable var model: CalculationModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header description
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Priorities")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text("Fine-tune what matters most to you")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 10)
            
            // Backup Power Value Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Backup Power Value")
                        .font(.footnote.bold())
                        .foregroundColor(.gray)
                    Spacer()
                    Text("$\(Int(model.backupValue))/yr")
                        .font(.subheadline.bold())
                        .foregroundColor(Color(red: 0.0, green: 0.83, blue: 0.67))
                }
                
                Slider(value: $model.backupValue, in: 0...2000, step: 50)
                    .tint(Color(red: 0.0, green: 0.83, blue: 0.67))
                
                HStack {
                    Text("$0 – Not important")
                    Spacer()
                    Text("$2,000 – Critical")
                }
                .font(.caption2)
                .foregroundColor(.gray)
                
                Text("What's it worth avoiding power outages? Consider food spoilage ($50-200), lost remote work ($100-500/day), medical equipment, and peace of mind.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineSpacing(3)
            }
            
            // VPP Programs Toggle
            VStack(alignment: .leading, spacing: 8) {
                Text("VPP Programs")
                    .font(.footnote.bold())
                    .foregroundColor(.gray)
                
                Toggle(isOn: $model.includeVpp) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Include VPP earnings in ROI")
                            .foregroundColor(.white)
                        Text("Virtual Power Plant programs pay you to share stored energy during grid peaks")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .tint(Color(red: 0.0, green: 0.83, blue: 0.67))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(white: 0.15))
                .cornerRadius(8)
            }
            
            // Federal Tax Credit Toggle
            VStack(alignment: .leading, spacing: 8) {
                Text("Federal Tax Credit")
                    .font(.footnote.bold())
                    .foregroundColor(.gray)
                
                Toggle(isOn: $model.applyITC) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Apply 30% ITC (requires solar)")
                            .foregroundColor(.white)
                        Text("Investment Tax Credit — 30% off installed cost when paired with solar panels")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .tint(Color(red: 0.0, green: 0.83, blue: 0.67))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(white: 0.15))
                .cornerRadius(8)
            }
        }
    }
}
