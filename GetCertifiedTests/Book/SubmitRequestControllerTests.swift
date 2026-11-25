import Foundation
import Testing
@testable import GetCertified

struct SubmitRequestControllerTests {
  private let items: [TrainingListItem] = [.fixture(id: "a", hours: 8), .fixture(id: "b", hours: 16)]
  private let service = RecordingBookingService()

  private func makeController(
    items: [TrainingListItem]? = nil, now: Date = .now
  ) -> SubmitRequestController {
    // The controller only passes the summary through to the view, so these tests don't need real totals.
    let list = TrainingList(items: items ?? self.items, summary: .zero)
    return SubmitRequestController(list: list, service: service, now: now)
  }

  private func makeFilledController() -> SubmitRequestController {
    let controller = makeController()
    controller.name = "Juan dela Cruz"
    controller.email = "juan@example.com"
    return controller
  }

  // MARK: - Validation

  @Test func requiresNameAndEmail() {
    let controller = makeController()
    #expect(!controller.canSubmit)

    controller.name = "Juan"
    #expect(!controller.canSubmit)

    controller.email = "juan@example.com"
    #expect(controller.canSubmit)
  }

  @Test func whitespaceOnlyNameIsNotEnough() {
    let controller = makeFilledController()
    controller.name = "   \n"
    #expect(!controller.canSubmit)
  }

  @Test(arguments: ["juan", "juan@", "juan@example", "juan@example.", "a@b@c.com", "@example.com"])
  func rejectsInvalidEmail(_ email: String) {
    let controller = makeFilledController()
    controller.email = email
    #expect(!controller.isEmailValid)
    #expect(!controller.canSubmit)
  }

  @Test(arguments: ["juan@example.com", "  juan@example.com  ", "j.d@mail.example.ph"])
  func acceptsValidEmail(_ email: String) {
    let controller = makeFilledController()
    controller.email = email
    #expect(controller.isEmailValid)
  }

  @Test func cannotSubmitWithoutCourses() {
    let controller = makeController(items: [])
    controller.name = "Juan"
    controller.email = "juan@example.com"
    #expect(!controller.canSubmit)
  }

  // MARK: - Defaults

  @Test func startDatesAreRelativeToToday() throws {
    let calendar = Calendar.current
    let now = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 10, hour: 15)))
    let controller = makeController(now: now)

    let today = calendar.startOfDay(for: now)
    #expect(controller.earliestStartDate == calendar.date(byAdding: .day, value: 1, to: today))
    #expect(controller.preferredStartDate == calendar.date(byAdding: .day, value: 7, to: today))
  }

  // MARK: - Submitting

  @Test func successfulSubmitSendsTrimmedRequest() async {
    let controller = makeFilledController()
    controller.name = "  Juan dela Cruz "
    controller.email = " juan@example.com"
    controller.company = " Acme  "
    controller.notes = "\nMornings, please\n"

    let confirmation = await controller.submit()

    #expect(confirmation == BookingConfirmation(reference: "GC-TEST01"))
    #expect(controller.status == .submitted(BookingConfirmation(reference: "GC-TEST01")))

    let request = service.requests.first
    #expect(service.requests.count == 1)
    #expect(request?.courseIDs == ["a", "b"])
    #expect(request?.name == "Juan dela Cruz")
    #expect(request?.email == "juan@example.com")
    #expect(request?.phone == "")
    #expect(request?.company == "Acme")
    #expect(request?.notes == "Mornings, please")
    #expect(request?.preferredStartDate == controller.preferredStartDate)
  }

  @Test func failedSubmitKeepsInputAndCanReturnToEditing() async {
    service.result = .failure(MockBookingService.ServiceError.unavailable)
    let controller = makeFilledController()

    let confirmation = await controller.submit()

    #expect(confirmation == nil)
    #expect(controller.status == .failed(MockBookingService.ServiceError.unavailable.localizedDescription))

    controller.dismissError()
    #expect(controller.status == .editing)
    #expect(controller.name == "Juan dela Cruz")
    #expect(controller.email == "juan@example.com")
  }

  @Test func invalidFormIsNotSent() async {
    let controller = makeController()

    let confirmation = await controller.submit()

    #expect(confirmation == nil)
    #expect(service.requests.isEmpty)
    #expect(controller.status == .editing)
  }
}
