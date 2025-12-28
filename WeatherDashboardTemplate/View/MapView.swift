//
//  MapView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @EnvironmentObject var vm: MainAppViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Interactive Map
            Map(initialPosition: .region(vm.mapRegion)) {
                // Add annotations for all POIs
                ForEach(vm.pois) { poi in
                    Annotation(poi.name, coordinate: poi.coordinate) {
                        POIMarker(poi: poi)
                            .onTapGesture {
                                handlePinTap(poi: poi)
                            }
                            .onLongPressGesture {
                                handlePinLongPress(poi: poi)
                            }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .frame(height: 350)
            // Update map when region changes
            .id(vm.mapRegion.center.latitude + vm.mapRegion.center.longitude)
            
            // MARK: - POI List
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.blue)
                    Text("Top 5 Tourist Attractions in \(vm.activePlaceName)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color(.systemBackground))
                
                Divider()
                
                // Scrollable list of POIs
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(vm.pois.enumerated()), id: \.element.id) { index, poi in
                            POIListItem(poi: poi, index: index + 1)
                                .onTapGesture {
                                    handleListItemTap(poi: poi)
                                }
                                .onLongPressGesture {
                                    handlePinLongPress(poi: poi)
                                }
                            
                            if index < vm.pois.count - 1 {
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                    }
                }
                
                // Empty state
                if vm.pois.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "map")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No tourist attractions found")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("Try searching for a different location")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - Interaction Handlers
    
    /// Handles tap on map pin - zooms to 500m region
    private func handlePinTap(poi: AnnotationModel) {
        print("📍 Pin tapped: \(poi.name)")
        vm.focus(on: poi.coordinate, zoom: 0.005) // 500m region
    }
    
    /// Handles tap on list item - centers map on POI
    private func handleListItemTap(poi: AnnotationModel) {
        print("📋 List item tapped: \(poi.name)")
        vm.focus(on: poi.coordinate, zoom: 0.02) // Standard zoom
    }
    
    /// Handles long press - opens Google search
    private func handlePinLongPress(poi: AnnotationModel) {
        print("🔍 Long press: Opening Google search for \(poi.name)")
        
        guard let query = poi.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.google.com/search?q=\(query)") else {
            return
        }
        
        #if os(iOS)
        UIApplication.shared.open(url)
        #endif
    }
}

// MARK: - POI Marker Component
struct POIMarker: View {
    let poi: AnnotationModel
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.red)
            
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 10))
                .foregroundColor(.red)
                .offset(y: -5)
        }
    }
}

// MARK: - POI List Item Component
struct POIListItem: View {
    let poi: AnnotationModel
    let index: Int
    
    var body: some View {
        HStack(spacing: 15) {
            // Number badge
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 35, height: 35)
                
                Text("\(index)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // POI info
            VStack(alignment: .leading, spacing: 4) {
                Text(poi.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 11))
                    Text(String(format: "%.4f, %.4f", poi.latitude, poi.longitude))
                        .font(.system(size: 12))
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Place.self, AnnotationModel.self, configurations: config)
    let vm = MainAppViewModel(context: ModelContext(container))
    
    return MapView()
        .environmentObject(vm)
}
