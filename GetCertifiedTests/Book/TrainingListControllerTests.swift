import Foundation
import Testing
@testable import GetCertified

struct TrainingListControllerTests {
  private let controller = TrainingListController(
    service: TrainingListService(fileURL: temporaryFileURL()))

  @Test func addAndContains() async {
    let course = Course.fixture(id: "a")
    #expect(!controller.contains(course))

    await controller.add(course)

    #expect(controller.contains(course))
    #expect(controller.courses.map(\.id) == ["a"])
  }

  @Test func addingTwiceKeepsOneEntry() async {
    await controller.add(.fixture(id: "a"))
    await controller.add(.fixture(id: "a"))

    #expect(controller.courses.count == 1)
  }

  @Test func removeSingleAndMany() async {
    for id in ["a", "b", "c"] { await controller.add(.fixture(id: id)) }

    await controller.remove(.fixture(id: "b"))
    #expect(controller.courses.map(\.id) == ["a", "c"])

    await controller.remove(ids: ["a", "c"])
    #expect(controller.courses.isEmpty)
  }

  @Test func fetchLoadsWhatWasSaved() async throws {
    let fileURL = temporaryFileURL()
    _ = try await TrainingListService(fileURL: fileURL).add(.fixture(id: "saved"))

    let controller = TrainingListController(service: TrainingListService(fileURL: fileURL))
    await controller.fetchCourses()

    #expect(controller.courses.map(\.id) == ["saved"])
  }

  @Test func failuresLeaveTheListUnchanged() async {
    let controller = TrainingListController(service: FailingTrainingListService())

    await controller.fetchCourses()
    await controller.add(.fixture())

    #expect(controller.courses.isEmpty)
  }
}
