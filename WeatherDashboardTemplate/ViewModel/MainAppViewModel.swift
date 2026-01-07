//
//  MainAppViewModel.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData
import MapKit

@MainActor
final class MainAppViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var query = ""
    @Published var currentWeather: Current?
    @Published var dailyForecast: [Daily] = [] 
    @Published var pois: [AnnotationModel] = []
    @Published var mapRegion = MKCoordinateRegion()
    @Published var visited: [Place] = []
    @Published var isLoading = false
    @Published var appError: WeatherMapError?
    @Published var activePlaceName: String = ""
    @Published var selectedTab: Int = 0
    
    // Separate alert for success/info messages
    @Published var infoMessage: String?
    @Published var showInfoAlert = false
    
    private let defaultPlaceName = "London"
    
    // MARK: - Services
    private let weatherService = WeatherService()
    private let locationManager = LocationManager()
    
    // MARK: - SwiftData Context
    private let context: ModelContext
    
    // MARK: - Initialization
    init(context: ModelContext) {
        self.context = context
        
        // Fetch previously visited places, sorted by most recent
        if let results = try? context.fetch(
            FetchDescriptor<Place>(sortBy: [SortDescriptor(\Place.lastUsedAt, order: .reverse)])
        ) {
            self.visited = results
        }
        
        // First launch: Load default location (London)
        if visited.isEmpty {
            Task {
                await loadDefaultLocation()
            }
        } else if let mostRecent = visited.first {
            // Load most recently used place
            Task {
                await loadLocation(fromPlace: mostRecent)
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Called when user submits a search query
    func submitQuery() {
        let city = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !city.isEmpty else {
//            appError = .missingData(message: "Please enter a valid location.")
            return
        }
        Task {
            do {
                try await loadLocation(byName: city)
                query = ""
            } catch {
                // Error already handled in loadLocation
            }
        }
    }
    
    /// Loads the default location (London) on first launch
    func loadDefaultLocation() async {
        do {
            try await loadLocation(byName: defaultPlaceName)
        } catch {
            appError = .networkError(error)
        }
    }
    
    /// Loads location data by name - handles both new and existing locations
    func loadLocation(byName: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        print("\n🔍 === Loading location: \(byName) ===")
        
        // Check if place already exists in database
        if let existingPlace = visited.first(where: { $0.name.lowercased() == byName.lowercased() }) {
            print("📦 Location found in database, loading from storage...")
            await loadLocation(fromPlace: existingPlace)
            showInfoMessage("Location '\(existingPlace.name)' loaded from storage")
            return
        }
        
        // New place - start geocoding
        do {
            // 1. Geocode the address
            let (name, lat, lon) = try await locationManager.geocodeAddress(byName)
            
            // 2. Fetch weather as fail-fast check
            let weatherResponse = try await weatherService.fetchWeather(lat: lat, lon: lon)
            
            // 3. Find POIs
            let poiList = try await locationManager.findPOIs(lat: lat, lon: lon)
            
            // 4. Create new Place object
            let newPlace = Place(name: name, latitude: lat, longitude: lon)
            
            // 5. Associate POIs with the place
            for poi in poiList {
                poi.place = newPlace
                newPlace.annotations.append(poi)
            }
            
            // 6. Insert into context and save
            context.insert(newPlace)
            visited.insert(newPlace, at: 0)
            
            do {
                try context.save()
                print("💾 Place saved to database: \(name)")
            } catch {
                print("❌ Failed to save context: \(error)")
                throw WeatherMapError.networkError(error)
            }
            
            // 7. Update UI with all data
            try await loadAll(for: newPlace)
            
            // 8. Show success message
            showInfoMessage("Location '\(name)' saved successfully")
            
        } catch {
            print("❌ Error loading location '\(byName)': \(error)")
            await revertToDefaultWithAlert(message: "Could not find location '\(byName)'. Please try another name.")
            throw error
        }
    }
    
    /// Loads data for an existing Place from the database
    func loadLocation(fromPlace place: Place) async {
        isLoading = true
        defer { isLoading = false }
        
        print("\n📦 === Loading from database: \(place.name) ===")
        
        do {
            // Update lastUsedAt timestamp
            place.lastUsedAt = .now
            try context.save()
            
            // Load all data (weather + POIs)
            try await loadAll(for: place)
            
        } catch {
            print("❌ Error loading place: \(error)")
            appError = .networkError(error)
        }
    }
    
    /// Deletes a place from the database
    func delete(place: Place) {
        print("🗑️ Deleting place: \(place.name)")
        
        context.delete(place)
        visited.removeAll { $0.id == place.id }
        
        do {
            try context.save()
            print("✅ Place deleted successfully")
        } catch {
            print("❌ Failed to delete place: \(error)")
            appError = .networkError(error)
        }
    }
    
    /// Focuses the map on a specific coordinate with zoom level
    func focus(on coordinate: CLLocationCoordinate2D, zoom: Double = 0.02) {
        withAnimation {
            mapRegion = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: zoom, longitudeDelta: zoom)
            )
        }
        print("🗺️ Map focused on (\(coordinate.latitude), \(coordinate.longitude)) with zoom: \(zoom)")
    }
    
    // MARK: - Private Methods
    
    /// Shows an informational message (not an error)
    private func showInfoMessage(_ message: String) {
        infoMessage = message
        showInfoAlert = true
    }
    
    /// Loads all data (weather + POIs) for a given place
    private func loadAll(for place: Place) async throws {
        activePlaceName = place.name
        print("📍 Loading all data for: \(place.name)")
        
        // ALWAYS fetch fresh weather data from API
        let weatherResponse = try await weatherService.fetchWeather(
            lat: place.latitude,
            lon: place.longitude
        )
        
        // Store full current weather object
        currentWeather = weatherResponse.current
        
        // Store full daily forecast (8 days)
        dailyForecast = Array(weatherResponse.daily.prefix(8))
        
        print("✅ Weather loaded: \(currentWeather?.weather.first?.main ?? "Unknown")")
        print("✅ Forecast loaded: \(dailyForecast.count) days")
        
        // Handle POIs
        if place.annotations.isEmpty {
            print("🔍 No POIs in database, fetching new ones...")
            
            let poiList = try await locationManager.findPOIs(
                lat: place.latitude,
                lon: place.longitude
            )
            
            for poi in poiList {
                poi.place = place
                place.annotations.append(poi)
            }
            
            try context.save()
            print("💾 POIs saved to database")
            
            pois = poiList
        } else {
            print("📦 Using cached POIs from database (\(place.annotations.count) items)")
            pois = place.annotations
        }
        
        // Update map region
        focus(on: place.coordinate)
        
        // re-order when change the visited array
//        if let index = visited.firstIndex(where: { $0.id == place.id }), index != 0 {
//            visited.remove(at: index)
//            visited.insert(place, at: 0)
//        }
        
        print("✅ === All data loaded successfully ===\n")
    }
    
    /// Reverts to default location and shows an alert
    private func revertToDefaultWithAlert(message: String) async {
        print("⚠️ Reverting to default location: \(defaultPlaceName)")
        appError = .missingData(message: message)
        await loadDefaultLocation()
    }
}
