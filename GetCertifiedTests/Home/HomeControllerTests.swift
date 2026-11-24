import Foundation
import Testing
@testable import GetCertified

struct CourseRowControllerTests {
  @Test func fetchPublishesCourses() async {
    let courses: [Course] = [.fixture(id: "a"), .fixture(id: "b")]
    let controller = CourseRowController(service: StubCourseRowService(result: .success(courses)))

    await controller.fetchCourses()

    #expect(controller.courses == courses)
  }

  @Test func failedFetchLeavesRowEmpty() async {
    let controller = CourseRowController(service: StubCourseRowService(result: .failure(TestError())))

    await controller.fetchCourses()

    #expect(controller.courses.isEmpty)
  }
}

struct HeroBannerControllerTests {
  @Test func fetchPublishesBanner() async {
    let banner = HeroBanner(title: "Title", subtitle: "Subtitle")
    let controller = HeroBannerController(service: StubHeroBannerService(result: .success(banner)))
    #expect(controller.banner == nil)

    await controller.fetchBanner()

    #expect(controller.banner == banner)
  }

  @Test func failedFetchLeavesBannerNil() async {
    let controller = HeroBannerController(service: StubHeroBannerService(result: .failure(TestError())))

    await controller.fetchBanner()

    #expect(controller.banner == nil)
  }
}

struct TipControllerTests {
  @Test func fetchPublishesTip() async {
    let tip = Tip(id: "tip", text: "Study daily.")
    let controller = TipController(service: StubTipService(result: .success(tip)))
    #expect(controller.tip == nil)

    await controller.fetchTip()

    #expect(controller.tip == tip)
  }

  @Test func failedFetchLeavesTipNil() async {
    let controller = TipController(service: StubTipService(result: .failure(TestError())))

    await controller.fetchTip()

    #expect(controller.tip == nil)
  }
}
