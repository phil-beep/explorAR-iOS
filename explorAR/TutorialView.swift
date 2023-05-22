//
//  TutorialView.swift
//  explorAR
//
//  Created by Philipp-Michael Handke on 11.04.23.
//

import SwiftUI

struct TutorialView: View {
    @AppStorage("firstStart") private var firstStart = true
    @State var iconSize: CGFloat = 75
    @State var paddingBetween: CGFloat = 20
    @State var horizontalPadding: CGFloat = 50
    
    var body: some View {
        VStack {
            TabView {
                VStack{
                    Image(systemName: "hand.wave").font(.system(size: iconSize))
                        .padding(paddingBetween)
                    Text("Welcome to explorAR!").font(.largeTitle).multilineTextAlignment(.center)
                }
                .padding(.horizontal, horizontalPadding)
                VStack {
                    Image(systemName: "pencil.and.outline").font(.system(size: iconSize))
                        .padding(paddingBetween)
                    Text("Start doodling an animal on the canvas").font(.largeTitle).multilineTextAlignment(.center)
                }
                .padding(.horizontal, horizontalPadding)
                VStack {
                    Image(systemName: "trash").font(.system(size: iconSize))
                        .padding(paddingBetween)
                    Text("Delete your drawing to start over").font(.largeTitle).multilineTextAlignment(.center)
                }
                .padding(.horizontal, horizontalPadding)
                VStack {
                    Image(systemName: "eye.fill").font(.system(size: iconSize))
                        .padding(paddingBetween)
                    Text("Let AI analyze your drawing").font(.largeTitle).multilineTextAlignment(.center)
                }
                .padding(.horizontal, horizontalPadding)
                VStack {
                    Image(systemName: "lightbulb").font(.system(size: iconSize))
                        .padding(paddingBetween)
                    Text("Receive AI generated facts").font(.largeTitle).multilineTextAlignment(.center)
                }
                .padding(.horizontal, horizontalPadding)
                VStack {
                    Image(systemName: "arkit").font(.system(size: iconSize))
                        .padding(paddingBetween)
                    Text("View your animal in Augmented Reality").font(.largeTitle).multilineTextAlignment(.center)
                }
                .padding(.horizontal, horizontalPadding)
                VStack {
                    Image(systemName: "checkmark.circle").font(.system(size: iconSize))
                    Text("You're good to go!").font(.largeTitle).multilineTextAlignment(.center)
                        .padding(paddingBetween)
                    Button("Got it!", action: hideTutorial)
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .cornerRadius(8)
                }
                .padding(.horizontal, horizontalPadding)
                
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
    
    func hideTutorial() {
        firstStart = false
    }
}


struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView()
    }
}
