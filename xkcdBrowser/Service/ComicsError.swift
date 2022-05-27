import Foundation

enum ComicsError: Error {
    case networkError
    case serverError
    case parseJSONError
    case comicsNumberError
}
