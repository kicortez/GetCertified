import Foundation
import Testing
@testable import GetCertified

struct TrainingListServiceTests {
  private let fileURL = temporaryFileURL()
  private var service: TrainingListService { TrainingListService(fileURL: fileURL) }

  @Test func startsEmptyWhenNothingIsSaved() async throws {
    #expect(try await service.fetch().items.isEmpty)
  }

  @Test func addPersistsAcrossInstances() async throws {
    _ = try await service.add(.fixture(id: "a"))
    _ = try await service.add(.fixture(id: "b"))

    let reloaded = try await TrainingListService(fileURL: fileURL).fetch().items
    #expect(reloaded.map(\.id) == ["a", "b"])
  }

  @Test func addIgnoresDuplicates() async throws {
    _ = try await service.add(.fixture(id: "a"))
    let list = try await service.add(.fixture(id: "a", name: "Renamed"))

    #expect(list.items.map(\.id) == ["a"])
    #expect(list.items.first?.name == "Course")
  }

  @Test func removeDeletesOnlyMatchingIDs() async throws {
    for id in ["a", "b", "c"] { _ = try await service.add(.fixture(id: id)) }

    let list = try await service.remove(ids: ["a", "c", "missing"])

    #expect(list.items.map(\.id) == ["b"])
    #expect(try await service.fetch().items.map(\.id) == ["b"])
  }

  @Test func summaryTotalsHoursAndDays() async throws {
    #expect(try await service.fetch().summary == .zero)

    _ = try await service.add(.fixture(id: "a", hours: 8))
    _ = try await service.add(.fixture(id: "b", hours: 16))
    let list = try await service.add(.fixture(id: "c", hours: 4))

    #expect(list.summary == TrainingList.Summary(count: 3, hours: 28, days: 3.5))
    #expect(try await service.remove(ids: ["c"]).summary == TrainingList.Summary(count: 2, hours: 24, days: 3))
  }

  @Test func unreadableFileFailsFetchAndIsReplacedOnAdd() async throws {
    try FileManager.default.createDirectory(
      at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try Data(#"[{"id":"old","unexpected":true}]"#.utf8).write(to: fileURL)

    await #expect(throws: TrainingListService.ServiceError.unreadable) {
      try await service.fetch()
    }

    _ = try await service.add(.fixture(id: "a"))
    #expect(try await service.fetch().items.map(\.id) == ["a"])
  }
}
