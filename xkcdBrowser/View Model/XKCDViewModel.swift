//
//  XKCDViewModel.swift
//  xkcdBrowser
//
//  Created by Miroslav Taleiko on 23.04.2022.
//

import Foundation

class XKCDViewModel: ObservableObject {
    private var currentEndpoint = "https://xkcd.com/info.0.json"
    
    func fetchCurrentComics() async throws -> XKCDComics {
        guard let url = URL(string: currentEndpoint) else {
            throw NetworkError.urlError
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.serverError
        }
        
        return try JSONDecoder().decode(XKCDComics.self, from: data)
    }
}


enum NetworkError: Error {
    case urlError
    case serverError
}
