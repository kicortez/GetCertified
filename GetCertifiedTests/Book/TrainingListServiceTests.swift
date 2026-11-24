import Foundation
import Testing
@testable import GetCertified

struct TrainingListServiceTests {
  private let fileURL = temporaryFileURL()
  private var service: TrainingListService { TrainingListService(fileURL: fileURL) }

  @Test func startsEmptyWhenNothingIsSaved() async throws {
    #expect(try await service.fetchSelectedCourses().isEmpty)
  }

  @Test func addPersistsAcrossInstances() async throws {
    _ = try await service.add(.fixture(id: "a"))
    _ = try await service.add(.fixture(id: "b"))

    let reloaded = try await TrainingListService(fileURL: fileURL).fetchSelectedCourses()
    #expect(reloaded.map(\.id) == ["a", "b"])
  }

  @Test func addIgnoresDuplicates() async throws {
    _ = try await service.add(.fixture(id: "a"))
    let courses = try await service.add(.fixture(id: "a", name: "Renamed"))

    #expect(courses.map(\.id) == ["a"])
    #expect(courses.first?.name == "Course")
  }

  @Test func removeDeletesOnlyMatchingIDs() async throws {
    for id in ["a", "b", "c"] { _ = try await service.add(.fixture(id: id)) }

    let courses = try await service.remove(ids: ["a", "c", "missing"])

    #expect(courses.map(\.id) == ["b"])
    #expect(try await service.fetchSelectedCourses().map(\.id) == ["b"])
  }
}
