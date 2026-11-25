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
/// The controller and views don't change.
struct TrainingListService: TrainingListServiceProtocol {
  static let defaultFileURL = URL.applicationSupportDirectory.appending(path: "booked-courses.json")

  /// Product rule: one training day is 8 hours.
  static let hoursPerDay = 8

  /// Where the list is stored. Tests pass a temporary location.
  private let fileURL: URL

  init(fileURL: URL = Self.defaultFileURL) {
    self.fileURL = fileURL
  }

  /// Returns the saved list and its summary.
  func fetch() async throws -> TrainingList {
    makeList(try loadItems())
  }

  /// Adds `item` unless an item with the same id is already saved. Returns the updated list.
  func add(_ item: TrainingListItem) async throws -> TrainingList {
    var items = try loadItems()
    guard !items.contains(where: { $0.id == item.id }) else { return makeList(items) }
    items.append(item)
    try save(items)
    return makeList(items)
  }

  /// Removes every saved item whose id is in `ids`. Returns the updated list.
  func remove(ids: Set<TrainingListItem.ID>) async throws -> TrainingList {
    var items = try loadItems()
    items.removeAll { ids.contains($0.id) }
    try save(items)
    return makeList(items)
  }

  private func makeList(_ items: [TrainingListItem]) -> TrainingList {
    let hours = items.reduce(0) { $0 + $1.hours }
    let summary = TrainingList.Summary(
      count: items.count, hours: hours, days: Double(hours) / Double(Self.hoursPerDay))
    return TrainingList(items: items, summary: summary)
  }

  /// Returns the saved items, or none when nothing is saved yet or the saved file can't be
  /// decoded (for example, one written in an older format). The next change overwrites that file.
  private func loadItems() throws -> [TrainingListItem] {
    guard FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) else { return [] }
    let data = try Data(contentsOf: fileURL)
    do {
      return try JSONDecoder().decode([TrainingListItem].self, from: data)
    } catch let error as DecodingError {
      print("Discarding unreadable training list: \(error)")
      return []
    }
  }

  private func save(_ items: [TrainingListItem]) throws {
    try FileManager.default.createDirectory(
      at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    let data = try JSONEncoder().encode(items)
    try data.write(to: fileURL, options: .atomic)
  }
}
