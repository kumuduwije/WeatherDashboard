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
    @State private var selectedPOIID: UUID?
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Interactive Map
            Map(position: $mapPosition) {
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
            
            .frame(maxHeight: .infinity)
            .onAppear {
                updateMapPosition()
            }
            .onChange(of: vm.mapRegion.center.latitude) { _, _ in updateMapPosition() }
            .onChange(of: vm.mapRegion.center.longitude) { _, _ in updateMapPosition() }
            
            // MARK: - POI List
            ZStack(alignment: .top) {
                Image("blue-sky")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: UIScreen.main.bounds.width)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack(spacing: 6) {
//                        Image(systemName: "mappin.and.ellipse")
                        Text("Top 5 Tourist Attractions in \(vm.activePlaceName)")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.7))
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(vm.pois.enumerated()), id: \.element.id) { index, poi in
                                POIListItem(poi: poi, isSelected: selectedPOIID == poi.id)
                                    .onTapGesture {
                                        selectedPOIID = poi.id
                                        handleListItemTap(poi: poi)
                                    }
                            }
                        }
                    }
                }
            }

            .ignoresSafeArea(edges: .bottom)
        }

        .background(Color.white)
    }
    
    private func updateMapPosition() {
        withAnimation(.easeInOut) {
            mapPosition = .region(vm.mapRegion)
        }
    }
    
    private func handlePinTap(poi: AnnotationModel) {
        selectedPOIID = poi.id
        vm.focus(on: poi.coordinate, zoom: 0.005)
        updateMapPosition()
    }
    
    private func handleListItemTap(poi: AnnotationModel) {
        vm.focus(on: poi.coordinate, zoom: 0.02)
        updateMapPosition()
    }
    
    private func handlePinLongPress(poi: AnnotationModel) {
        let searchQuery = "\(poi.name)"
        guard let query = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.google.com/search?q=\(query)") else { return }
        #if os(iOS)
        UIApplication.shared.open(url)
        #endif
    }
}

// MARK: - List Item
struct POIListItem: View {
    let poi: AnnotationModel
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            // Pin Icon Badge
            ZStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 28, height: 28)
                
                Image(systemName: "mappin")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Text(poi.name)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.white)
                .lineLimit(1)
        
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(isSelected ? Color.white.opacity(0.2) : Color.clear)
        .background(
            Divider()
                .background(Color.white.opacity(0.3))
            , alignment: .bottom
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Marker Component
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
                .background(Circle().fill(.white).frame(width: 25, height: 25))
            
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 10))
                .foregroundColor(isPressed ? .orange : .red)
                .offset(y: -5)
        }
        .scaleEffect(isPressed ? 1.2 : 1.0)
        .simultaneousGesture(TapGesture().onEnded { onTap() })
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.8)
                .updating($isPressed) { currentState, gestureState, _ in
                    gestureState = currentState
                }
                .onEnded { _ in onLongPress() }
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Place.self, AnnotationModel.self, configurations: config)
    let vm = MainAppViewModel(context: ModelContext(container))
    
    return MapView()
        .environmentObject(vm)
}
