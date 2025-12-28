//
//  ForecastView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//



import SwiftUI
import SwiftData
import Charts

// MARK: - Temperature Category Enum
enum TempCategory: String, CaseIterable {
    case freezing = "Freezing"
    case cold = "Cold"
    case cool = "Cool"
    case mild = "Mild"
    case warm = "Warm"
    case hot = "Hot"
    
    /// Color for each temperature category
    var color: Color {
        switch self {
        case .freezing: return .blue
        case .cold: return .cyan
        case .cool: return .teal
        case .mild: return .green
        case .warm: return .orange
        case .hot: return .red
        }
    }
    
    /// Convert temperature to category
    static func from(tempC: Double) -> TempCategory {
        switch tempC {
        case ..<0: return .freezing
        case 0..<10: return .cold
        case 10..<15: return .cool
        case 15..<20: return .mild
        case 20..<28: return .warm
        default: return .hot
        }
    }
}

// MARK: - Temperature Data Model for Chart
private struct TempData: Identifiable {
    let id = UUID()
    let date: Date
    let type: String        // "High" or "Low"
    let value: Double       // Temperature value
    let category: TempCategory
}

// MARK: - Forecast View
struct ForecastView: View {
    @EnvironmentObject var vm: MainAppViewModel
    
    /// Convert daily forecast to chart data
    private var chartData: [TempData] {
        vm.dailyForecast.flatMap { day -> [TempData] in
            let date = Date(timeIntervalSince1970: TimeInterval(day.dt))
            
            return [
                TempData(
                    date: date,
                    type: "High",
                    value: day.temp.max,
                    category: .from(tempC: day.temp.max)
                ),
                TempData(
                    date: date,
                    type: "Low",
                    value: day.temp.min,
                    category: .from(tempC: day.temp.min)
                )
            ]
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.indigo.opacity(0.4),
                    Color.blue.opacity(0.2),
                    Color.cyan.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Header
                    VStack(spacing: 5) {
                        Text("8 Day Forecast - \(vm.activePlaceName)")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Daily Highs and Lows (°C)")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Bar Chart
                    if !chartData.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Temperature Chart")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            Chart(chartData) { data in
                                BarMark(
                                    x: .value("Date", data.date, unit: .day),
                                    y: .value("Temperature", data.value)
                                )
                                .foregroundStyle(data.category.color.gradient)
                                .position(by: .value("Type", data.type))
                            }
                            .frame(height: 250)
                            .padding(.horizontal, 20)
                            .chartYAxis {
                                AxisMarks(position: .leading) { value in
                                    AxisValueLabel {
                                        if let temp = value.as(Double.self) {
                                            Text("\(Int(temp))°")
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                        .foregroundStyle(.white.opacity(0.2))
                                }
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) { value in
                                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                                        .foregroundStyle(Color.white.opacity(0.8))
                                }
                            }
                            .chartLegend(position: .bottom) {
                                HStack(spacing: 20) {
                                    Label("High", systemImage: "arrow.up.circle.fill")
                                    Label("Low", systemImage: "arrow.down.circle.fill")
                                }
                                .foregroundColor(.white.opacity(0.9))
                                .font(.caption)
                            }
                        }
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.1))
                        )
                        .padding(.horizontal, 15)
                    }
                    
                    // MARK: - Detailed Daily Summary
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Detailed Daily Summary")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        ForEach(vm.dailyForecast) { day in
                            DailyForecastRow(daily: day)
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer().frame(height: 30)
                }
            }
        }
    }
}

// MARK: - Daily Forecast Row Component
struct DailyForecastRow: View {
    let daily: Daily
    
    var body: some View {
        VStack(spacing: 12) {
            // Date
            HStack {
                Text(DateFormatterUtils.formattedDateWithWeekdayAndDay(from: TimeInterval(daily.dt)))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if let weather = daily.weather.first {
                    Image(systemName: weather.sfSymbolName)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .symbolRenderingMode(.multicolor)
                }
            }
            
            // Temperature range
            HStack(spacing: 15) {
                Label {
                    Text("High: \(Int(daily.temp.max.rounded()))°C")
                        .font(.system(size: 15, weight: .medium))
                } icon: {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.orange)
                }
                
                Label {
                    Text("Low: \(Int(daily.temp.min.rounded()))°C")
                        .font(.system(size: 15, weight: .medium))
                } icon: {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.cyan)
                }
            }
            .foregroundColor(.white.opacity(0.9))
            
            // Weather description and summary
            if let weather = daily.weather.first {
                VStack(alignment: .leading, spacing: 4) {
                    Text(weather.description.capitalized)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.95))
                    
                    Text(daily.summary)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    ForecastView()
        .environmentObject(vm)
}
