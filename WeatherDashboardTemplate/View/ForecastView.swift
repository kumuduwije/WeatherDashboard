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
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.80, green: 0.83, blue: 0.98), location: 0.00), // light sky blue
                    .init(color: Color(red: 0.86, green: 0.84, blue: 0.95), location: 0.55), // soft lavender
                    .init(color: Color(red: 0.97, green: 0.74, blue: 0.82), location: 1.00)  // soft pink
                ]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("8 Day Forecast - \(vm.activePlaceName)")
                            .font(.system(size: 28, weight: .regular))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25))
                        
                        Text("Daily Highs and Lows (°C)")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    // MARK: - Chart & Title
                    if !chartData.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            // Chart
                            Chart(chartData) { data in
                                BarMark(
                                    x: .value("Date", data.date, unit: .day),
                                    y: .value("Temperature", data.value)
                                )
                                
                                .foregroundStyle(data.type == "Low" ? Color.blue.gradient : Color.orange.gradient)
                                .position(by: .value("Type", data.type))
                            }
                            .frame(height: 250)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .chartYAxis {
                                AxisMarks(position: .leading) { value in
                                    AxisValueLabel {
                                        if let temp = value.as(Double.self) {
                                            Text("\(Int(temp))°")
                                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                                        }
                                    }
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                        .foregroundStyle(Color.gray.opacity(0.3))
                                }
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) { value in
                                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                                        .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.5))
                                }
                            }
                            
                            Spacer().frame(height: 20)
                            
                            // Divider
                            Divider()
                                .background(Color(red: 0.5, green: 0.5, blue: 0.6).opacity(0.3))
                                .padding(.horizontal, 20)
                            
                            Spacer().frame(height: 10)
                            
                            Text("Detailed Daily Summary")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25))
                                .padding(.horizontal)
                                .padding(.bottom,6)
                                

                        }
                        .background(
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
//                        .padding(.horizontal, 15)
                    }
                    
                    Spacer().frame(height: 15)
                    
                    // MARK: - Daily Summary List
                    VStack(spacing: 0) {
                        ForEach(Array(vm.dailyForecast.enumerated()), id: \.element.id) { index, day in
                            DailyForecastRow(daily: day)
                            
                            // Divider between rows (not after last one)
                            if index < vm.dailyForecast.count - 1 {
                                Divider()
                                    .background(Color(red: 0.5, green: 0.5, blue: 0.6).opacity(0.2))
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.3))
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, 15)
                    
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
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                // Date
                Text(DateFormatterUtils.formattedDateWithWeekdayAndDay(from: TimeInterval(daily.dt)))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25))
                
                // Summary description
                Text(daily.summary)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    .lineLimit(2)
                
                // Temperature range
                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Text("Low:")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25))
                        Text("\(Int(daily.temp.min.rounded()))°C")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25))
                    }
                    
                    HStack(spacing: 6) {
                        Text("High:")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25))
                        Text("\(Int(daily.temp.max.rounded()))°C")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25))
                    }
                }
            }
            
            Spacer()
            
            // Weather icon on the right
            if let weather = daily.weather.first {
                Image(systemName: weather.sfSymbolName)
                    .font(.system(size: 28))
                    .foregroundColor(Color(red: 0.2, green: 0.25, blue: 0.35))
                    .symbolRenderingMode(.hierarchical)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    ForecastView()
        .environmentObject(vm)
}
