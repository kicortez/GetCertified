import Foundation
import Testing
@testable import GetCertified

struct TrainingListControllerTests {
  private let controller = TrainingListController(
    service: TrainingListService(fileURL: temporaryFileURL()))

  /// The ids in `.success`, or `nil` for any other state.
  private func loadedIDs(_ controller: TrainingListController) -> [String]? {
    guard case .success(let list) = controller.state else { return nil }
    return list.items.map(\.id)
  }

  @Test func startsLoading() {
    #expect(controller.state == .loading)
  }

  @Test func addSetsTheUpdatedList() async {
    await controller.add(.fixture(id: "a"))

    #expect(loadedIDs(controller) == ["a"])
  }

  @Test func addingTwiceKeepsOneEntry() async {
    await controller.add(.fixture(id: "a"))
    await controller.add(.fixture(id: "a"))

    #expect(loadedIDs(controller) == ["a"])
  }

  @Test func removeOneThenMany() async {
    for id in ["a", "b", "c"] { await controller.add(.fixture(id: id)) }

    await controller.remove(ids: ["b"])
    #expect(loadedIDs(controller) == ["a", "c"])

    await controller.remove(ids: ["a", "c"])
    #expect(loadedIDs(controller) == [])
  }

  @Test func fetchLoadsWhatWasSaved() async throws {
    let fileURL = temporaryFileURL()
    _ = try await TrainingListService(fileURL: fileURL).add(.fixture(id: "saved"))

    let controller = TrainingListController(service: TrainingListService(fileURL: fileURL))
    await controller.fetch()

    #expect(loadedIDs(controller) == ["saved"])
  }

  @Test func fetchSuccessSetsTheList() async {
    let list = TrainingList(items: [.fixture(id: "a")], summary: .zero)
    let controller = TrainingListController(
      service: StubTrainingListService(fetchResult: .success(list), changeResult: .success(list)))

    await controller.fetch()

    #expect(controller.state == .success(list))
  }

  @Test func failedFetchSetsError() async {
    let controller = TrainingListController(
      service: StubTrainingListService(fetchResult: .failure(TestError()), changeResult: .success(.empty)))

    await controller.fetch()

    guard case .error = controller.state else {
      Issue.record("Expected .error, got \(controller.state)")
      return
    }
  }

  @Test func failedChangeSetsError() async {
    let controller = TrainingListController(
      service: StubTrainingListService(fetchResult: .success(.empty), changeResult: .failure(TestError())))
    await controller.fetch()

    await controller.add(.fixture(id: "a"))

    guard case .error = controller.state else {
      Issue.record("Expected .error, got \(controller.state)")
      return
    }
  }

  @Test func changeSuccessRecoversFromFetchError() async {
    let list = TrainingList(items: [.fixture(id: "a")], summary: .zero)
    let controller = TrainingListController(
      service: StubTrainingListService(fetchResult: .failure(TestError()), changeResult: .success(list)))
    await controller.fetch()

    await controller.add(.fixture(id: "a"))

    #expect(controller.state == .success(list))
  }
}
