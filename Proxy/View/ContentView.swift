//
//  ContentView.swift
//  Proxy
//
//  Created by Kevin Alinazar on 2026-02-05.
//


import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = AppViewModel()
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                MainView()
                    .environmentObject(viewModel)
            } else {
                AuthView()
                    .environmentObject(viewModel)
            }
        }
    }
}
