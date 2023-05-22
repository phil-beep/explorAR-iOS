//
//  SettingsView.swift
//  explorAR
//
//  Created by Philipp-Michael Handke on 11.04.23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("firstStart") private var firstStart = true
    var body: some View {
        VStack {
            Divider()
            Link("Show Gallery", destination: URL(string: "https://imgur.com/a/fH0JpoZ")!)
            Divider()
            Button(action: {firstStart = true}) {
                HStack {
                    Image(systemName: "arrow.uturn.backward.circle")
                    Text("Reset App")
                }
                .foregroundColor(.red)
            }
            Divider()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
