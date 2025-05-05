//
//  TranslatorView.swift
//  EchocodeTaskTest
//
//  Created by   Kosenko Mykola on 04.05.2025.
//

import SwiftUI
import UIKit

struct TranslatorView: View {
    @StateObject private var viewModel = TranslatorViewModel()
    @State private var translationPhase: TranslationPhase = .idle
    @State private var selectedTab: Tab = .clicker
    @State private var showSettingsAlert = false
    @State private var settingsAlertMessage = ""
    @State private var settingsAlertTitle = ""
    
    enum TranslationPhase {
        case idle, recording, translating, result
    }
    
    enum Tab {
        case translator, clicker
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#F3F5F6"), Color(hex: "#C9FFE0")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 15) {
                if selectedTab == .translator {
                    translatorContent
                } else {
                    settingsContent
                }
                
                // Bottom navigation - updated with exact dimensions
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 5)
                        .frame(width: 216, height: 82)
                    
                    HStack(spacing: 10) {
                        VStack(spacing: 4) {
                            Image(systemName: "translate")
                                .font(.system(size: 22))
                            Text("Translator")
                                .font(.caption2)
                        }
                        .foregroundColor(selectedTab == .translator ? .black : .gray)
                        .frame(width: 90)
                        .onTapGesture {
                            selectedTab = .translator
                        }
                        
                        VStack(spacing: 4) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 22))
                            Text("Clicker")
                                .font(.caption2)
                        }
                        .foregroundColor(selectedTab == .clicker ? .black : .gray)
                        .frame(width: 90)
                        .onTapGesture {
                            selectedTab = .clicker
                        }
                    }
                    .frame(width: 216)
                    .padding(.top, 19)
                    .padding(.bottom, 19)
                }
                .frame(width: 216, height: 82)
                .padding(.bottom, 15)
            }
        }
        .statusBar(hidden: false)
        .overlay(
            Group {
                if viewModel.microphonePermission == .notDetermined && selectedTab == .translator {
                    microphonePermissionView()
                }
            }
        )
        .alert(isPresented: $viewModel.showPermissionAlert) {
            Alert(
                title: Text("Microphone Permission Required"),
                message: Text(viewModel.permissionAlertMessage),
                primaryButton: .default(Text("Open Settings")) {
                    openSettings()
                },
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showSettingsAlert) {
            // Choose alert type based on title to determine if we need settings button
            if settingsAlertTitle == "Rate App" || settingsAlertTitle == "Contact Us" {
                return Alert(
                    title: Text(settingsAlertTitle),
                    message: Text(settingsAlertMessage),
                    primaryButton: .default(Text("Open Settings")) {
                        openSettings()
                    },
                    secondaryButton: .cancel()
                )
            } else {
                return Alert(
                    title: Text(settingsAlertTitle),
                    message: Text(settingsAlertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // MARK: - Translator Content
    private var translatorContent: some View {
        VStack {
            // Header
            if translationPhase == .result {
                // Back button and Result title
                HStack {
                    Button(action: {
                        viewModel.stopRecordingIfNeeded() // Use the new method
                        translationPhase = .idle
                        viewModel.translatedText = "" // Reset translated text
                        viewModel.recordedText = ""   // Reset recorded text
                    }) {
                        Image(systemName: "arrow.left.circle")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Text("Result")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Empty view for alignment
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 30, height: 30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            } else {
                // Regular translator header
                Text("Translator")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 10)
                
                // Translation direction
                ZStack {
                    // Background for the toggle
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 310, height: 61) // As specified
                    
                    HStack(spacing: 8) { // Gap: 8px as specified
                        Text("PET")
                            .fontWeight(viewModel.translationDirection == .petToHuman ? .bold : .regular)
                            .foregroundColor(viewModel.translationDirection == .petToHuman ? .black : .gray)
                            .frame(width: 100) // Fixed width for alignment
                        
                        Button(action: {
                            viewModel.switchTranslationDirection()
                            print("🔍 Direction switched to: \(viewModel.translationDirection)")
                        }) {
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                        }
                        
                        Text("HUMAN")
                            .fontWeight(viewModel.translationDirection == .humanToPet ? .bold : .regular)
                            .foregroundColor(viewModel.translationDirection == .humanToPet ? .black : .gray)
                            .frame(width: 100) // Fixed width for alignment
                    }
                }
                .padding(.top, 80) // Position from top (approximately 150px accounting for safe areas)
                .padding(.bottom, 10)
            }
            
            if translationPhase == .result {
                // Result view with speech bubble
                VStack {
                    // Speech bubble with translation result
                    if viewModel.translatedText.isEmpty {
                        // Fallback text if translation is empty
                        SpeechBubbleView(text: "I'm hungry, feed me!")
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            .padding(.bottom, 30)
                    } else {
                        SpeechBubbleView(text: viewModel.translatedText)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            .padding(.bottom, 30)
                    }
                    
                    Spacer()
                    
                    // Selected pet - adjusted to match position in screenshots
                    selectedPetImage
                        .resizable()
                        .scaledToFit()
                        .frame(height: 170)
                        .padding(.bottom, 100)
                    
                    // New repeat button
                    Button(action: {
                        // Reset the state only without auto-starting recording
                        viewModel.stopRecordingIfNeeded() // Use the new method to ensure recording is stopped
                        translationPhase = .idle
                        viewModel.translatedText = ""
                        viewModel.recordedText = ""
                        
                        // No automatic recording start - user needs to tap the mic button
                    }) {
                        Text("Repeat")
                            .foregroundColor(.black)
                            .font(.system(size: 16, weight: .medium))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 30)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(hex: "#D6DCFF")) // Same color as speech bubble
                                    .frame(width: 120, height: 45)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            )
                    }
                    .padding(.bottom, 50)
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: UUID())
                    
                    Spacer()
                }
            } else if translationPhase == .translating {
                // Translating view with "Process of translation..." text
                VStack(spacing: 0) {
                    Spacer(minLength: 150) // Space at the top
                    
                    // Selected pet image - centered
                    selectedPetImage
                        .resizable()
                        .scaledToFit()
                        .frame(height: 170)
                    
                    // Process of translation text
                    Text("Process of translation...")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .frame(width: 310, height: 22)
                        .padding(.top, 60) // Space between pet and text
                    
                    Spacer() // Space at the bottom
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Main content area for recording
                HStack(spacing: 15) {
                    // Left side - Recording with waveform
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .frame(height: 150)
                            .shadow(color: Color.black.opacity(0.1), radius: 3)
                        
                        VStack {
                            if translationPhase == .recording || translationPhase == .translating {
                                // Waveform visualization with purple lines
                                WaveformView()
                                    .frame(height: 80)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 5)
                                
                                Text("Recording...")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            } else {
                                // Mic button in idle state
                                VStack {
                                    Image(systemName: "mic.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.black)
                                        .padding(.bottom, 5)
                                    
                                    Text("Start Speak")
                                        .font(.caption)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding()
                        .onTapGesture {
                            if translationPhase == .idle {
                                startRecording()
                            }
                        }
                    }
                    
                    // Right side - Pet selector
                    petSelectorView
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 3D Animal image during recording/idle
                selectedPetImage
                    .resizable()
                    .scaledToFit()
                    .frame(height: 130)
                    .scaleEffect(translationPhase == .recording ? 1.05 : 1.0)
                    .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), 
                               value: translationPhase == .recording)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Settings Content
    private var settingsContent: some View {
        VStack(spacing: 0) {
            // Centered Settings title
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
                .padding(.bottom, 20)
            
            ScrollView {
                VStack(spacing: 12) {
                    settingsRow(title: "Rate Us", action: {
                        // Basic implementation - would open App Store in production
                        print("Rate Us tapped")
                        openAppStoreForRating()
                    })
                    
                    settingsRow(title: "Share App", action: {
                        // Basic implementation - would show share sheet in production
                        print("Share App tapped")
                        shareApp()
                    })
                    
                    settingsRow(title: "Contact Us", action: {
                        // Basic implementation - would open email or feedback form
                        print("Contact Us tapped")
                        contactUs()
                    })
                    
                    settingsRow(title: "Restore Purchases", action: {
                        // Basic implementation - would connect to in-app purchase API
                        print("Restore Purchases tapped")
                        restorePurchases()
                    })
                    
                    settingsRow(title: "Privacy Policy", action: {
                        // Basic implementation - would open privacy policy webpage
                        print("Privacy Policy tapped")
                        openPrivacyPolicy()
                    })
                    
                    settingsRow(title: "Terms of Use", action: {
                        // Basic implementation - would open terms webpage
                        print("Terms of Use tapped")
                        openTermsOfUse()
                    })
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
    }
    
    private func settingsRow(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.trailing, 16)
            }
            .frame(height: 50)
            .background(Color(hex: "#D6DCFF")) // Exact color without opacity
            .cornerRadius(12)
        }
    }
    
    // Basic test implementations of settings actions
    private func openAppStoreForRating() {
        // In a real app, this would use StoreKit to open App Store rating
        // For testing, we'll show an alert with option to open settings
        settingsAlertTitle = "Rate App"
        settingsAlertMessage = "This would open device settings where you can rate the app"
        showSettingsAlert = true
    }
    
    private func shareApp() {
        // In production, this would create a UIActivityViewController
        let url = URL(string: "https://apps.apple.com/app/your-app-id")
        guard let url = url else { return }
        
        let activityViewController = UIActivityViewController(
            activityItems: ["Check out this amazing Pet Translator app!", url],
            applicationActivities: nil
        )
        
        // Get the root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
    }
    
    private func contactUs() {
        // Simple implementation - would open mail app or feedback form
        let emailURL = URL(string: "mailto:support@example.com")
        if let url = emailURL, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // Fallback for simulator or if mail isn't configured
            settingsAlertTitle = "Contact Us"
            settingsAlertMessage = "Email client not available. Please contact us at support@example.com"
            showSettingsAlert = true
        }
    }
    
    private func restorePurchases() {
        // Simulate purchase restoration with a delay
        settingsAlertTitle = "Purchases"
        settingsAlertMessage = "Restoring purchases..."
        showSettingsAlert = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            settingsAlertTitle = "Purchases"
            settingsAlertMessage = "Purchases restored successfully!"
            showSettingsAlert = true
        }
    }
    
    private func openPrivacyPolicy() {
        // Open a web URL for privacy policy
        if let url = URL(string: "https://example.com/privacy") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTermsOfUse() {
        // Open a web URL for terms of use
        if let url = URL(string: "https://example.com/terms") {
            UIApplication.shared.open(url)
        }
    }
    
    // Pet selector with dog and cat options
    private var petSelectorView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 3)
                .frame(height: 150)
            
            VStack(spacing: 15) {
                // Cat option
                Button(action: {
                    viewModel.selectedPet = .cat
                }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.selectedPet == .cat 
                                 ? Color(red: 1.0, green: 0.95, blue: 0.7) // Light cream/yellow for cat
                                 : Color.gray.opacity(0.05))
                            .frame(width: 65, height: 65)
                        
                        Image("Cat")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                    }
                }
                
                // Dog option
                Button(action: {
                    viewModel.selectedPet = .dog
                }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.selectedPet == .dog 
                                 ? Color(red: 0.85, green: 0.95, blue: 1.0) // Light blue for dog
                                 : Color.gray.opacity(0.05))
                            .frame(width: 65, height: 65)
                        
                        Image("orangeDog")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                    }
                }
            }
            .padding()
        }
    }
    
    // Helper to get the selected pet image
    private var selectedPetImage: Image {
        viewModel.selectedPet == .dog ? Image("orangeDog") : Image("Cat")
    }
    
    private func startRecording() {
        // Make sure we're in the right state
        if translationPhase != .idle {
            // Don't start recording if not in idle state
            return
        }
        
        print("🔍 VIEW: Starting recording. Direction: \(viewModel.translationDirection)")
        translationPhase = .recording
        
        // Simulate recording for 3 seconds, then show translating
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            print("🔍 VIEW: Recording complete, starting translation")
            translationPhase = .translating
            
            // Make sure we explicitly call translateRecording to process the input
            viewModel.translateRecording()
            
            // Simulate translation completion after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                print("🔍 VIEW: Translation complete. Result: \(viewModel.translatedText)")
                translationPhase = .result
            }
        }
        
        // Trigger the actual recording in the view model
        viewModel.toggleRecording()
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    @ViewBuilder
    private func microphonePermissionView() -> some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("\"App Name\" is asking for permission to access your microphone")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                
                Text("Allow access to your microphone to use the app's features")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                
                Divider()
                
                Button(action: {
                    viewModel.requestMicrophonePermission()
                }) {
                    Text("Allow Access")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                        .padding(.vertical, 12)
                }
                
                Divider()
                
                Button(action: {
                    // Just close the dialog
                    viewModel.microphonePermission = .denied
                }) {
                    Text("Don't Allow")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                        .padding(.vertical, 12)
                }
            }
            .background(Color.white)
            .cornerRadius(15)
            .padding(.horizontal, 40)
        }
    }
}

