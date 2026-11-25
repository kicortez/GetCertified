import Foundation
import Testing
@testable import GetCertified

struct CourseControllerTests {
  @Test func startsLoading() {
    let controller = CourseController(service: StubCourseService(result: .success([.fixture()])))
    #expect(controller.state == .loading)
  }

  @Test func fetchSucceeds() async {
    let courses: [Course] = [.fixture(id: "a"), .fixture(id: "b")]
    let controller = CourseController(service: StubCourseService(result: .success(courses)))

    await controller.fetchCourses()

    #expect(controller.state == .success(courses))
  }

  @Test func failedFetchSetsError() async {
    let controller = CourseController(service: StubCourseService(result: .failure(TestError())))

    await controller.fetchCourses()

    guard case .error = controller.state else {
      Issue.record("Expected .error, got \(controller.state)")
      return
    }
  }
}
