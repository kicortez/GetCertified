import Foundation

/// The state of a controller that loads one value from a service.
///
/// `.loading` is the initial state and is set again at the start of every fetch.
/// `.success` holds the loaded value, and `.error` holds the error's `localizedDescription`.
enum LoadState<Value: Codable> {
  case loading
  case success(Value)
  case error(String)
}

extension LoadState: Equatable where Value: Equatable {}
