import Foundation
import Observation

@Observable
final class HeroBannerController {
  @ObservationIgnored private let service: HeroBannerServiceProtocol

  private(set) var state: LoadState<HeroBanner> = .loading

  init(service: HeroBannerServiceProtocol) {
    self.service = service
  }

  func fetchBanner() async {
    state = .loading
    do {
      state = .success(try await service.fetchBanner())
    } catch {
      state = .error(error.localizedDescription)
    }
  }
}
