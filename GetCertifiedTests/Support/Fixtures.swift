import Foundation
@testable import GetCertified

extension Course {
  static func fixture(id: String = "course-1", name: String = "Course", hours: Int = 8) -> Course {
    Course(
      id: id, name: name, subtitle: nil, type: .regular, certificationKind: nil,
      category: "macOS", description: "", hours: hours, image: "placeholder")
  }
}

/// A unique file location in the temporary directory, so tests never touch the app's real data.
func temporaryFileURL() -> URL {
  URL.temporaryDirectory
    .appending(path: "GetCertifiedTests-\(UUID().uuidString)")
    .appending(path: "booked-courses.json")
}
