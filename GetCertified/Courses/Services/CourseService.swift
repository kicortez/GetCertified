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
    guard let url = Bundle.main.url(forResource: "courses", withExtension: "json") else {
      throw ServiceError.fileNotFound
    }
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode([Course].self, from: data)
  }
}
