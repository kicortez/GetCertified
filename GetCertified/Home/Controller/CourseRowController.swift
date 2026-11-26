import Foundation
import Observation

@Observable
final class CourseRowController {
  @ObservationIgnored private let service: CourseRowServiceProtocol

  private(set) var state: LoadState<[Course]> = .loading

  init(service: CourseRowServiceProtocol) {
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
