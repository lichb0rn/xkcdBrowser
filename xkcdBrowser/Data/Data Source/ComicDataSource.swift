import Foundation

protocol ComicDataSource {
    func getComics(fromIndex index: Int, count: Int) async throws -> [Comic]
}

extension ComicDataSource {
    func getComics(fromIndex index: Int) async throws -> [Comic] {
        return try await getComics(fromIndex: index, count: 10)
    }
}
