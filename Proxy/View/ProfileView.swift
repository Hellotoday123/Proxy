//
//  ProfileView.swift
//  Proxy
//
//  Created by user285973 on 2/8/26.
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var inputURL = ""
    
    let brandOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Profile Picture
                ZStack {
                    Circle()
                        .stroke(brandOrange, lineWidth: 3)
                        .frame(width: 130, height: 130)
                    
                    AsyncImage(url: URL(string: viewModel.currentUser?.profilePicURL ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .resizable()
                            .padding(30)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                }
                
                // User Info
                VStack(spacing: 5) {
                    Text(viewModel.currentUser?.username ?? "Username")
                        .font(.title)
                        .bold()
                    
                    Text(viewModel.currentUser?.email ?? "email@example.com")
                        .foregroundColor(.gray)
                    
                    Text("ID: \(viewModel.currentUser?.id ?? "Unknown")")
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.top, 5)
                }
                
                Divider()
                    .padding(.horizontal)
                
                // Update Photo Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Update Profile Photo")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        TextField("Paste Image URL", text: $inputURL)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                        
                        Button {
                            Task {
                                await viewModel.updateProfilePic(url: inputURL)
                                inputURL = ""
                            }
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(brandOrange)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Logout
                Button(action: {
                    viewModel.signOut()
                }) {
                    Text("Log Out")
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
}
