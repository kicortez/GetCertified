import Foundation
import Observation

@MainActor
@Observable
final class CourseController {
  @ObservationIgnored private let service: CourseserviceProtocol
  
  private(set) var courses: [Course] = []
  
  init(service: CourseserviceProtocol) {
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
