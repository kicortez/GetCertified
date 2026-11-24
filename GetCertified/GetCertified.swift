import SwiftUI

@main struct GetCertified: App {
  @State private var trainingListController = TrainingListController(service: TrainingListService())

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(trainingListController)
        .task { await trainingListController.fetchCourses() }
    }
  }
}
