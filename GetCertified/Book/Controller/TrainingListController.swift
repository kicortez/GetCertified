import Foundation
import Observation

@Observable
final class TrainingListController {
  @ObservationIgnored private let service: TrainingListServiceProtocol

  private(set) var items: [TrainingListItem] = []

  init(service: TrainingListServiceProtocol) {
    self.service = service
  }

  func fetchItems() async {
    do {
      items = try await service.fetchItems()
    } catch {
      print("Failed to fetch training list: \(error)")
    }
  }

  func contains(_ course: Course) -> Bool {
    items.contains { $0.id == course.id }
  }

  func add(_ course: Course) async {
    do {
      items = try await service.add(TrainingListItem(course))
    } catch {
      print("Failed to add course: \(error)")
    }
  }

  func remove(_ item: TrainingListItem) async {
    await remove(ids: [item.id])
  }

  func remove(ids: Set<TrainingListItem.ID>) async {
    do {
      items = try await service.remove(ids: ids)
    } catch {
      print("Failed to remove trainings: \(error)")
    }
  }
}
