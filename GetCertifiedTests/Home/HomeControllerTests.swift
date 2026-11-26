import Foundation
import Testing
@testable import GetCertified

struct CourseRowControllerTests {
  @Test func startsLoading() {
    let controller = CourseRowController(service: StubCourseRowService(result: .success([.fixture()])))
    #expect(controller.state == .loading)
  }

  @Test func fetchSucceeds() async {
    let courses: [Course] = [.fixture(id: "a"), .fixture(id: "b")]
    let controller = CourseRowController(service: StubCourseRowService(result: .success(courses)))

    await controller.fetchCourses()

    #expect(controller.state == .success(courses))
  }

  @Test func failedFetchSetsError() async {
    let controller = CourseRowController(service: StubCourseRowService(result: .failure(TestError())))

    await controller.fetchCourses()

    guard case .error = controller.state else {
      Issue.record("Expected .error, got \(controller.state)")
      return
    }
  }
}

struct HeroBannerControllerTests {
  @Test func startsLoading() {
    let banner = HeroBanner(title: "Title", subtitle: "Subtitle")
    let controller = HeroBannerController(service: StubHeroBannerService(result: .success(banner)))
    #expect(controller.state == .loading)
  }

  @Test func fetchSucceeds() async {
    let banner = HeroBanner(title: "Title", subtitle: "Subtitle")
    let controller = HeroBannerController(service: StubHeroBannerService(result: .success(banner)))

    await controller.fetchBanner()

    #expect(controller.state == .success(banner))
  }

  @Test func failedFetchSetsError() async {
    let controller = HeroBannerController(service: StubHeroBannerService(result: .failure(TestError())))

    await controller.fetchBanner()

    guard case .error = controller.state else {
      Issue.record("Expected .error, got \(controller.state)")
      return
    }
  }
}

struct TipControllerTests {
  @Test func startsLoading() {
    let tip = Tip(id: "tip", text: "Study daily.")
    let controller = TipController(service: StubTipService(result: .success(tip)))
    #expect(controller.state == .loading)
  }

  @Test func fetchSucceeds() async {
    let tip = Tip(id: "tip", text: "Study daily.")
    let controller = TipController(service: StubTipService(result: .success(tip)))

    await controller.fetchTip()

    #expect(controller.state == .success(tip))
  }

  @Test func failedFetchSetsError() async {
    let controller = TipController(service: StubTipService(result: .failure(TestError())))

    await controller.fetchTip()

    guard case .error = controller.state else {
      Issue.record("Expected .error, got \(controller.state)")
      return
    }
  }
}
