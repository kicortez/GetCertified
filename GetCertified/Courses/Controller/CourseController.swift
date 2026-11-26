import Foundation
import Observation

@Observable
final class CourseController {
  @ObservationIgnored private let service: CourseServiceProtocol

  private(set) var state: LoadState<[Course]> = .loading

  init(service: CourseServiceProtocol) {
    self.service = service
  }

  func fetchCourses() async {
    state = .loading
    do {
      state = .success(try await service.fetchCourses())
    } catch {
      state = .error(error.localizedDescription)
    }
  }
}
