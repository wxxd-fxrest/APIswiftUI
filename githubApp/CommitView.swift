//
//  CommitView.swift
//  githubApp
//
//  Created by 밀가루 on 7/11/24.
//

import SwiftUI
import Foundation
import Combine

// 컨트리뷰션 수에 따른 컬러 반환 함수
func colorForContributions(_ count: Int) -> Color {
    switch count {
    case 0:
        return Color.gray.opacity(0.2)  // 컨트리뷰션이 없는 경우
    case 1...4:
        return Color.green.opacity(0.4)  // 1~4 회 컨트리뷰션
    case 5...9:
        return Color.green.opacity(0.6)  // 5~9 회 컨트리뷰션
    case 10...19:
        return Color.green.opacity(0.8)  // 10~19 회 컨트리뷰션
    default:
        return Color.green  // 20 회 이상의 컨트리뷰션
    }
}

// 컨트리뷰션을 그리는 그리드 뷰
struct ContributionGridView: View {
    let contributionDays: [ContributionDay]  // 컨트리뷰션 정보 배열
    let rows: [GridItem] = Array(repeating: .init(.fixed(20)), count: 7)  // 7일간의 그리드 레이아웃
    
    var body: some View {
        ScrollView(.horizontal) {  // 가로 스크롤 뷰
            LazyHGrid(rows: rows, spacing: 4) {
                ForEach(contributionDays) { day in
                    RoundedRectangle(cornerRadius: 4)  // 둥근 사각형
                        .fill(colorForContributions(day.contributionCount))  // 컨트리뷰션 수에 따른 색상
                        .frame(width: 20, height: 20)  // 프레임 설정
                        .overlay(Text(day.date).font(.system(size: 6)).foregroundColor(.gray))  // 날짜 텍스트
                        .accessibility(label: Text("\(day.date): \(day.contributionCount) contributions"))  // 접근성 레이블
                }
            }
        }
    }
}

// 메인 뷰 - GitHubService를 관찰하고 컨트리뷰션 정보를 표시
struct CommitView: View {
    @ObservedObject var gitHubService = GitHubService()  // GitHub 서비스 객체
    let year = Calendar.current.component(.year, from: Date())  // 현재 연도 구하기
    
    var body: some View {
        NavigationView {  // 내비게이션 뷰
            VStack {
                ContributionGridView(contributionDays: gitHubService.contributionDays)  // 그리드 뷰
                    .padding()  // 패딩 추가
                
                List(gitHubService.contributionDays) { day in
                    HStack {
                        Text(day.date)  // 날짜 표시
                        Spacer()  // 공간 추가
                        Text("\(day.contributionCount)")  // 컨트리뷰션 수 표시
                    }
                }
            }
            .navigationTitle("GitHub 쟌디")  // 내비게이션 타이틀 설정
            .onAppear {
                let username = "wxxd-fxrest"  // GitHub 사용자명
                guard let token = readGitHubToken() else {
                    fatalError("토큰을 찾을 수 없음")
                }
                // 컨트리뷰션 데이터 가져오기
                gitHubService.fetchContributions(username: username, token: token) {
                    // Completion handler: You can perform additional actions after fetching contributions
                    print("All contributions fetched.")
                }
            }
        }
    }
    
    // GitHub API 토큰을 읽어오는 함수
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

#Preview {
    CommitView()
}
