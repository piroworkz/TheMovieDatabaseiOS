//
//  RequestBuilderError.swift
//  TMDB
//
//  Created by David Luna on 09/02/25.
//

enum RequestBuilderError: Error {
    case invalidOrMissingBaseURL
    case missingApiKey
    case malformedURL
}
