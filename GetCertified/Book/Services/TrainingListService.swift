import Foundation

protocol TrainingListServiceProtocol {
  func fetchSelectedCourses() async throws -> [Course]
  func save(_ courses: [Course]) throws
  func add(_ course: Course) async throws -> [Course]
  func remove(ids: Set<Course.ID>) async throws -> [Course]
}

struct TrainingListService: TrainingListServiceProtocol {
  static let defaultFileURL = URL.applicationSupportDirectory.appending(path: "booked-courses.json")

  /// Where the list is stored. Tests pass a temporary location.
  private let fileURL: URL

  init(fileURL: URL = Self.defaultFileURL) {
    self.fileURL = fileURL
  }

  func fetchSelectedCourses() async throws -> [Course] {
    guard FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) else { return [] }
    let data = try Data(contentsOf: fileURL)
    return try JSONDecoder().decode([Course].self, from: data)
  }

  func save(_ courses: [Course]) throws {
    try FileManager.default.createDirectory(
      at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    let data = try JSONEncoder().encode(courses)
    try data.write(to: fileURL, options: .atomic)
  }

  /// Adds `course` unless a course with the same id is already saved. Returns the updated list.
  func add(_ course: Course) async throws -> [Course] {
    var courses = try await fetchSelectedCourses()
    guard !courses.contains(where: { $0.id == course.id }) else { return courses }
    courses.append(course)
    try save(courses)
    return courses
  }

  /// Removes every saved course whose id is in `ids`. Returns the updated list.
  func remove(ids: Set<Course.ID>) async throws -> [Course] {
    var courses = try await fetchSelectedCourses()
    courses.removeAll { ids.contains($0.id) }
    try save(courses)
    return courses
  }
}
