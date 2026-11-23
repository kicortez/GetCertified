import Foundation

/// Decodes a JSON file bundled with the app, the same way `CourseService` reads `courses.json`.
enum BundledJSON {
  enum LoadError: Error {
    case fileNotFound(String)
  }

  static func load<T: Decodable>(_ type: T.Type, from resource: String) throws -> T {
    guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
      throw LoadError.fileNotFound(resource)
    }
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(T.self, from: data)
  }
}
