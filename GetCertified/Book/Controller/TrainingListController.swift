import Foundation
import Observation

@Observable
final class TrainingListController {
  @ObservationIgnored private let service: TrainingListServiceProtocol

  private(set) var list: TrainingList = .empty

  var items: [TrainingListItem] { list.items }
  var summary: TrainingList.Summary { list.summary }

  init(service: TrainingListServiceProtocol) {
    self.service = service
  }

  func fetch() async {
    do {
      list = try await service.fetch()
    } catch {
      print("Failed to fetch training list: \(error)")
    }
  }

  func contains(_ course: Course) -> Bool {
    items.contains { $0.id == course.id }
  }

  func add(_ course: Course) async {
    do {
      list = try await service.add(TrainingListItem(course))
    } catch {
      print("Failed to add course: \(error)")
    }
  }

  func remove(_ item: TrainingListItem) async {
    await remove(ids: [item.id])
  }

  func remove(ids: Set<TrainingListItem.ID>) async {
    do {
      list = try await service.remove(ids: ids)
    } catch {
      print("Failed to remove trainings: \(error)")
    }
  }
}
