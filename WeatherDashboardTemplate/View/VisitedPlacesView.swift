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
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.3),
                    Color.blue.opacity(0.2),
                    Color.indigo.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    
                    Text("Visited Places")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Count badge
                    if !vm.visited.isEmpty {
                        Text("\(vm.visited.count)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 35, height: 35)
                            .background(Circle().fill(Color.blue))
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                
                // MARK: - Places List or Empty State
                if vm.visited.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "map.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("No Saved Places")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Search for a location to get started")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .padding()
                    
                } else {
                    // List of saved places
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(vm.visited) { place in
                                PlaceRow(place: place)
                                    .onTapGesture {
                                        handlePlaceTap(place: place)
                                    }
                                    .onLongPressGesture {
                                        handlePlaceLongPress(place: place)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            handleDelete(place: place)
                                        } label: {
                                            Label("Delete", systemImage: "trash.fill")
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
                
                // MARK: - Instructions Footer
                if !vm.visited.isEmpty {
                    VStack(spacing: 8) {
                        HStack(spacing: 15) {
                            Label("Tap to load", systemImage: "hand.tap.fill")
                            Label("Long press to search", systemImage: "hand.point.up.left.fill")
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        
                        Label("Swipe left to delete", systemImage: "trash.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.1))
                }
            }
        }
    }
    
    // MARK: - Interaction Handlers
    
    /// Handles tap on place - loads place and switches to "Now" tab
    private func handlePlaceTap(place: Place) {
        print("📍 Place tapped: \(place.name)")
        
        Task {
            await vm.loadLocation(fromPlace: place)
            // Show info message directly
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
    
    /// Handles swipe-to-delete
    private func handleDelete(place: Place) {
        print("🗑️ Deleting place: \(place.name)")
        
        withAnimation {
            vm.delete(place: place)
        }
    }
}

// MARK: - Place Row Component
struct PlaceRow: View {
    let place: Place
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Place name
            HStack {
                Image(systemName: "location.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                
                Text(place.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            // Coordinates
            HStack(spacing: 8) {
                Image(systemName: "globe")
                    .font(.system(size: 12))
                
                Text(String(format: "%.2f, %.2f", place.latitude, place.longitude))
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.7))
            
            // Last used timestamp
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                
                Text("Last used: \(formatDate(place.lastUsedAt))")
                    .font(.system(size: 12))
            }
            .foregroundColor(.white.opacity(0.6))
            
            // POI count
            HStack(spacing: 8) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 12))
                
                Text("\(place.annotations.count) attractions saved")
                    .font(.system(size: 12))
            }
            .foregroundColor(.white.opacity(0.6))
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
    }
    
    /// Formats date for display
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Place.self, AnnotationModel.self, configurations: config)
    let vm = MainAppViewModel(context: ModelContext(container))
    
    return VisitedPlacesView()
        .environmentObject(vm)
}
