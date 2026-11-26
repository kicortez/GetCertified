import SwiftUI
import UIKit

/// A course's icon, loaded by name from the asset catalog (`Assets.xcassets/icons`).
/// The icons are bundled with the app for simplicity, not downloaded.
/// If the name has no matching asset, it shows a plain tinted tile instead.
struct CourseIcon: View {
  let name: String

  private var hasAsset: Bool { UIImage(named: name) != nil }

  var body: some View {
    Group {
      if hasAsset {
        Image(name)
          .resizable()
          .scaledToFit()
      } else {
        fallback
      }
    }
    .accessibilityHidden(true)
  }

  private var fallback: some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(.tint.quaternary)
      .aspectRatio(1, contentMode: .fit)
      .overlay {
        Image(systemName: "book.closed")
          .foregroundStyle(.tint)
      }
  }
}
