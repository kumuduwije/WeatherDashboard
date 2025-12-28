//
//  Place.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//
// MARK: SwiftData models with proper relationships

import SwiftData
import CoreLocation

/// Represents a saved location with its tourist attractions
@Model
final class Place {
    @Attribute(.unique) var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var lastUsedAt: Date
    
    /// One-to-many relationship: One Place has many POIs
    /// deleteRule: .cascade means when Place is deleted, all its annotations are also deleted
    /// inverse: Creates bidirectional relationship
    @Relationship(deleteRule: .cascade, inverse: \AnnotationModel.place)
    var annotations: [AnnotationModel] = []
    
    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double,
        annotations: [AnnotationModel] = []
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.lastUsedAt = .now
        self.annotations = annotations
    }
    
    /// Convenience computed property for CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// Represents a Point of Interest (tourist attraction) associated with a Place
@Model
final class AnnotationModel: Identifiable {
    var id: UUID = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
    
    /// Many-to-one relationship: Many POIs belong to one Place
    var place: Place?
    
    init(name: String, latitude: Double, longitude: Double, place: Place? = nil) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.place = place
    }
    
    /// Convenience computed property for CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
