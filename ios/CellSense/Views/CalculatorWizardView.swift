import SwiftUI

struct CalculatorWizardView: View {
    @State private var model = CalculationModel()
    @State private var currentStep = 1
    @State private var navigateToResults = false
    
    var body: some View {
        ZStack {
            // Dark sleek background matching web app
            Color(red: 0.02, green: 0.04, blue: 0.06)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header brand title
                VStack(spacing: 8) {
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .cornerRadius(16)
                        .shadow(color: Color(red: 0.0, green: 0.83, blue: 0.67).opacity(0.3), radius: 6)
                    
                    HStack(spacing: 4) {
                        Text("Cell")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text("Sense")
                            .font(.title2.bold())
                            .foregroundColor(Color(red: 0.0, green: 0.83, blue: 0.67)) // Teal accent
                    }
                    Text("Home Battery ROI Calculator")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
                
                // Visual Wizard Progress Steps
                HStack(spacing: 12) {
                    stepIndicator(number: 1, label: "Utility")
                    progressLine(active: currentStep > 1)
                    stepIndicator(number: 2, label: "Home")
                    progressLine(active: currentStep > 2)
                    stepIndicator(number: 3, label: "Priorities")
                }
                .padding(.horizontal, 24)
                
                // Form step views
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if currentStep == 1 {
                            UtilityStepView(model: model)
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        } else if currentStep == 2 {
                            HomeStepView(model: model)
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        } else {
                            PrioritiesStepView(model: model)
                                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        }
                    }
                    .padding(20)
                    .background(Color(white: 0.07).opacity(0.8))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                }
                
                // Bottom navigation actions
                HStack(spacing: 16) {
                    if currentStep > 1 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep -= 1
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                Text("Back")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                    }
                    
                    if currentStep < 3 {
                        Button(action: {
                            if validateStep() {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStep += 1
                                }
                            }
                        }) {
                            HStack {
                                Text("Next: \(currentStep == 1 ? "Your Home" : "Priorities")")
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.0, green: 0.83, blue: 0.67))
                            .foregroundColor(.black)
                            .font(.body.bold())
                            .cornerRadius(10)
                        }
                    } else {
                        Button(action: {
                            model.runCalculation()
                            navigateToResults = true
                        }) {
                            HStack {
                                Text("⚡ Calculate My ROI")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.0, green: 0.83, blue: 0.67))
                            .foregroundColor(.black)
                            .font(.body.bold())
                            .cornerRadius(10)
                            .shadow(color: Color(red: 0.0, green: 0.83, blue: 0.67).opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .padding(.top, 10)
        }
        .navigationDestination(isPresented: $navigateToResults) {
            ResultsDashboardView(results: model.results, utility: model.selectedUtility, model: model)
        }
    }
    
    private func stepIndicator(number: Int, label: String) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(currentStep >= number ? Color(red: 0.0, green: 0.83, blue: 0.67) : Color.white.opacity(0.1))
                    .frame(width: 28, height: 28)
                
                Text("\(number)")
                    .font(.footnote.bold())
                    .foregroundColor(currentStep >= number ? .black : .gray)
            }
            
            Text(label)
                .font(.caption2)
                .foregroundColor(currentStep >= number ? .white : .gray)
        }
    }
    
    private func progressLine(active: Bool) -> some View {
        Rectangle()
            .fill(active ? Color(red: 0.0, green: 0.83, blue: 0.67) : Color.white.opacity(0.1))
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20) // align with circle centers
    }
    
    private func validateStep() -> Bool {
        if currentStep == 1 {
            return model.selectedUtility != nil && model.selectedRatePlan != nil && model.monthlyBill > 0
        }
        return true
    }
}

#Preview {
    NavigationStack {
        CalculatorWizardView()
    }
}
