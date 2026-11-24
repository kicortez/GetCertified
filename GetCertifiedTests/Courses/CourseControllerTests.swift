import Foundation
import Testing
@testable import GetCertified

struct CourseControllerTests {
  @Test func startsEmpty() {
    let controller = CourseController(service: StubCourseService(result: .success([.fixture()])))
    #expect(controller.courses.isEmpty)
  }

  @Test func fetchPublishesCourses() async {
    let courses: [Course] = [.fixture(id: "a"), .fixture(id: "b")]
    let controller = CourseController(service: StubCourseService(result: .success(courses)))

    await controller.fetchCourses()

    #expect(controller.courses == courses)
  }

  @Test func failedFetchLeavesCoursesEmpty() async {
    let controller = CourseController(service: StubCourseService(result: .failure(TestError())))

    await controller.fetchCourses()

    #expect(controller.courses.isEmpty)
  }
}
