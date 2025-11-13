//
//  HowToPlayView.swift
//  Sequence
//
//  Created by Amarjit on 13/11/2025.
//

import SwiftUI


struct HowToPlayView: View {
    
    var body: some View {
        VStack(spacing: 16) {
            Text(String(localized: "How to Play"))
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            ScrollView {
                VStack(spacing: 12) {
                    MiniCard2(icon: "steps", title: String(localized: "Connect the dots")) {
                        Text(String(localized: "Connect the numbers in order"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    MiniCard2(icon: "grid", title: String(localized: "Fill the square")) {
                        Text(String(localized: "Fill every square"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                    }
                    MiniCard(icon: "✅", title: String(localized: "Beat your score")) {
                        Text(String(localized: "Try to beat your best score!"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            
            Spacer(minLength: 8)
            
            /// Footer button - TBC
            Button {
                print("Let's play tapped")
            } label: {
                Text(String(localized: "Let's Play"))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding([.horizontal, .bottom])
        }
    }
}

struct MiniCard2<Content: View>: View {
    let icon: String
    let title: String
    let content: Content

    init(icon: String, title: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.content = content()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(icon)
                .resizable()
                .frame(width: 60, height: 40)
          
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                content
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

struct MiniCard<Content: View>: View {
    let icon: String
    let title: String
    let content: Content

    init(icon: String, title: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.content = content()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(icon)
                .font(.title2)
                .frame(width: 60, height: 36)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                content
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    HowToPlayView()
}

