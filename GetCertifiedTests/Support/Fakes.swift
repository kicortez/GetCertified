import Foundation
@testable import GetCertified

struct TestError: Error {}

/// A training list service that returns `fetchResult` from `fetch()` and `changeResult` from
/// `add(_:)` and `remove(ids:)`, with no delay.
struct StubTrainingListService: TrainingListServiceProtocol {
  var fetchResult: Result<TrainingList, Error>
  var changeResult: Result<TrainingList, Error>

  func fetch() async throws -> TrainingList { try fetchResult.get() }
  func add(_ item: TrainingListItem) async throws -> TrainingList { try changeResult.get() }
  func remove(ids: Set<TrainingListItem.ID>) async throws -> TrainingList { try changeResult.get() }
}

/// A booking service that records the request it receives.
final class RecordingBookingService: BookingServiceProtocol {
  private(set) var requests: [BookingRequest] = []
  var result: Result<BookingConfirmation, Error> = .success(BookingConfirmation(reference: "GC-TEST01"))

  func submit(_ request: BookingRequest) async throws -> BookingConfirmation {
    requests.append(request)
    return try result.get()
  }
}

/// A course catalog that returns `result` instead of reading `courses.json`.
struct StubCourseService: CourseServiceProtocol {
  var result: Result<[Course], Error>
  func fetchCourses() async throws -> [Course] { try result.get() }
}

struct StubCourseRowService: CourseRowServiceProtocol {
  var result: Result<[Course], Error>
  func fetchCourses() async throws -> [Course] { try result.get() }
}

struct StubHeroBannerService: HeroBannerServiceProtocol {
  var result: Result<HeroBanner, Error>
  func fetchBanner() async throws -> HeroBanner { try result.get() }
}

struct StubTipService: TipServiceProtocol {
  var result: Result<Tip, Error>
  func fetchTipOfTheDay() async throws -> Tip { try result.get() }
}
