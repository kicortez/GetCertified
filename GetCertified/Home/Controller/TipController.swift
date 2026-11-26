import Foundation
import Observation

@Observable
final class TipController {
  @ObservationIgnored private let service: TipServiceProtocol

  private(set) var state: LoadState<Tip> = .loading

  init(service: TipServiceProtocol) {
    self.service = service
  }

  func fetchTip() async {
    state = .loading
    do {
      state = .success(try await service.fetchTipOfTheDay())
    } catch {
      state = .error(error.localizedDescription)
    }
  }
}
