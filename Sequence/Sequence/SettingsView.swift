//
//  SettingsView.swift
//  Sequence
//
//  Created by Amarjit on 12/11/2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Sound") {
                    Toggle("Sound effects", isOn: .constant(true))
                    Toggle("Background music", isOn: .constant(true))
                }
                Section("Display") {
                    Toggle("Dark mode", isOn: .constant(true))
                }
                Section("Game") {
                    Button("Reset game data", role: .destructive) {
                        // Do something
                        showResetAlert = true
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        print("Pressed done")
                    }
                }
            }
            .alert(String(localized: "Confirm Reset Game Data?"), isPresented: $showResetAlert) {
                Button(String(localized: "Cancel"), role: .cancel) { }
                Button(String(localized: "Yes"), role: .destructive) {
                    resetGameData()
                }
            } message: {
                Text(String(localized: "Are you sure?"))
            }
        }
    }

    private func resetGameData() {
        print("Game data reset")
    }
}


#Preview {
    SettingsView()
}

