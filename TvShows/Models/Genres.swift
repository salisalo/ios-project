//
//  Genres.swift
//  TvShows
//
//  Created by Salo Antidze on 3/16/21.
//

import Foundation

struct GenresResponse: Decodable {
    var genres: [Genres]
}

struct Genres: Decodable {
    var id: Int
    var name: String
}
