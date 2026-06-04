import SwiftUI
import Charts

struct ResultsDashboardView: View {
    let results: [PaybackResult]
    let utility: Utility?
    let model: CalculationModel
    
    @State private var selectedChartTab = 0 // 0: Timeline, 1: Payback, 2: Savings
    @State private var activeMathSheet: PaybackResult? = nil
    
    // Finds the best-value system
    private var bestValueResult: PaybackResult? {
        results.max(by: { $0.netBenefit < $1.netBenefit })
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.02, green: 0.04, blue: 0.06)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Header text
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Battery ROI Comparison")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text("Side-by-side analysis of home battery systems based on your inputs")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    
                    // Horizontally scrollable comparison cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(results) { result in
                                BatteryCardView(result: result) {
                                    activeMathSheet = result
                                }
                                .frame(width: 290)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Chart Segment Picker
                    VStack(alignment: .leading, spacing: 16) {
                        Picker("Chart View", selection: $selectedChartTab) {
                            Text("Timeline").tag(0)
                            Text("Payback Bar").tag(1)
                            Text("Savings Shares").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 16)
                        
                        // Active Chart Container
                        VStack(alignment: .leading, spacing: 16) {
                            if selectedChartTab == 0 {
                                cumulativeTimelineChart
                            } else if selectedChartTab == 1 {
                                paybackBarChart
                            } else {
                                savingsDonutChart
                            }
                        }
                        .padding(16)
                        .background(Color(white: 0.08))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    // Disclosure footnote
                    Text("CellSense provides estimates based on published utility rate data (Q1 2026). Actual savings depend on usage patterns, rate changes, and system performance. Not financial advice.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.top, 10)
                }
                .padding(.vertical, 20)
            }
        }
        .navigationTitle("ROI Results")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $activeMathSheet) { result in
            MathBreakdownView(result: result)
        }
    }
    
    // ── CHART 1: 10-Yr Cumulative Line Chart ──
    private var cumulativeTimelineChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("10-Year Cumulative Net Benefit")
                .font(.headline)
                .foregroundColor(.white)
            Text("Cumulative cash flow over time, factoring in upfront costs and annual savings.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 8)
            
            Chart {
                ForEach(results) { result in
                    // Start from Year 0 (Net system cost negative)
                    LineMark(
                        x: .value("Year", 0),
                        y: .value("Benefit", -result.netSystemCost),
                        series: .value("System", result.battery.shortName)
                    )
                    .foregroundStyle(Color(hex: result.battery.color))
                    .interpolationMethod(.monotone)
                    
                    PointMark(
                        x: .value("Year", 0),
                        y: .value("Benefit", -result.netSystemCost)
                    )
                    .foregroundStyle(Color(hex: result.battery.color))
                    
                    ForEach(result.projection) { point in
                        LineMark(
                            x: .value("Year", point.year),
                            y: .value("Benefit", point.cumulative),
                            series: .value("System", result.battery.shortName)
                        )
                        .foregroundStyle(Color(hex: result.battery.color))
                        .interpolationMethod(.monotone)
                        
                        PointMark(
                            x: .value("Year", point.year),
                            y: .value("Benefit", point.cumulative)
                        )
                        .foregroundStyle(Color(hex: result.battery.color))
                    }
                }
            }
            .frame(height: 250)
            .chartXAxis {
                AxisMarks(values: .stride(by: 2)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(Color.white.opacity(0.1))
                    AxisValueLabel().foregroundStyle(Color.gray)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(Color.white.opacity(0.1))
                    AxisValueLabel {
                        if let doubleVal = value.as(Double.self) {
                            Text("$\(Int(doubleVal).formatted())")
                        }
                    }
                    .foregroundStyle(Color.gray)
                }
            }
            
            // Custom Legend
            FlowLayout(spacing: 12) {
                ForEach(results) { result in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: result.battery.color))
                            .frame(width: 8, height: 8)
                        Text(result.battery.shortName)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.top, 8)
        }
    }
    
    // ── CHART 2: Payback Side-by-side Bar Chart ──
    private var paybackBarChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payback Period (Years)")
                .font(.headline)
                .foregroundColor(.white)
            Text("Shorter is faster. Omitted values indicate infinite payback periods.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 8)
            
            Chart {
                ForEach(results) { result in
                    if result.paybackYears.isFinite {
                        BarMark(
                            x: .value("System", result.battery.shortName),
                            y: .value("Payback", result.paybackYears)
                        )
                        .foregroundStyle(Color(hex: result.battery.color))
                        .annotation(position: .top) {
                            Text(String(format: "%.1f", result.paybackYears))
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(Color.white.opacity(0.1))
                    AxisValueLabel().foregroundStyle(Color.gray)
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel().foregroundStyle(Color.white)
                }
            }
        }
    }
    
    // ── CHART 3: Savings shares Sector/Donut Chart ──
    private var savingsDonutChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let best = bestValueResult {
                Text("Annual Savings Shares (\(best.battery.shortName))")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Percentage shares of annual benefit components for the Best Value battery.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)
                
                let touVal = Double(best.components.arbitrage.annualSavings)
                let vppVal = best.components.vpp.annualEarnings.mid
                let backupVal = Double(best.components.backup.annualValue)
                let total = touVal + vppVal + backupVal
                
                Chart {
                    if touVal > 0 {
                        SectorMark(
                            angle: .value("Arbitrage", Double(touVal)),
                            innerRadius: .ratio(0.6),
                            angularInset: 2.0
                        )
                        .foregroundStyle(Color(red: 0.0, green: 0.83, blue: 0.67))
                    }
                    
                    if vppVal > 0 {
                        SectorMark(
                            angle: .value("VPP", Double(vppVal)),
                            innerRadius: .ratio(0.6),
                            angularInset: 2.0
                        )
                        .foregroundStyle(Color(red: 0.96, green: 0.62, blue: 0.04))
                    }
                    
                    if backupVal > 0 {
                        SectorMark(
                            angle: .value("Backup", Double(backupVal)),
                            innerRadius: .ratio(0.6),
                            angularInset: 2.0
                        )
                        .foregroundStyle(Color(red: 0.55, green: 0.36, blue: 0.96))
                    }
                }
                .frame(height: 180)
                .chartBackground { chartProxy in
                    GeometryReader { geo in
                        if let anchor = chartProxy.plotFrame {
                            let frame = geo[anchor]
                            VStack(spacing: 2) {
                                Text("Best Value")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Text("$\(Int(total).formatted())/yr")
                                    .font(.headline.bold())
                                    .foregroundColor(.white)
                            }
                            .position(x: frame.midX, y: frame.midY)
                        }
                    }
                }
                
                // Legend
                VStack(spacing: 6) {
                    legendItem(color: Color(red: 0.0, green: 0.83, blue: 0.67), label: "TOU Arbitrage", value: touVal, total: total)
                    legendItem(color: Color(red: 0.96, green: 0.62, blue: 0.04), label: "VPP Program", value: vppVal, total: total)
                    legendItem(color: Color(red: 0.55, green: 0.36, blue: 0.96), label: "Backup Outages", value: backupVal, total: total)
                }
                .padding(.top, 8)
            } else {
                Text("No data available")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func legendItem(color: Color, label: String, value: Double, total: Double) -> some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
            let pct = total > 0 ? Int(round((value / total) * 100)) : 0
            Text("$\(Int(value))/yr (\(pct)%)")
                .font(.caption2.bold())
                .foregroundColor(.white)
        }
    }
}

// Custom flow layout for legend items on line chart
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.replacingUnspecifiedDimensions().width
        var height: CGFloat = 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if currentX + size.width > width {
                currentX = 0
                currentY += maxHeight + spacing
                maxHeight = 0
            }
            currentX += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
        height = currentY + maxHeight
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += maxHeight + spacing
                maxHeight = 0
            }
            view.place(at: CGPoint(x: currentX, y: currentY), proposal: ProposedViewSize(size))
            currentX += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
    }
}
