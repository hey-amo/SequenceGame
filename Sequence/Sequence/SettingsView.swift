//
//  SettingsView.swift
//  Sequence
//
//  Created by Amarjit on 12/11/2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section {
                Text("Sounds")
            }
            Section {
                Text("Visuals")
            }
            Section {
                Text("Reset")
                Button("Reset stats") {
                    // Do something
                }
            }
            Section {
                Text("About")
                Text("Version: 1.0. Nov 2025")
                Text("Author: Amo")
            }
        }
    }
}

#Preview {
    SettingsView()
}
