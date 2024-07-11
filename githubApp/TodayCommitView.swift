//
//  TodayCommitView.swift
//  githubApp
//
//  Created by 밀가루 on 7/11/24.
//

import SwiftUI

struct ContributionSquareView: View {
    let contributionCount: Int
    let totalCommits: Int = 10

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Image("Group")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width, height: geometry.size.height)

                let segmentHeight = geometry.size.height / 5

                VStack(spacing: 0) {
                    ForEach((0..<(contributionCount / 2)).reversed(), id: \.self) { index in
                        let countPerSegment = (index * 2).clamped(to: 0...totalCommits)
                        let color = Color.blue.opacity(0.6)

                        Rectangle()
                            .fill(color)
                            .frame(height: segmentHeight)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
                .mask(
                    Image("Group")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                )
            }
        }
        .frame(width: 200, height: 200)
    }
}

struct TodayCommitView: View {
    @ObservedObject var gitHubService = GitHubService()

    var body: some View {
        VStack {
            Text("Today Commit: \(gitHubService.todayContributionCount)")
                .padding()
            
            ContributionSquareView(contributionCount: gitHubService.todayContributionCount)
                            .padding()
        }
        .onAppear {
            let username = "wxxd-fxrest"  // GitHub 사용자명
            guard let token = readGitHubToken() else {
                fatalError("토큰을 찾을 수 없음")
            }
            gitHubService.fetchContributions(username: username, token: token) {
                print("모든 커밋을 가져옴")
            }
        }
    }
    
    func readGitHubToken() -> String? {
        guard let plistURL = Bundle.main.url(forResource: "APIkey", withExtension: "plist") else {
            fatalError("APIKey.plist를 찾을 수 없음")
        }

        guard let data = try? Data(contentsOf: plistURL) else {
            fatalError("APIKey.plist를 읽을 수 없음")
        }

        do {
            let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any]
            guard let token = plistData["GitHubKey"] as? String else {
                fatalError("APIKey.plist에서 GitHubKey를 찾을 수 없음")
            }
            return token
        } catch {
            fatalError("APIKey.plist를 읽는 동안 오류 발생: \(error)")
        }
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

#Preview {
    TodayCommitView()
}
