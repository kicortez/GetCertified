import Foundation

protocol TipServiceProtocol {
  func fetchTipOfTheDay() async throws -> Tip
}

/// Reads the bundled `tips.json` and picks one tip per calendar day.
struct TipService: TipServiceProtocol {
  enum ServiceError: Error {
    case noTips
  }

  var date: Date = .now

  func fetchTipOfTheDay() async throws -> Tip {
    let tips = try BundledJSON.load([Tip].self, from: "tips")
    guard !tips.isEmpty else { throw ServiceError.noTips }
    let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
    return tips[(dayOfYear - 1) % tips.count]
  }
}
