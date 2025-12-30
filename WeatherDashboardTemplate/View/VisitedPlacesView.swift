//
//  VisitedPLacesView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData

struct VisitedPlacesView: View {
    @EnvironmentObject var vm: MainAppViewModel
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.3829, green: 0.8343, blue: 0.8365), location: 0.00), // teal (top-left)
                    .init(color: Color(red: 0.5709, green: 0.7104, blue: 0.8430), location: 0.30), // soft blue (middle)
                    .init(color: Color(red: 0.8504, green: 0.7953, blue: 0.9478), location: 1.00)  // lavender (bottom-right)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header with lollipop icon
                HStack(spacing: 8) {
                    Text("Visited Places 📍")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.45))
                    
                    // Lollipop/pin icon
//                    Image(systemName: "mappin")
//                        .font(.system(size: 28, weight: .semibold))
//                        .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.55))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 15)
                
                // MARK: - Places List or Empty State
                if vm.visited.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "map.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.4))
                        
                        Text("No Saved Places")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Text("Search for a location to get started")
                            .font(.system(size: 16))
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .padding()
                    
                } else {
                    // List of saved places
                    List {
                        ForEach(vm.visited) { place in
                            PlaceRowCard(
                                place: place,
                                isActive: isActivePlace(place)
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(
                                top: 0,
                                leading: 0,
                                bottom: 0,
                                trailing: 0
                            ))
                            .onTapGesture {
                                handlePlaceTap(place: place)
                            }
                            .onLongPressGesture {
                                handlePlaceLongPress(place: place)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Helper to Check Active Place
    private func isActivePlace(_ place: Place) -> Bool {
        // Check if this place matches the currently active location
        return place.name.lowercased() == vm.activePlaceName.lowercased()
    }
    
    // MARK: - Delete Handler
    private func deleteItems(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let place = vm.visited[index]
                print("🗑️ Deleting place: \(place.name)")
                vm.delete(place: place)
            }
        }
    }
    
    // MARK: - Interaction Handlers
    
    /// Handles tap on place - loads place and switches to "Now" tab
    private func handlePlaceTap(place: Place) {
        print("📍 Place tapped: \(place.name)")
        
        Task {
            await vm.loadLocation(fromPlace: place)
            // Show info message
            vm.infoMessage = "Loaded \(place.name)"
            vm.showInfoAlert = true
            
            // Switch to "Now" tab
            withAnimation {
                vm.selectedTab = 0
            }
        }
    }
    
    /// Handles long press - opens Google search for location
    private func handlePlaceLongPress(place: Place) {
        print("🔍 Long press: Opening Google search for \(place.name)")
        
        guard let query = place.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.google.com/search?q=\(query)") else {
            return
        }
        
        #if os(iOS)
        UIApplication.shared.open(url)
        #endif
    }
}

// MARK: - Place Row Card Component
struct PlaceRowCard: View {
    let place: Place
    let isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Place name - dark color
            Text(place.name)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color(red: 0.15, green: 0.25, blue: 0.35))
            
            // Coordinates - gray color
            Text("Lat: \(String(format: "%.3f", place.latitude)), Lon: \(String(format: "%.3f", place.longitude))")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(red: 0.45, green: 0.55, blue: 0.6))
            
            // Timestamp - lighter gray
            Text(formatTimestamp(place.lastUsedAt))
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color(red: 0.5, green: 0.6, blue: 0.65))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
        .background(
            isActive
                ? Color(red: 0.45, green: 0.7092, blue: 0.9236)
                : Color.clear
        )
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }
    
    /// Formats timestamp
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy 'at' HH:mm:ss z"
        return formatter.string(from: date)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Place.self, AnnotationModel.self, configurations: config)
    let vm = MainAppViewModel(context: ModelContext(container))
    
    return VisitedPlacesView()
        .environmentObject(vm)
}
