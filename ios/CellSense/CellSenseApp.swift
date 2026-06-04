import SwiftUI

@main
struct CellSenseApp: App {
    init() {
        // Initialize DataManager on app start
        _ = DataManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CalculatorWizardView()
            }
        }
    }
}
