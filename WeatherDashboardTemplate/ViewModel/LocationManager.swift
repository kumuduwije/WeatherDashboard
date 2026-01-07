//
//  LocationManager.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import Foundation
import CoreLocation
@preconcurrency import MapKit

@MainActor
final class LocationManager {
    
    /// Converts a place name or address into geographic coordinates
    /// - Parameter address: The location name (e.g., "London", "Paris", "Tokyo")
    /// - Returns: Tuple containing (name, latitude, longitude)
    /// - Throws: WeatherMapError.geocodingFailed if location cannot be found
    func geocodeAddress(_ address: String) async throws -> (name: String, lat: Double, lon: Double) {
        print("Geocoding address: \(address)")
        
        // Geocoder instance
        let geocoder = CLGeocoder()
        
        do {
            // Perform async geocoding
            let placemarks = try await geocoder.geocodeAddressString(address)
            
            // Validate results
            guard let placemark = placemarks.first,
                  let location = placemark.location else {
                print("No location found for: \(address)")
                throw WeatherMapError.geocodingFailed(address)
            }
            
            // Extract name (prefer locality, fallback to name)
            let name = placemark.locality ?? placemark.name ?? address
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            print("Geocoded '\(address)' → \(name) (\(lat), \(lon))")
            
            return (name: name, lat: lat, lon: lon)
            
        } catch let error as WeatherMapError {
            // Re-throw our custom errors
            throw error
        } catch {
            // Geocoding failed
            print("Geocoding failed: \(error.localizedDescription)")
            throw WeatherMapError.geocodingFailed(address)
        }
    }
    
    /// Finds tourist attractions (POIs) near the given coordinates
    /// - Parameters:
    ///   - lat: Latitude coordinate
    ///   - lon: Longitude coordinate
    ///   - limit: Maximum number of POIs to return (default: 5)
    /// - Returns: Array of AnnotationModel objects representing tourist attractions
    /// - Throws: WeatherMapError if search fails
    func findPOIs(lat: Double, lon: Double, limit: Int = 5) async throws -> [AnnotationModel] {
        print("Searching for POIs near (\(lat), \(lon))")
        
        // Create coordinate and region
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        // Small region (1km radius) around the location
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        
        // Create search request for tourist attractions
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Tourist Attractions"
        request.region = region
        
        // Perform search
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            
            // Convert MKMapItem results to AnnotationModel
            let annotations = response.mapItems
                .compactMap { item -> AnnotationModel? in
                    // Filter out items without names
                    guard let name = item.name else { return nil }
                    
                    return AnnotationModel(
                        name: name,
                        latitude: item.placemark.coordinate.latitude,
                        longitude: item.placemark.coordinate.longitude
                    )
                }
                .prefix(limit) // Limit to requested number
                .map { $0 } // Convert Slice to Array
            
            print("Found \(annotations.count) tourist attractions")
            
            
            for (index, poi) in annotations.enumerated() {
                print("   \(index + 1). \(poi.name)")
            }
            
            return Array(annotations)
            
        } catch {
            // Search failed (network error, invalid region, etc.)
            print("POI search failed: \(error.localizedDescription)")
            throw WeatherMapError.networkError(error)
        }
    }
}
