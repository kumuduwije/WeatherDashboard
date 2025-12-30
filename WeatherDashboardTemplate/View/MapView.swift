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
    @State private var mapPosition: MapCameraPosition = .automatic
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Interactive Map
            Map(position: $mapPosition) {
                // Add annotations for all POIs
                ForEach(vm.pois) { poi in
                    Annotation(poi.name, coordinate: poi.coordinate) {
                        POIMarkerWithGesture(
                            poi: poi,
                            onTap: { handlePinTap(poi: poi) },
                            onLongPress: { handlePinLongPress(poi: poi) }
                        )
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .frame(height: 350)
            .onAppear {
                updateMapPosition()
            }
            .onChange(of: vm.mapRegion.center.latitude) { _, _ in
                updateMapPosition()
            }
            .onChange(of: vm.mapRegion.center.longitude) { _, _ in
                updateMapPosition()
            }
            
            // MARK: - POI List with Blue Sky Background
            ZStack {
                // Background image
                Image("blue-sky")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 0) {
                    // Header with blue background
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                        Text("Top 5 Tourist Attractions in \(vm.activePlaceName)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.7))
                    
                    // Scrollable list of POIs with  background image
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(Array(vm.pois.enumerated()), id: \.element.id) { index, poi in
                                POIListItem(poi: poi, index: index + 1)
                                    .onTapGesture {
                                        handleListItemTap(poi: poi)
                                    }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    }
                    
                    // Empty state
                    if vm.pois.isEmpty {
                        VStack(spacing: 15) {
                            Image(systemName: "map")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.7))
                            Text("No tourist attractions found")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            Text("Try searching for a different location")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - Helper Methods
    
    private func updateMapPosition() {
        mapPosition = .region(vm.mapRegion)
    }
    
    // MARK: - Interaction Handlers
    
    private func handlePinTap(poi: AnnotationModel) {
        print("📍 Pin tapped: \(poi.name)")
        vm.focus(on: poi.coordinate, zoom: 0.005)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            updateMapPosition()
        }
    }
    
    private func handleListItemTap(poi: AnnotationModel) {
        print("📋 List item tapped: \(poi.name)")
        vm.focus(on: poi.coordinate, zoom: 0.02)
        
        withAnimation(.easeInOut(duration: 0.5)) {
            updateMapPosition()
        }
    }
    
    private func handlePinLongPress(poi: AnnotationModel) {
        print("🔍 LONG PRESS DETECTED on PIN: \(poi.name)")
        
        let searchQuery = "\(poi.name) tourist attraction"
        
        guard let query = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.google.com/search?q=\(query)") else {
            print("❌ Failed to create URL for: \(poi.name)")
            return
        }
        
        print("✅ Opening URL: \(url.absoluteString)")
        
        #if os(iOS)
        UIApplication.shared.open(url) { success in
            if success {
                print("✅ Browser opened successfully")
            } else {
                print("❌ Failed to open browser")
            }
        }
        #endif
    }
}

// MARK: - POI Marker with Proper Gesture Handling
struct POIMarkerWithGesture: View {
    let poi: AnnotationModel
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    @GestureState private var isPressed = false
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(isPressed ? .orange : .red)
            
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 10))
                .foregroundColor(isPressed ? .orange : .red)
                .offset(y: -5)
        }
        .scaleEffect(isPressed ? 1.2 : 1.0)
        .simultaneousGesture(
            // Tap gesture
            TapGesture()
                .onEnded { _ in
                    print("👆Tap gesture detected")
                    onTap()
                }
        )
        .simultaneousGesture(
            // Long press gesture
            LongPressGesture(minimumDuration: 0.8)
                .updating($isPressed) { currentState, gestureState, _ in
                    gestureState = currentState
                }
                .onEnded { _ in
                    print("Long press gesture finised!")
                    onLongPress()
                }
        )
    }
}

// MARK: - POI List Item Component
struct POIListItem: View {
    let poi: AnnotationModel
    let index: Int
    
    var body: some View {
        HStack(spacing: 10) {
            // Orange circular number badge
            ZStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 32, height: 32)
                
                Text("\(index)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // POI name
            Text(poi.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.2))
        )
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
