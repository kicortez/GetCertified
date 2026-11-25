import Foundation
import Testing
@testable import GetCertified

struct TrainingListServiceTests {
  private let fileURL = temporaryFileURL()
  private var service: TrainingListService { TrainingListService(fileURL: fileURL) }

  @Test func startsEmptyWhenNothingIsSaved() async throws {
    #expect(try await service.fetchItems().isEmpty)
  }

  @Test func addPersistsAcrossInstances() async throws {
    _ = try await service.add(.fixture(id: "a"))
    _ = try await service.add(.fixture(id: "b"))

    let reloaded = try await TrainingListService(fileURL: fileURL).fetchItems()
    #expect(reloaded.map(\.id) == ["a", "b"])
  }

  @Test func addIgnoresDuplicates() async throws {
    _ = try await service.add(.fixture(id: "a"))
    let items = try await service.add(.fixture(id: "a", name: "Renamed"))

    #expect(items.map(\.id) == ["a"])
    #expect(items.first?.name == "Course")
  }

  @Test func removeDeletesOnlyMatchingIDs() async throws {
    for id in ["a", "b", "c"] { _ = try await service.add(.fixture(id: id)) }

    let items = try await service.remove(ids: ["a", "c", "missing"])

    #expect(items.map(\.id) == ["b"])
    #expect(try await service.fetchItems().map(\.id) == ["b"])
  }

  @Test func unreadableFileStartsEmptyAndIsReplacedOnAdd() async throws {
    try FileManager.default.createDirectory(
      at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try Data(#"[{"id":"old","unexpected":true}]"#.utf8).write(to: fileURL)

    #expect(try await service.fetchItems().isEmpty)

    _ = try await service.add(.fixture(id: "a"))
    #expect(try await service.fetchItems().map(\.id) == ["a"])
  }
}
