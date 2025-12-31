//  NavBarView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 19/10/2025.
//

import SwiftUI
import SwiftData

struct NavBarView: View {
    @EnvironmentObject var vm: MainAppViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $vm.selectedTab) {
                CurrentWeatherView()
                    .tabItem { Label("Now", systemImage: "sun.max.fill") }
                    .tag(0)

                ForecastView()
                    .tabItem { Label("Forecast", systemImage: "calendar") }
                    .tag(1)

                MapView()
                    .tabItem { Label("Map", systemImage: "map") }
                    .tag(2)

                VisitedPlacesView()
                    .tabItem { Label("Saved", systemImage: "globe") }
                    .tag(3)
            }
            .accentColor(.blue)
            
            .overlay {
                       if vm.isLoading {
                           ProgressView("Loading…")
                               .padding()
                               .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                       }
                   }
                   
                   // Error Alert (red/warning)
                   .alert(item: $vm.appError) { error in
                       Alert(
                           title: Text("Error"),
                           message: Text(error.localizedDescription),
                           dismissButton: .default(Text("OK"))
                       )
                   }  
                   .alert("Success", isPresented: $vm.showInfoAlert) {
                       Button("OK", role: .cancel) { }
                   } message: {
                       if let message = vm.infoMessage {
                           Text(message)
                       }
                   }
            .ignoresSafeArea(edges: .top)
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Text("Change Location")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    HStack {
                        TextField("Enter New Location", text: $vm.query)
                            .textFieldStyle(.plain)
                            .submitLabel(.search)
                            .onSubmit { vm.submitQuery() }
                        
                        Button {
                            vm.submitQuery()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(4)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.thinMaterial) // Transparent glass effect
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal)
                .padding(.top, 5)
            }
        }
        
        .background(Color.clear)
    }
}
#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    NavBarView()
        .environmentObject(vm)
}
