////
//  ProfileView.swift
//  Proxy
//
//  Created by user285973 on 2/8/26.
//
 
import SwiftUI
import PhotosUI
 
struct ProfileView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var newPhotoURL: String = ""
    @State private var selectedPhoto: PhotosPickerItem? = nil
 
    private var genericProfileImage: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFill()
            .frame(width: 120, height: 120)
            .foregroundColor(.gray.opacity(0.5))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.orange, lineWidth: 3))
    }
 
    var body: some View {
        VStack(spacing: 20) {
 
            if let urlString = viewModel.currentUser?.profilePicURL, !urlString.isEmpty {
 
                if urlString.hasPrefix("data:image") {
                    if let dataString = urlString.components(separatedBy: ",").last,
                       let imageData = Data(base64Encoded: dataString),
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.orange, lineWidth: 3))
                    } else {
                        genericProfileImage
                    }
 
                } else if let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.orange, lineWidth: 3))
                        case .failure:
                            genericProfileImage
                        case .empty:
                            genericProfileImage
                        @unknown default:
                            genericProfileImage
                        }
                    }
                } else {
                    genericProfileImage
                }
 
            } else {
                genericProfileImage
            }
 
            // User Info
            Text(viewModel.currentUser?.username ?? "Loading...")
                .font(.title2)
                .fontWeight(.bold)
 
            Text(viewModel.currentUser?.email ?? "")
                .foregroundColor(.gray)
 
            Divider()
 
            // Update Photo Section
            VStack(alignment: .leading) {
                Text("Update Profile Photo")
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
 
                HStack {
                    TextField("Paste Image URL here...", text: $newPhotoURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
 
                    // URL upload button
                    Button(action: {
                        Task {
                            await viewModel.updateProfilePic(url: newPhotoURL)
                            newPhotoURL = ""
                        }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.orange)
                    }
                    .disabled(newPhotoURL.isEmpty)
 
                    // Photo picker button
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.orange)
                    }
                    .onChange(of: selectedPhoto) { newValue in
                        guard let newValue else { return }
                        Task {
                            do {
                                if let data = try await newValue.loadTransferable(type: Data.self) {
                                    if let uiImage = UIImage(data: data) {
                                        if let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
                                            let base64String = "data:image/jpeg;base64," + jpegData.base64EncodedString()
                                            await viewModel.updateProfilePic(url: base64String)
                                        }
                                    }
                                }
                            } catch {
                                print("Photo picker error: \(error)")
                            }
                        }
                    }
                }
            }
            .padding()
 
            Spacer()
 
            // Sign Out
            Button(action: {
                viewModel.signOut()
            }) {
                Text("Sign Out")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .navigationTitle("Profile")
    }
}
