//
//  ContentView.swift
//  githubApp
//
//  Created by 밀가루 on 7/11/24.
//

import SwiftUI
import Foundation
import Combine

struct ContributionDay: Identifiable, Codable {
    var id: String { date }
    let contributionCount: Int
    let date: String
}

struct Week: Codable {
    let contributionDays: [ContributionDay]
}

struct ContributionCalendar: Codable {
    let totalContributions: Int
    let weeks: [Week]
}

struct ContributionsCollection: Codable {
    let contributionCalendar: ContributionCalendar
}

struct User: Codable {
    let contributionsCollection: ContributionsCollection
}

struct GitHubResponse: Codable {
    let data: DataField
    struct DataField: Codable {
        let user: User
    }
}

class GitHubService: ObservableObject {
    @Published var contributionDays: [ContributionDay] = []
    
    private var cancellable: AnyCancellable?

    func fetchContributions(username: String, token: String) {
        let url = URL(string: "https://api.github.com/graphql")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let query = """
        {
            user(login: "\(username)") {
                contributionsCollection {
                    contributionCalendar {
                        totalContributions
                        weeks {
                            contributionDays {
                                contributionCount
                                date
                            }
                        }
                    }
                }
            }
        }
        """
        
        let body = ["query": query]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: GitHubResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Commit을 가져오는 중 오류 발생: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { response in
                self.contributionDays = response.data.user.contributionsCollection.contributionCalendar.weeks.flatMap { $0.contributionDays }
            })
    }
}

func colorForContributions(_ count: Int) -> Color {
    switch count {
    case 0:
        return Color.gray.opacity(0.2)
    case 1...4:
        return Color.green.opacity(0.4)
    case 5...9:
        return Color.green.opacity(0.6)
    case 10...19:
        return Color.green.opacity(0.8)
    default:
        return Color.green
    }
}

struct ContributionGridView: View {
    let contributionDays: [ContributionDay]
    let rows: [GridItem] = Array(repeating: .init(.fixed(20)), count: 7) // Assuming you want 7 days horizontally

    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows, spacing: 4) {
                ForEach(contributionDays) { day in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorForContributions(day.contributionCount))
                        .frame(width: 20, height: 20)
                        .overlay(Text(day.date).font(.system(size: 6)).foregroundColor(.gray))
                        .accessibility(label: Text("\(day.date): \(day.contributionCount) contributions"))
                }
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var gitHubService = GitHubService()
    let year = Calendar.current.component(.year, from: Date())

    var body: some View {
        NavigationView {
            VStack {
                ContributionGridView(contributionDays: gitHubService.contributionDays)
                    .padding()
                
                List(gitHubService.contributionDays) { day in
                    HStack {
                        Text(day.date)
                        Spacer()
                        Text("\(day.contributionCount)")
                    }
                }
            }
            .navigationTitle("GitHub 쟌디")
            .onAppear {
                let username = "wxxd-fxrest"
                guard let token = readGitHubToken() else {
                    fatalError("토큰 찾을 수 없음")
                }
                gitHubService.fetchContributions(username: username, token: token)
            }
        }
    }
    
    func readGitHubToken() -> String? {
        guard let plistURL = Bundle.main.url(forResource: "APIkey", withExtension: "plist") else {
            fatalError("APIKey.plist 찾을 수 없음")
        }
        
        guard let data = try? Data(contentsOf: plistURL) else {
            fatalError("APIKey.plist 읽지 못 함")
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
    ContentView()
}
