//
//  TvShowGeneralInfo.swift
//  TvShows
//
//  Created by Salo Antidze on 3/11/21.
//

import Foundation

struct TvShowInfoResponse: Decodable {
    var results: [TvShowInfo]
}

struct TvShowInfo: Decodable {
    var id: Int
    var first_air_date: String?
    var name: String
    var origin_country: [String]
    var poster_path: String?
    var vote_average: Float
    var vote_count: Int
    var genre_ids: [Int]
    var overview: String
    
}
