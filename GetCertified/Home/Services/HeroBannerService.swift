import Foundation

protocol HeroBannerServiceProtocol {
  func fetchBanner() async throws -> HeroBanner
}

/// Reads the banner from the bundled `hero-banner.json`.
struct HeroBannerService: HeroBannerServiceProtocol {
  func fetchBanner() async throws -> HeroBanner {
    try BundledJSON.load(HeroBanner.self, from: "hero-banner")
  }
}
