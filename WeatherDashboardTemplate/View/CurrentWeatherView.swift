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
    @State private var isCelsius: Bool = true
    @State private var iconScale: CGFloat = 0.5
    @State private var advisoryIconScale: CGFloat = 0.5

    // Convert temperature based on selected unit
    private func convertTemp(_ celsius: Double) -> String {
        if isCelsius {
            return "\(Int(celsius.rounded()))°C"
        } else {
            let fahrenheit = (celsius * 9/5) + 32
            return "\(Int(fahrenheit.rounded()))°F"
        }
    }

    private func generateShareText(current: Current, weather: Weather, today: Daily) -> String {
        let location = vm.activePlaceName
        let date = DateFormatterUtils.formattedCurrentDate(format: "EEEE, MMM dd")
        let temp = convertTemp(current.temp)
        let high = convertTemp(today.temp.max)
        let low = convertTemp(today.temp.min)
        let description = weather.description.capitalized

        return """
        \(weather.main) in \(location)
        \(date)

        \(temp) - \(description)
        High: \(high) | Low: \(low)

        Shared from Weather Dashboard
        """
    }

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
                        
                        // MARK: - Location and Date Header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .center) {
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

                            // Temperature Unit Toggle
                            HStack {
                                Spacer()

                                HStack(spacing: 4) {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            isCelsius = true
                                        }
                                    }) {
                                        Text("°C")
                                            .font(.system(size: 14, weight: isCelsius ? .bold : .medium))
                                            .foregroundColor(isCelsius ? Color(red: 0.15, green: 0.15, blue: 0.25) : Color(red: 0.5, green: 0.5, blue: 0.6))
                                    }

                                    Text("|")
                                        .font(.system(size: 14, weight: .light))
                                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))

                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            isCelsius = false
                                        }
                                    }) {
                                        Text("°F")
                                            .font(.system(size: 14, weight: !isCelsius ? .bold : .medium))
                                            .foregroundColor(!isCelsius ? Color(red: 0.15, green: 0.15, blue: 0.25) : Color(red: 0.5, green: 0.5, blue: 0.6))
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.4))
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 3)
                        
                        Spacer().frame(height: 30)
                        
                        // MARK: - SHADOW CARD CONTAINER
                        VStack(spacing: 0) {
                            
                            Spacer().frame(height: 25)
                            
                            // MARK: - Temperature and Weather Icon
                            HStack(alignment: .top, spacing: 15) {
                                // Temperature with Share Button
                                HStack(alignment: .top, spacing: 4) {
                                    Text(convertTemp(current.temp))
                                        .font(.system(size: 70, weight: .bold))
                                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)

                                    // Share Button
                                    ShareLink(item: generateShareText(current: current, weather: weather, today: today)) {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25).opacity(0.7))
                                            .padding(6)
                                            .background(
                                                Circle()
                                                    .fill(Color.white.opacity(0.25))
                                            )
                                    }
                                    .padding(.top, 8)
                                }

                                Spacer()

                                // Weather icon
                                Image(systemName: weather.sfSymbolName)
                                    .font(.system(size: 70))
                                    .foregroundColor(Color(red: 0.2, green: 0.25, blue: 0.35))
                                    .symbolRenderingMode(.hierarchical)
                                    .scaleEffect(iconScale)
                                    .onAppear {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0)) {
                                            iconScale = 1.0
                                        }
                                    }
                                    .onChange(of: vm.activePlaceName) { _, _ in
                                        iconScale = 0.5
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0)) {
                                            iconScale = 1.0
                                        }
                                    }
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
                                    Text(convertTemp(today.temp.max))
                                        .font(.system(size: 22, weight: .bold))
                                }
                                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.25))

                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.down")
                                        .font(.system(size: 18, weight: .bold))
                                    Text(convertTemp(today.temp.min))
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
                                        .scaleEffect(advisoryIconScale)
                                        .onAppear {
                                            withAnimation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0).delay(0.3)) {
                                                advisoryIconScale = 1.0
                                            }
                                        }
                                        .onChange(of: vm.activePlaceName) { _, _ in
                                            advisoryIconScale = 0.5
                                            withAnimation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0).delay(0.3)) {
                                                advisoryIconScale = 1.0
                                            }
                                        }
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
