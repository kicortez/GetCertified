import Foundation
import Observation

@Observable
final class HeroBannerController {
  @ObservationIgnored private let service: HeroBannerServiceProtocol

  private(set) var banner: HeroBanner?

  init(service: HeroBannerServiceProtocol) {
    self.service = service
  }

  func fetchBanner() async {
    do {
      banner = try await service.fetchBanner()
    } catch {
      print("Failed to fetch hero banner: \(error)")
    }
  }
}
