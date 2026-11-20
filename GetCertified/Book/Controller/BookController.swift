import Foundation
import Observation

@Observable
final class BookController {
  @ObservationIgnored private let service: BookServiceProtocol

  private(set) var courses: [Course] = []

  init(service: BookServiceProtocol) {
    self.service = service
  }

  func fetchCourses() async {
    do {
      courses = try await service.fetchSelectedCourses()
    } catch {
      print("Failed to fetch selected courses: \(error)")
    }
  }

  func contains(_ course: Course) -> Bool {
    courses.contains { $0.id == course.id }
  }

  func add(_ course: Course) async {
    do {
      courses = try await service.add(course)
    } catch {
      print("Failed to add course: \(error)")
    }
  }

  func remove(_ course: Course) async {
    await remove(ids: [course.id])
  }

  func remove(ids: Set<Course.ID>) async {
    do {
      courses = try await service.remove(ids: ids)
    } catch {
      print("Failed to remove courses: \(error)")
    }
  }
}
