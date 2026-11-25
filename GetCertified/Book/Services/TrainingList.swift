import Foundation

/// The training list together with its totals, as returned by `TrainingListServiceProtocol`.
/// The totals are calculated by the service, so views only format them.
struct TrainingList: Equatable {
  struct Summary: Equatable {
    let count: Int
    let hours: Int
    let days: Double

    static let zero = Summary(count: 0, hours: 0, days: 0)
  }

  let items: [TrainingListItem]
  let summary: Summary

  static let empty = TrainingList(items: [], summary: .zero)
}
