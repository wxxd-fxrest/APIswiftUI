//
//  GitHubModel.swift
//  githubApp
//
//  Created by 밀가루 on 7/11/24.
//

import Foundation

// GitHub API에서 받아오는 일일 컨트리뷰션 정보를 표현하는 구조체
struct ContributionDay: Identifiable, Codable {
    var id: String { date }
    let contributionCount: Int  // 해당 날짜의 컨트리뷰션 수
    let date: String  // 날짜
}

// 한 주 동안의 컨트리뷰션 정보를 포함하는 구조체
struct Week: Codable {
    let contributionDays: [ContributionDay]  // 한 주 동안의 일일 컨트리뷰션 정보 배열
}

// 전체 컨트리뷰션 카운트와 주별 정보를 포함하는 구조체
struct ContributionCalendar: Codable {
    let totalContributions: Int  // 전체 컨트리뷰션 수
    let weeks: [Week]  // 주별 컨트리뷰션 정보 배열
}

// GitHub 사용자의 컨트리뷰션 정보를 포함하는 구조체
struct ContributionsCollection: Codable {
    let contributionCalendar: ContributionCalendar  // 컨트리뷰션 캘린더 정보
}

// GitHub API 응답에서 추출하는 사용자 정보 구조체
struct User: Codable {
    let contributionsCollection: ContributionsCollection  // 사용자의 컨트리뷰션 모음 정보
}

// GitHub API 전체 응답을 처리하는 구조체
struct GitHubResponse: Codable {
    let data: DataField

    struct DataField: Codable {
        let user: User  // 사용자 정보
    }
}
