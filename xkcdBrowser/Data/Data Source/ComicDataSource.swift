import Foundation

protocol ComicDataSource {
    func getComics() async throws -> [Comic]
}
