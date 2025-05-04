//
//  ContentView.swift
//  EchocodeTaskTest
//
//  Created by   Kosenko Mykola on 04.05.2025.
//


import SwiftUI

extension Color {
    static let vibrantMint = Color(red: 0.0, green: 0.8, blue: 0.6)
}

struct SettingItem: View {
    var title: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
                .padding(.vertical, 14)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .background(Color(UIColor.systemIndigo).opacity(0.2))
        .cornerRadius(10)
    }
}

struct ContentView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.vibrantMint]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                // Settings header
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                
                // Settings items
                VStack(spacing: 12) {
                    SettingItem(title: "Rate Us")
                    SettingItem(title: "Share App")
                    SettingItem(title: "Contact Us")
                    SettingItem(title: "Restore Purchases")
                    SettingItem(title: "Privacy Policy")
                    SettingItem(title: "Terms of Use")
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Bottom navigation
                HStack(spacing: 50) {
                    VStack {
                        Image(systemName: "character.bubble")
                            .font(.system(size: 24))
                        Text("Translator")
                            .font(.caption)
                    }
                    .foregroundColor(.black)
                    
                    VStack {
                        Image(systemName: "gearshape")
                            .font(.system(size: 24))
                        Text("Clicker")
                            .font(.caption)
                    }
                    .foregroundColor(.black)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(30)
                .padding(.bottom, 30)
                
                // Home indicator
                Rectangle()
                    .frame(width: 130, height: 5)
                    .cornerRadius(2.5)
                    .foregroundColor(.black)
                    .padding(.bottom, 8)
            }
        }
        .statusBar(hidden: false)
    }
}

// Preview
#Preview {
    ContentView()
}
