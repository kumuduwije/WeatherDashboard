//
//  CurrentWeatherView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//


import SwiftUI
import SwiftData

struct CurrentWeatherView: View {
    @EnvironmentObject var vm: MainAppViewModel
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.6),
                    Color.cyan.opacity(0.3),
                    Color.blue.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Location Name
                    Text(vm.activePlaceName.isEmpty ? "Loading..." : vm.activePlaceName)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    // MARK: - Current Date
                    Text(DateFormatterUtils.formattedCurrentDate(format: "EEEE, dd MMM yyyy"))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer().frame(height: 20)
                    
                    if let current = vm.currentWeather,
                       let weather = current.weather.first {
                        
                        // MARK: - Main Temperature Display
                        VStack(spacing: 8) {
                            // Weather icon
                            Image(systemName: weather.sfSymbolName)
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                                .symbolRenderingMode(.multicolor)
                            
                            // Temperature
                            Text("\(Int(current.temp.rounded()))°C")
                                .font(.system(size: 70, weight: .thin))
                                .foregroundColor(.white)
                            
                            // Weather description
                            Text(weather.description.capitalized)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.vertical, 20)
                        
                        // MARK: - High/Low Temperature
                        if let today = vm.dailyForecast.first {
                            HStack(spacing: 30) {
                                Label {
                                    Text("\(Int(today.temp.max.rounded()))°C")
                                        .font(.system(size: 18, weight: .semibold))
                                } icon: {
                                    Image(systemName: "arrow.up")
                                }
                                .foregroundColor(.white)
                                
                                Label {
                                    Text("\(Int(today.temp.min.rounded()))°C")
                                        .font(.system(size: 18, weight: .semibold))
                                } icon: {
                                    Image(systemName: "arrow.down")
                                }
                                .foregroundColor(.white)
                            }
                            .padding(.bottom, 20)
                        }
                        
                        // MARK: - Details Section
                        VStack(spacing: 0) {
                            Text("Details")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 15)
                            
                            VStack(spacing: 12) {
                                // Pressure
                                DetailRow(
                                    icon: "gauge",
                                    label: "Pressure",
                                    value: "\(current.pressure) hPa"
                                )
                                
                                Divider()
                                    .background(Color.white.opacity(0.3))
                                
                                // Sunrise
                                DetailRow(
                                    icon: "sunrise.fill",
                                    label: "Sunrise",
                                    value: DateFormatterUtils.formattedDate12Hour(from: TimeInterval(current.sunrise))
                                )
                                
                                Divider()
                                    .background(Color.white.opacity(0.3))
                                
                                // Sunset
                                DetailRow(
                                    icon: "sunset.fill",
                                    label: "Sunset",
                                    value: DateFormatterUtils.formattedDate12Hour(from: TimeInterval(current.sunset))
                                )
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(15)
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 10)
                        
                        // MARK: - Weather Advisory
                        if let today = vm.dailyForecast.first,
                           let todayWeather = today.weather.first {
                            let category = WeatherAdviceCategory.from(
                                temp: current.temp,
                                description: todayWeather.description
                            )
                            
                            HStack(spacing: 15) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 40))
                                    .foregroundColor(category.color)
                                    .symbolRenderingMode(.multicolor)
                                
                                Text(category.adviceText)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(category.color.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(category.color.opacity(0.5), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                        
                    } else {
                        // Loading state
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Loading weather data...")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(height: 400)
                    }
                    
                    Spacer().frame(height: 30)
                }
                .padding(.vertical)
            }
        }
    }
}

// MARK: - Detail Row Component
struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Label {
                Text(label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    CurrentWeatherView()
        .environmentObject(vm)
}
