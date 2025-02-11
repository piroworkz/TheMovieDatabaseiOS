//
//  RequestBuilder.swift
//  TMDB
//
//  Created by David Luna on 09/02/25.
//

import Foundation

public protocol RequestBuilder {
    func build(for endpoint: String, _ httpMethod: HttpMethod) throws -> URLRequest
}
