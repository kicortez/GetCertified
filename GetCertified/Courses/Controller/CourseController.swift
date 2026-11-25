import Foundation
import Observation

@Observable
final class CourseController {
  enum State: Equatable {
    case loading
    case success([Course])
    case error(String)
  }

  @ObservationIgnored private let service: CourseServiceProtocol

  private(set) var state: State = .loading

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
