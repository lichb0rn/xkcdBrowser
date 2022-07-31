import Foundation

enum NetworkError: Error {
    case noInternet
    case badServerResponse
    case parseJSONError
}
