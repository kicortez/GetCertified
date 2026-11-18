import SwiftUI

struct RootView: View {
  var body: some View {
    TabView {
      Tab("Home", systemImage: "house") { Text("Home") }
      Tab("Catalog", systemImage: "square.grid.2x2") { Text("Catalog") }
      Tab("Book", systemImage: "book") { Text("Book") }
    }
  }
}

#Preview {
  RootView()
}
