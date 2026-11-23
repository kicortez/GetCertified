import Foundation

protocol CourseRowServiceProtocol {
  func fetchCourses() async throws -> [Course]
}

/// Reads a list of course IDs from a bundled JSON file (for example `popular-courses.json`)
/// and resolves them against the course catalog, keeping the file's order.
struct CourseRowService: CourseRowServiceProtocol {
  let resource: String
  var courseService: CourseServiceProtocol = CourseService()

  func fetchCourses() async throws -> [Course] {
    let ids = try BundledJSON.load([Course.ID].self, from: resource)
    let catalog = try await courseService.fetchCourses()
    let coursesByID = Dictionary(catalog.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    return ids.compactMap { coursesByID[$0] }
  }
}
