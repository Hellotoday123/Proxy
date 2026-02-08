//
//  MainView.swift
//  Proxy
//
//  Created by user285973 on 2/8/26.
//



import SwiftUI

struct MainView: View {
    // Default to Center (Map) -> Index 1
    @State private var selection = 1
    
    var body: some View {
        TabView(selection: $selection) {
            
            // LEFT SCREEN: Friends & Chat
            ChatListView()
                .tag(0)
            
            // CENTER SCREEN: Map
            MapView()
                .tag(1)
            
            // RIGHT SCREEN: Profile
            ProfileView()
                .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never)) // Swipe enabled, no dots
        .ignoresSafeArea()
    }
}
