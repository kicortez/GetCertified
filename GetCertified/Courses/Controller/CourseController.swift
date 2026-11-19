import Foundation
import Observation

@MainActor
@Observable
final class CourseController {
  @ObservationIgnored private let service: CourseServiceProtocol
  
  private(set) var courses: [Course] = []
  
  init(service: CourseServiceProtocol) {
    self.service = service
  }
  
  func fetchCourses() async {
    do {
      courses = try await service.fetchCourses()
    } catch {
      print("Failed to fetch courses: \(error)")
    }
  }
}
