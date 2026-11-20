import SwiftUI

struct RootView: View {
  var body: some View {
    TabView {
      Tab("Home", systemImage: "house") { Text("Home") }
      Tab("Courses", systemImage: "square.grid.2x2") { CoursesView() }
      Tab("Book", systemImage: "book") { BookView() }
    }
  }
}
