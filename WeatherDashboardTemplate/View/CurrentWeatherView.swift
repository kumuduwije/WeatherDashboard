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
            // Gradient background - light blue to pink/purple
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.6936, green: 0.6891, blue: 0.7833), // top (soft blue/indigo)
                    Color(red: 0.9491, green: 0.8063, blue: 0.8362), // middle (soft pink)
                    Color(red: 0.8553, green: 0.7366, blue: 0.9399)  // bottom (lavender/purple)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 70)
                    if let current = vm.currentWeather,
                       let weather = current.weather.first,
                       let today = vm.dailyForecast.first {
                        
                        // MARK: - Location and Date Header (OUTSIDE SHADOW CARD)
                        HStack() {
                            // Location name
                            Text(vm.activePlaceName.isEmpty ? "Loading..." : vm.activePlaceName)
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25))
                            
                            Spacer()
                            
                            // Date
                            Text(DateFormatterUtils.formattedCurrentDate(format: "EEEE, MMM dd"))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 3)
                        
                        Spacer().frame(height: 30)
                        
                        // MARK: - SHADOW CARD CONTAINER
                        VStack(spacing: 0) {
                            
                            Spacer().frame(height: 25)
                            
                            // MARK: - Temperature (LEFT) and Weather Icon (RIGHT)
                            HStack {
                                Text("\(Int(current.temp.rounded()))°C")
                                    .font(.system(size: 70, weight: .bold))
                                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25))
                                
                                Spacer()
                                
                                // Weather icon - RIGHT
                                Image(systemName: weather.sfSymbolName)
                                    .font(.system(size: 70))
                                    .foregroundColor(Color(red: 0.2, green: 0.25, blue: 0.35))
                                    .symbolRenderingMode(.hierarchical)
                            }
                            .padding(.horizontal, 20)
                            
                            Spacer().frame(height: 15)
                            
                            // MARK: - Weather Description (LEFT ALIGNED)
                            HStack {
                                Text(weather.description.capitalized)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25))
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            Spacer().frame(height: 20)
                            
                            // MARK: - High/Low Temperatures (LEFT ALIGNED)
                            HStack(spacing: 20) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.up")
                                        .font(.system(size: 18, weight: .bold))
                                    Text("\(Int(today.temp.max.rounded()))°C")
                                        .font(.system(size: 22, weight: .bold))
                                }
                                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25))
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.down")
                                        .font(.system(size: 18, weight: .bold))
                                    Text("\(Int(today.temp.min.rounded()))°C")
                                        .font(.system(size: 22, weight: .bold))
                                }
                                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25))
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            Spacer().frame(height: 30)
                            
                            // MARK: - Divider
                            Divider()
                                .background(Color(red: 0.5, green: 0.5, blue: 0.6).opacity(0.3))
                                .padding(.horizontal, 20)
                            
                            Spacer().frame(height: 25)
                            
                            // MARK: - Details Section
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Details")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                                    .padding(.horizontal, 20)
                                
                                Spacer().frame(height: 20)
                                
                                // Pressure
                                DetailRow(
                                    icon: "gauge",
                                    iconColor: Color.blue,
                                    label: "Pressure",
                                    value: "\(current.pressure) hPa"
                                )
                                .padding(.horizontal, 20)
                                
                                Spacer().frame(height: 15)
                                
                                // Sunrise
                                DetailRow(
                                    icon: "sunrise.fill",
                                    iconColor: Color.blue,
                                    label: "Sunrise",
                                    value: DateFormatterUtils.formattedDate24Hour(from: TimeInterval(current.sunrise))
                                )
                                .padding(.horizontal, 20)
                                
                                Spacer().frame(height: 15)
                                
                                // Sunset
                                DetailRow(
                                    icon: "sunset.fill",
                                    iconColor: Color.blue,
                                    label: "Sunset",
                                    value: DateFormatterUtils.formattedDate24Hour(from: TimeInterval(current.sunset))
                                )
                                .padding(.horizontal, 20)
                            }
                            
                            Spacer().frame(height: 30)
                            
                            // MARK: - Divider
                            Divider()
                                .background(Color(red: 0.5, green: 0.5, blue: 0.6).opacity(0.3))
                                .padding(.horizontal, 20)
                            
                            Spacer().frame(height: 25)
                            
                            // MARK: - Weather Advisory Box
                            let category = WeatherAdviceCategory.from(
                                temp: current.temp,
                                description: weather.description
                            )
                            
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(category.color.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: category.icon)
                                        .font(.system(size: 30))
                                        .foregroundColor(category.color)
                                        .symbolRenderingMode(.hierarchical)
                                }
                                
                                // Advisory text
                                Text(category.adviceText)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)
                            }
                            .padding(15)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.4))
                            )
                            .padding(.horizontal, 20)
                            
                            Spacer().frame(height: 25)
                            
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.25))
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
                        .padding(.horizontal, 15)
                        
                        Spacer().frame(height: 30)
                        
                    } else {
                        // Loading state
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(Color(red: 0.15, green: 0.15, blue: 0.25))
                            Text("Loading weather data...")
                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                        }
                        .frame(height: 400)
                    }
                }
            }
        }
    }
}

// MARK: - Detail Row Component
struct DetailRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 10) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 30)
            
            // Label
            Text(label)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25))
            
            Spacer()
            
            // Value
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25))
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Place.self, AnnotationModel.self, configurations: config)
    let vm = MainAppViewModel(context: ModelContext(container))
    
    return CurrentWeatherView()
        .environmentObject(vm)
}
