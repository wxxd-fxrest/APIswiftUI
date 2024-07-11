//
//  GitHubService.swift
//  githubApp
//
//  Created by 밀가루 on 7/11/24.
//

import Foundation
import Combine

class GitHubService: ObservableObject {
    @Published var contributionDays: [ContributionDay] = []  // 전체 컨트리뷰션 정보 배열
    @Published var todayContributionCount: Int = 0  // 오늘 컨트리뷰션 수

    private var cancellables = Set<AnyCancellable>()  // 데이터 수신 취소 가능 객체들의 집합

    // GitHub API로부터 전체 컨트리뷰션 정보를 가져오는 메서드
    func fetchContributions(username: String, token: String, completion: @escaping () -> Void) {
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

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: GitHubResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("모든 커밋을 가져오는 중 오류 발생: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { response in
                self.contributionDays = response.data.user.contributionsCollection.contributionCalendar.weeks.flatMap { $0.contributionDays }
                print("Contribution Count: \(self.contributionDays)")
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let todayDateString = dateFormatter.string(from: Date())
                
                if let todayContributionDay = self.contributionDays.first(where: { $0.date == todayDateString }) {
                    self.todayContributionCount = todayContributionDay.contributionCount
                    print("Today Contribution Count: \(self.todayContributionCount)")
                } else {
                    print("오늘 커밋 없음")
                }
            })
            .store(in: &cancellables)
    }
}
