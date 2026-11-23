import Foundation
import Observation

@Observable
final class TipController {
  @ObservationIgnored private let service: TipServiceProtocol

  private(set) var tip: Tip?

  init(service: TipServiceProtocol) {
    self.service = service
  }

  func fetchTip() async {
    do {
      tip = try await service.fetchTipOfTheDay()
    } catch {
      print("Failed to fetch tip of the day: \(error)")
    }
  }
}