// Speech bubble view
struct SpeechBubbleView: View {
    let text: String
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main speech bubble with exact specifications
            RoundedRectangle(cornerRadius: 16) // 16px border radius
                .fill(Color(hex: "#D6DCFF")) // Light purple color as specified
                .frame(width: 291, height: 142) // Exact dimensions as specified
                .overlay(
                    Text(text)
                        .foregroundColor(.black)
                        .padding()
                )
            
            // Comics-style tail element positioned at the bottom right - more subtle now
            Path { path in
                // Starting point at the bottom right of the bubble
                let startX: CGFloat = 260 // Bottom right area of bubble
                let startY: CGFloat = 142 // Bottom of bubble
                let angle: CGFloat = 130 // Angle matching the image (diagonal down-right)
                let length: CGFloat = 60 // Significantly reduced length
                let width: CGFloat = 12 // Reduced width of the tail
                
                // Create a tapered tail shape
                let angleRad = angle * .pi / 180
                
                path.move(to: CGPoint(x: startX, y: startY)) // Start at bubble edge
                path.addLine(to: CGPoint(x: startX + width * cos(angleRad - .pi/2), 
                                       y: startY + width * sin(angleRad - .pi/2))) // Width at start
                path.addLine(to: CGPoint(x: startX + length * cos(angleRad) + width/4 * cos(angleRad - .pi/2), 
                                       y: startY + length * sin(angleRad) + width/4 * sin(angleRad - .pi/2))) // Tapered end
                path.addLine(to: CGPoint(x: startX + length * cos(angleRad) - width/4 * cos(angleRad - .pi/2), 
                                       y: startY + length * sin(angleRad) - width/4 * sin(angleRad - .pi/2))) // Tapered end
                path.addLine(to: CGPoint(x: startX - width * cos(angleRad - .pi/2), 
                                       y: startY - width * sin(angleRad - .pi/2))) // Width at start
                path.closeSubpath()
            }
            .fill(Color(hex: "#D6DCFF")) // Same color as bubble
        }
        // Position the bubble correctly
        .padding(.top, 50) // Adjust to help with the 229px top position
    }
}

// Animated waveform visualization
struct WaveformView: View {
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<15, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.purple.opacity(0.7))
                    .frame(width: 3, height: getHeight(for: index))
                    .scaleEffect(y: animating ? randomScale() : 0.3, anchor: .bottom)
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(Double(index) * 0.05),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
    
    private func getHeight(for index: Int) -> CGFloat {
        let baseline: CGFloat = 40
        // Create a rough pattern with higher bars in the middle
        if index > 4 && index < 10 {
            return baseline
        } else {
            return baseline * 0.6
        }
    }
    
    private func randomScale() -> CGFloat {
        return CGFloat.random(in: 0.5...1.0)
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 

