import SwiftUI

@main struct GetCertified: App {
  @State private var bookController = BookController(service: BookService())

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(bookController)
        .task { await bookController.fetchCourses() }
    }
  }
}
