//
//  ContentView.swift
//  githubApp
//
//  Created by 밀가루 on 7/11/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CommitView()
                .tabItem {
                    Image(systemName: "square.on.square")
                    Text("쟌디")
                }
                .tag(0)
            
            TodayCommitView()
                .tabItem {
                    Image(systemName: "square.fill")
                    Text("today")
                }
                .tag(1)
        }
    }
}

#Preview {
    ContentView()
}
