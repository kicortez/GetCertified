import SwiftUI

struct CoursesView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var searchText = ""

  private let placeholderItems = (1...12).map { "Placeholder \($0)" }

  private var columns: [GridItem] {
    let count = horizontalSizeClass == .regular ? 3 : 2
    return Array(repeating: GridItem(.flexible(), spacing: 16), count: count)
  }

  private var filteredItems: [String] {
    guard !searchText.isEmpty else { return placeholderItems }
    return placeholderItems.filter { $0.localizedCaseInsensitiveContains(searchText) }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVGrid(columns: columns, spacing: 16) {
          ForEach(filteredItems, id: \.self) { item in
            RoundedRectangle(cornerRadius: 16)
              .fill(.quaternary)
              .aspectRatio(1, contentMode: .fit)
              .overlay { Text(item) }
          }
        }
        .padding(16)
      }
      .searchable(text: $searchText)
      .navigationTitle("Courses")
    }
  }
}

#Preview {
  CoursesView()
}
