import Foundation

protocol TrainingListServiceProtocol {
  func fetchItems() async throws -> [TrainingListItem]
  func add(_ item: TrainingListItem) async throws -> [TrainingListItem]
  func remove(ids: Set<TrainingListItem.ID>) async throws -> [TrainingListItem]
}

struct TrainingListService: TrainingListServiceProtocol {
  static let defaultFileURL = URL.applicationSupportDirectory.appending(path: "booked-courses.json")

  /// Where the list is stored. Tests pass a temporary location.
  private let fileURL: URL

  init(fileURL: URL = Self.defaultFileURL) {
    self.fileURL = fileURL
  }

  /// Returns the saved list, or an empty one when nothing is saved yet or the saved file can't be
  /// decoded (for example, one written in an older format). The next change overwrites that file.
  func fetchItems() async throws -> [TrainingListItem] {
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

  /// Adds `item` unless an item with the same id is already saved. Returns the updated list.
  func add(_ item: TrainingListItem) async throws -> [TrainingListItem] {
    var items = try await fetchItems()
    guard !items.contains(where: { $0.id == item.id }) else { return items }
    items.append(item)
    try save(items)
    return items
  }

  /// Removes every saved item whose id is in `ids`. Returns the updated list.
  func remove(ids: Set<TrainingListItem.ID>) async throws -> [TrainingListItem] {
    var items = try await fetchItems()
    items.removeAll { ids.contains($0.id) }
    try save(items)
    return items
  }
}
