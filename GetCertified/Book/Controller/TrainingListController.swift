import Foundation
import Observation

@Observable
final class TrainingListController {
  @ObservationIgnored private let service: TrainingListServiceProtocol

  /// Every service call sets `.loading`, then `.success` with the returned list or `.error`.
  /// Views keep the last `.success` list themselves, so it stays on screen while loading or after an error.
  private(set) var state: LoadState<TrainingList> = .loading

  init(service: TrainingListServiceProtocol) {
    self.service = service
  }

  func fetch() async {
    await load { try await $0.fetch() }
  }

  func add(_ course: Course) async {
    await load { try await $0.add(TrainingListItem(course)) }
  }

  func remove(ids: Set<TrainingListItem.ID>) async {
    await load { try await $0.remove(ids: ids) }
  }

  private func load(_ operation: (TrainingListServiceProtocol) async throws -> TrainingList) async {
    state = .loading
    do {
      state = .success(try await operation(service))
    } catch {
      state = .error(error.localizedDescription)
    }
  }
}
