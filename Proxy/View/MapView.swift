//
//  MapView.swift
//  Proxy
//
//  Created by user285973 on 2/8/26.
//

//
//  MapView.swift
//  Pulse
//
//  Created by Ping & Kevin
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673), // Montreal
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, showsUserLocation: true)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Text("Swipe Left for Chat | Right for Profile")
                    .font(.caption)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .padding(.bottom, 50)
            }
        }
    }
}
