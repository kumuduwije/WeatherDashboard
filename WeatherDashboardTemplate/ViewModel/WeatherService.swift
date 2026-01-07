//
//  WeatherService.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation

@MainActor
final class WeatherService {

    private let apiKey = "75f79e2702080d98db76deb94787415a"
    
    /// Fetches weather data from OpenWeather One Call API 3.0
    /// - Parameters:
    ///   - lat: Latitude coordinate
    ///   - lon: Longitude coordinate
    /// - Returns: Decoded WeatherResponse object with current weather and 8-day forecast
    /// - Throws: WeatherMapError for various failure scenarios
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&units=metric&appid=\(apiKey)"
        
        // Validate URL
        guard let url = URL(string: urlString) else {
            throw WeatherMapError.invalidURL(urlString)
        }
        
        print("Fetching weather for coordinates: (\(lat), \(lon))")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherMapError.invalidResponse(statusCode: -1)
            }
            
            guard httpResponse.statusCode == 200 else {
                print("API Error: Status code \(httpResponse.statusCode)")
                throw WeatherMapError.invalidResponse(statusCode: httpResponse.statusCode)
            }
            
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            
            let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
            
            print("Weather data fetched successfully for \(weatherResponse.timezone)")
            return weatherResponse
            
        } catch let error as DecodingError {
            
            print("Decoding error: \(error)")
            throw WeatherMapError.decodingError(error)
            
        } catch let error as WeatherMapError {
            throw error
            
        } catch {
            print("Network error: \(error.localizedDescription)")
            throw WeatherMapError.networkError(error)
        }
    }
}
