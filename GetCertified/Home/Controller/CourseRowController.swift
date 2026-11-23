import Foundation
import Observation

@Observable
final class CourseRowController {
  @ObservationIgnored private let service: CourseRowServiceProtocol

  private(set) var courses: [Course] = []

  init(service: CourseRowServiceProtocol) {
    self.service = service
  }

  func fetchCourses() async {
    do {
      courses = try await service.fetchCourses()
    } catch {
      print("Failed to fetch course row: \(error)")
    }
  }
}
