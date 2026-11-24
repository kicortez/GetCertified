import Foundation

protocol BookingServiceProtocol {
  func submit(_ request: BookingRequest) async throws -> BookingConfirmation
}

/// Stands in for the training center's booking endpoint.
///
/// Note: this is the point where an actual backend should be connected. For now it waits
/// briefly to mimic a network call and returns a generated reference number.
struct MockBookingService: BookingServiceProtocol {
  enum ServiceError: LocalizedError {
    case unavailable

    var errorDescription: String? {
      "The training center couldn't be reached. Please try again."
    }
  }

  var delay: Duration = .seconds(1)
  var shouldFail = false

  func submit(_ request: BookingRequest) async throws -> BookingConfirmation {
    try await Task.sleep(for: delay)
    if shouldFail { throw ServiceError.unavailable }
    return BookingConfirmation(reference: Self.makeReference())
  }

  private static func makeReference() -> String {
    let characters = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
    let suffix = String((0..<6).compactMap { _ in characters.randomElement() })
    return "GC-\(suffix)"
  }
}
