import Foundation

protocol TrainingListServiceProtocol {
  func fetch() async throws -> TrainingList
  func add(_ item: TrainingListItem) async throws -> TrainingList
  func remove(ids: Set<TrainingListItem.ID>) async throws -> TrainingList
}

/// Stores the training list on the device and applies the cart rules: no duplicates, removal by ID,
/// and the summary totals (count, hours, and days at `hoursPerDay`).
///
/// This is the integration point for a backend. The rules and the summary calculation live here,
/// not in the controller or views, so a backend service can take them over by implementing
/// `TrainingListServiceProtocol` and returning a `TrainingList` with server-calculated totals.
/// The controller and views don't change. Failures are reported the way a backend would report
/// them: as a `ServiceError` with a message the user can read.
struct TrainingListService: TrainingListServiceProtocol {
  enum ServiceError: LocalizedError, Equatable {
    /// The saved list couldn't be read or decoded.
    case unreadable
    /// A change couldn't be written.
    case saveFailed

    var errorDescription: String? {
      switch self {
      case .unreadable: "Your training list couldn't be loaded."
      case .saveFailed: "Your change couldn't be saved. Please try again."
      }
    }
  }

  static let defaultFileURL = URL.applicationSupportDirectory.appending(path: "booked-courses.json")

  /// Product rule: one training day is 8 hours.
  static let hoursPerDay = 8

  /// Where the list is stored. Tests pass a temporary location.
  private let fileURL: URL

  init(fileURL: URL = Self.defaultFileURL) {
    self.fileURL = fileURL
  }

  /// Returns the saved list and its summary. Throws `ServiceError.unreadable` if the saved file
  /// can't be read or decoded.
  func fetch() async throws -> TrainingList {
    try await simulateLatency()
    return makeList(try loadItems(discardingUnreadable: false))
  }

  /// Adds `item` unless an item with the same id is already saved. Returns the updated list.
  func add(_ item: TrainingListItem) async throws -> TrainingList {
    try await simulateLatency()
    var items = try loadItems(discardingUnreadable: true)
    guard !items.contains(where: { $0.id == item.id }) else { return makeList(items) }
    items.append(item)
    try save(items)
    return makeList(items)
  }

  /// Removes every saved item whose id is in `ids`. Returns the updated list.
  func remove(ids: Set<TrainingListItem.ID>) async throws -> TrainingList {
    try await simulateLatency()
    var items = try loadItems(discardingUnreadable: true)
    items.removeAll { ids.contains($0.id) }
    try save(items)
    return makeList(items)
  }

  /// Dummy sleep: reading a local file is instant, so this simulates network latency to keep
  /// the loading state briefly visible. Remove it when a real backend is connected.
  private func simulateLatency() async throws {
    try await Task.sleep(for: .seconds(1))
  }

  private func makeList(_ items: [TrainingListItem]) -> TrainingList {
    let hours = items.reduce(0) { $0 + $1.hours }
    let summary = TrainingList.Summary(
      count: items.count, hours: hours, days: Double(hours) / Double(Self.hoursPerDay))
    return TrainingList(items: items, summary: summary)
  }

  /// Returns the saved items, or none when nothing is saved yet.
  ///
  /// An unreadable file (for example, one written in an older format) throws
  /// `ServiceError.unreadable`. Changes pass `discardingUnreadable: true` to start from an empty
  /// list instead and overwrite the file, so a bad file can't block the training list for good.
  private func loadItems(discardingUnreadable: Bool) throws -> [TrainingListItem] {
    guard FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) else { return [] }
    do {
      let data = try Data(contentsOf: fileURL)
      return try JSONDecoder().decode([TrainingListItem].self, from: data)
    } catch {
      if discardingUnreadable { return [] }
      throw ServiceError.unreadable
    }
  }

  private func save(_ items: [TrainingListItem]) throws {
    do {
      try FileManager.default.createDirectory(
        at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
      let data = try JSONEncoder().encode(items)
      try data.write(to: fileURL, options: .atomic)
    } catch {
      throw ServiceError.saveFailed
    }
  }
}
