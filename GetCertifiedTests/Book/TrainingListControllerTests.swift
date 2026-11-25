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
    #expect(controller.items.map(\.id) == ["a"])
  }

  @Test func addingTwiceKeepsOneEntry() async {
    await controller.add(.fixture(id: "a"))
    await controller.add(.fixture(id: "a"))

    #expect(controller.items.count == 1)
  }

  @Test func removeSingleAndMany() async {
    for id in ["a", "b", "c"] { await controller.add(.fixture(id: id)) }

    await controller.remove(TrainingListItem.fixture(id: "b"))
    #expect(controller.items.map(\.id) == ["a", "c"])

    await controller.remove(ids: ["a", "c"])
    #expect(controller.items.isEmpty)
  }

  @Test func fetchLoadsWhatWasSaved() async throws {
    let fileURL = temporaryFileURL()
    _ = try await TrainingListService(fileURL: fileURL).add(.fixture(id: "saved"))

    let controller = TrainingListController(service: TrainingListService(fileURL: fileURL))
    await controller.fetch()

    #expect(controller.items.map(\.id) == ["saved"])
  }

  @Test func failuresLeaveTheListUnchanged() async {
    let controller = TrainingListController(service: FailingTrainingListService())

    await controller.fetch()
    await controller.add(.fixture())

    #expect(controller.items.isEmpty)
  }
}
