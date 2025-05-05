//
//  TranslatorViewModel.swift
//  EchocodeTaskTest
//
//  Created by   Kosenko Mykola on 04.05.2025.
//

import Foundation
import AVFoundation
import SwiftUI
import UIKit

class TranslatorViewModel: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isTranslating = false
    @Published var translationDirection: TranslationDirection = .humanToPet
    @Published var recordedText = ""
    @Published var translatedText = ""
    @Published var microphonePermission: MicrophonePermissionStatus = .notDetermined
    @Published var showPermissionAlert = false
    @Published var permissionAlertMessage = ""
    @Published var selectedPet: PetType = .dog
    
    // Audio session and recorder
    private let audioSession = AVAudioSession.sharedInstance()
    
    // Collection of possible translations
    private let humanToDogTranslations = [
        // Basic greetings and commands
        "hello": "Woof woof! Tail wagging excitedly",
        "hi": "Woof! Arf! Happy bark",
        "hey": "Ruff? Head tilted curiously",
        
        // Questions
        "how are you": "Woof! Woof! Playful bark with tail wag",
        "what's up": "Arf? Ears perked up alertly",
        "are you hungry": "Woof woof woof! Drooling and spinning in circles",
        
        // Commands
        "sit": "Whine... Sits down obediently",
        "stay": "Ruff... Freezes in place, staring intently",
        "come": "Arf arf arf! Runs toward you excitedly",
        "down": "Mmmmm... Lies down, looking up at you",
        "roll over": "Ruff ruff... Rolls onto back with paws in air",
        "shake": "Woof! Offers paw with wagging tail",
        
        // Praise
        "good boy": "Woof woof woof! Tail wagging excitedly",
        "good dog": "Arf arf arf! Happy dance",
        "who's a good boy": "Woof-woof-woof-woof! Uncontrollable excitement",
        
        // Activities
        "food": "WOOF WOOF! Drooling and spinning",
        "treat": "Arf! Arf! Alert posture with intense stare",
        "walk": "WOOF! WOOF! WOOF! Jumps excitedly toward door",
        "play": "Arf arf arf! Brings toy in play bow position",
        "ball": "Woof! Woof! Focused attention in ready stance",
        "outside": "Woof woof woof! Runs to door expectantly",
        
        // Affection
        "i love you": "Woof! Licks face with wagging tail",
        "cuddle": "Mmmmm... Snuggles closer with contented sigh",
        "pet": "Woooof... Leans into your hand happily",
        
        // Default response
        "": "Woof? Tail wag with curious head tilt"
    ]
    
    private let humanToCatTranslations = [
        // Basic greetings
        "hello": "Meow... Indifferent stare",
        "hi": "Mrrp. Slow blink",
        "hey": "Mew? Ear twitch",
        
        // Questions
        "how are you": "Purrrrr... Slow blink",
        "what's up": "Mrow? Looks at ceiling disinterestedly",
        "are you hungry": "Meow! Meow! MEOW! Circles around legs impatiently",
        
        // Commands
        "sit": "Meh. Ignores command while grooming paw",
        "stay": "Mrrrrp. Walks away deliberately",
        "come": "... Stares and pretends not to hear you",
        "jump": "Mew. Looks at target, decides it's not worth the effort",
        
        // Praise
        "good kitty": "Purrrrr... Soft purring",
        "pretty cat": "Mrrp. Preens then acts disinterested",
        "who's a good cat": "Meh. Looks away as if insulted",
        
        // Activities
        "food": "MEOW! MEOW! MEOW! Circles legs urgently",
        "treat": "Meow! Mrrp! Runs to kitchen with immediate attention",
        "play": "Mrrp? Perks ears watching toy intently",
        "toy": "Chirp! Chirp! Pupils dilate in hunting position",
        "laser": "Mrrrrr! Frantic excitement with chattering sounds",
        
        // Affection
        "i love you": "Purrrrrrrrr... Rubs against leg with slow blink",
        "cuddle": "Mrrrrrp... Purrrrrr... Kneads with paws contentedly",
        "pet": "Meow... Purrrr... Arches back into your hand",
        
        // Default response
        "": "Meow. Stares judgmentally"
    ]
    
    private let dogToHumanTranslations = [
        // Basic sounds
        "woof": "I'm hungry, feed me!",
        "bark": "Someone's at the door!",
        "arf": "Hey! Pay attention to me!",
        "ruff": "I want to play now!",
        
        // Vocalizations
        "whine": "I need to go outside, please!",
        "growl": "I'm feeling threatened or uncomfortable",
        "howl": "I'm lonely, play with me!",
        "pant": "I'm hot or excited",
        "sigh": "I'm bored, entertain me",
        
        // Combinations
        "woof woof": "Let's go for a walk, human!",
        "bark bark": "Danger! Something suspicious outside!",
        "whine whine": "Please, I really need something!",
        "howl howl": "I miss you so much!",
        
        // Default response
        "": "I'm hungry, feed me!"
    ]
    
    private let catToHumanTranslations = [
        // Basic sounds
        "meow": "I'm hungry, feed me!",
        "mew": "Pay attention to me, human!",
        "mrow": "Hello, I acknowledge your presence",
        
        // Vocalizations
        "purr": "I'm content with your service",
        "hiss": "Back off, human!",
        "chirp": "I see something interesting",
        "trill": "Hello, I'm happy to see you",
        "yowl": "I'm in distress or very hungry",
        "chatter": "I see prey but can't reach it!",
        
        // Combinations
        "meow meow": "Feed me immediately!",
        "purr purr": "You are being a satisfactory servant",
        "hiss hiss": "I am prepared to attack!",
        "yowl yowl": "This is an emergency!",
        
        // Default response
        "": "I demand your immediate attention, human!"
    ]
    
    enum PetType {
        case dog, cat
    }
    
    enum TranslationDirection {
        case humanToPet
        case petToHuman
        
        mutating func toggle() {
            self = self == .humanToPet ? .petToHuman : .humanToPet
        }
    }
    
    enum MicrophonePermissionStatus {
        case notDetermined
        case denied
        case granted
    }
    
    override init() {
        super.init()
        checkMicrophonePermission()
    }
    
    func checkMicrophonePermission() {
        // Just use the existing API and ignore warnings
        let permission = audioSession.recordPermission
        
        self.microphonePermission = {
            switch permission {
            case .granted: return .granted
            case .denied: return .denied
            default: return .notDetermined
            }
        }()
    }
    
    func requestMicrophonePermission() {
        // Still using requestRecordPermission since there's no clear alternative yet
        audioSession.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.microphonePermission = granted ? .granted : .denied
            }
        }
    }
    
    func toggleRecording() {
        switch microphonePermission {
        case .granted:
            if isRecording {
                // Stop recording
                isRecording = false
                stopRecording()
            } else {
                // Start recording - but only if not already recording
                isRecording = true
                startRecording()
            }
        case .denied:
            // Show alert to direct user to settings
            permissionAlertMessage = "Microphone access denied. Please enable microphone access in Settings."
            showPermissionAlert = true
        case .notDetermined:
            requestMicrophonePermission()
        }
    }
    
    // Add a method to explicitly stop recording
    func stopRecordingIfNeeded() {
        if isRecording {
            isRecording = false
            stopRecording()
        }
    }
    
    private func startRecording() {
        // Instead of actually recording audio, we'll simulate it for this app
        // In a real app, you would set up AVAudioRecorder here
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            // DEBUG - Print current state before recording
            print("🔍 RECORDING START - Direction: \(translationDirection) - Pet: \(selectedPet)")
            
            // Simulate recording with a delay to show UI changes
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                
                // Get all possible phrases from the appropriate dictionary
                if self.translationDirection == .humanToPet {
                    // Human speaking to pet - simulate human speech using dictionary keys
                    let phraseDictionary = self.selectedPet == .dog ? 
                        self.humanToDogTranslations : self.humanToCatTranslations
                    
                    // Get all keys except empty string
                    let allPhrases = phraseDictionary.keys.filter { !$0.isEmpty }
                    let validPhrases = Array(allPhrases)
                    
                    // Select a random phrase
                    if !validPhrases.isEmpty {
                        let randomIndex = Int.random(in: 0..<validPhrases.count)
                        self.recordedText = validPhrases[randomIndex]
                    } else {
                        self.recordedText = "hello" // Fallback
                    }
                    
                    print("🔍 HUMAN->PET: Generated phrase: \(self.recordedText)")
                } else {
                    // Pet speaking to human - simulate pet sounds
                    let soundsDictionary = self.selectedPet == .dog ?
                        self.dogToHumanTranslations : self.catToHumanTranslations
                    
                    // Get all keys except empty string
                    let allSounds = soundsDictionary.keys.filter { !$0.isEmpty }
                    let validSounds = Array(allSounds)
                    
                    // Select a random sound
                    if !validSounds.isEmpty {
                        let randomIndex = Int.random(in: 0..<validSounds.count)
                        self.recordedText = validSounds[randomIndex]
                    } else {
                        self.recordedText = self.selectedPet == .dog ? "woof" : "meow" // Fallback
                    }
                    
                    print("🔍 PET->HUMAN: Generated sound: \(self.recordedText)")
                }
            }
            
        } catch {
            print("Failed to set up recording session: \(error.localizedDescription)")
            isRecording = false
        }
    }
    
    private func stopRecording() {
        // In a real app, you would stop the AVAudioRecorder here
        do {
            try audioSession.setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
        
        // Translate the recording if we have text
        if !recordedText.isEmpty {
            translateRecording()
        }
    }
    
    func translateRecording() {
        isTranslating = true
        
        // DEBUG - Print what we're about to translate
        print("🔍 TRANSLATING: '\(recordedText)' - Direction: \(translationDirection) - Pet: \(selectedPet)")
        
        // Simulate translation with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // Normalize input text (lowercase, trim whitespace)
            let inputText = self.recordedText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            print("🔍 Normalized input: '\(inputText)'")
            
            // Get appropriate translation based on direction and selected pet
            if self.translationDirection == .humanToPet {
                print("🔍 Direction: Human to Pet")
                let translationDictionary = self.selectedPet == .dog ?
                    self.humanToDogTranslations : self.humanToCatTranslations
                
                // Try to find exact match first
                if let exactTranslation = translationDictionary[inputText] {
                    print("🔍 Found exact match: \(exactTranslation)")
                    self.translatedText = exactTranslation
                }
                // If no exact match, look for partial matches
                else if !inputText.isEmpty {
                    let partialMatches = translationDictionary.keys.filter { !$0.isEmpty && inputText.contains($0) }
                    print("🔍 Partial matches: \(partialMatches)")
                    
                    if let bestMatch = partialMatches.sorted(by: { $0.count > $1.count }).first,
                       let translation = translationDictionary[bestMatch] {
                        print("🔍 Using best partial match: \(bestMatch) -> \(translation)")
                        self.translatedText = translation
                    } else {
                        // Use default if no match
                        print("🔍 No match found, using default")
                        self.translatedText = translationDictionary[""] ?? 
                            (self.selectedPet == .dog ? "Woof!" : "Meow...")
                    }
                } else {
                    // Empty input, use default
                    print("🔍 Empty input, using default")
                    self.translatedText = translationDictionary[""] ?? 
                        (self.selectedPet == .dog ? "Woof!" : "Meow...")
                }
            } else {
                print("🔍 Direction: Pet to Human")
                // Pet to human translation
                let translationDictionary = self.selectedPet == .dog ?
                    self.dogToHumanTranslations : self.catToHumanTranslations
                
                // Similar matching logic for pet to human
                if let exactTranslation = translationDictionary[inputText] {
                    print("🔍 Found exact match: \(exactTranslation)")
                    self.translatedText = exactTranslation
                }
                else if !inputText.isEmpty {
                    let partialMatches = translationDictionary.keys.filter { !$0.isEmpty && inputText.contains($0) }
                    print("🔍 Partial matches: \(partialMatches)")
                    
                    if let bestMatch = partialMatches.sorted(by: { $0.count > $1.count }).first,
                       let translation = translationDictionary[bestMatch] {
                        print("🔍 Using best partial match: \(bestMatch) -> \(translation)")
                        self.translatedText = translation
                    } else {
                        // Use default if no match
                        print("🔍 No match found, using default")
                        self.translatedText = translationDictionary[""] ?? "I'm hungry, feed me!"
                    }
                } else {
                    // Empty input, use default
                    print("🔍 Empty input, using default")
                    self.translatedText = translationDictionary[""] ?? "I'm hungry, feed me!"
                }
            }
            
            print("🔍 FINAL TRANSLATION: \(self.translatedText)")
            self.isTranslating = false
        }
    }
    
    func switchTranslationDirection() {
        translationDirection.toggle()
        recordedText = ""
        translatedText = ""
    }
    
    deinit {
        // Clean up when view model is deallocated
        do {
            try audioSession.setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
} 
