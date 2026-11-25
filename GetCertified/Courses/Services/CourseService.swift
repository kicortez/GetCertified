import Foundation

protocol CourseServiceProtocol {
  func fetchCourses() async throws -> [Course]
}

struct CourseService: CourseServiceProtocol {
  enum ServiceError: Error {
    case fileNotFound
  }
  
  /// Fetches the list of courses.
  ///
  /// Note: this is also the point where an actual backend service should be
  /// connected to fetch courses. For now it only reads the local `courses.json`.
  func fetchCourses() async throws -> [Course] {
    // Dummy sleep: reading bundled JSON is instant, so this simulates network
    // latency to keep the loading state briefly visible. Remove it when a real
    // backend is connected.
    try await Task.sleep(for: .seconds(1))
    return try BundledJSON.load([Course].self, from: "courses")
  }
}
