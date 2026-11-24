import Foundation

/// What gets sent to the training center when the user submits their training list.
struct BookingRequest: Codable, Equatable {
  let courseIDs: [Course.ID]
  let name: String
  let email: String
  let phone: String
  let company: String
  let preferredStartDate: Date
  let notes: String
}

/// The training center's acknowledgement of a submitted request.
struct BookingConfirmation: Codable, Equatable {
  let reference: String
}
