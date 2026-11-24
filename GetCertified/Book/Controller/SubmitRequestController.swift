import Foundation
import Observation

/// Holds the Submit Request form and drives its submission.
@Observable
final class SubmitRequestController {
  enum Status: Equatable {
    case editing
    case submitting
    case submitted(BookingConfirmation)
    case failed(String)
  }

  @ObservationIgnored private let service: BookingServiceProtocol

  let courses: [Course]

  var name = ""
  var email = ""
  var phone = ""
  var company = ""
  var preferredStartDate: Date
  var notes = ""

  private(set) var status: Status = .editing

  /// The earliest start date the user can pick: tomorrow.
  let earliestStartDate: Date

  init(courses: [Course], service: BookingServiceProtocol, now: Date = .now) {
    self.courses = courses
    self.service = service
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: now)
    earliestStartDate = calendar.date(byAdding: .day, value: 1, to: today) ?? today
    preferredStartDate = calendar.date(byAdding: .day, value: 7, to: today) ?? today
  }

  var totalHours: Int { courses.reduce(0) { $0 + $1.hours } }

  var isEmailValid: Bool {
    let parts = trimmed(email).split(separator: "@")
    return parts.count == 2 && parts[1].contains(".") && !parts[1].hasSuffix(".")
  }

  var canSubmit: Bool {
    status != .submitting && !courses.isEmpty && !trimmed(name).isEmpty && isEmailValid
  }

  /// Sends the request. Returns the confirmation on success so the caller can clear the training list.
  @discardableResult
  func submit() async -> BookingConfirmation? {
    guard canSubmit else { return nil }
    status = .submitting
    do {
      let confirmation = try await service.submit(makeRequest())
      status = .submitted(confirmation)
      return confirmation
    } catch {
      status = .failed(error.localizedDescription)
      return nil
    }
  }

  /// Returns to the form after a failed submission, keeping what the user typed.
  func dismissError() {
    if case .failed = status { status = .editing }
  }

  private func makeRequest() -> BookingRequest {
    BookingRequest(
      courseIDs: courses.map(\.id),
      name: trimmed(name),
      email: trimmed(email),
      phone: trimmed(phone),
      company: trimmed(company),
      preferredStartDate: preferredStartDate,
      notes: trimmed(notes))
  }

  private func trimmed(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
