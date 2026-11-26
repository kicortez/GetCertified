import SwiftUI

struct HomeView: View {
  @State private var heroController = HeroBannerController(service: HeroBannerService())
  @State private var popularController = CourseRowController(
    service: CourseRowService(resource: "popular-courses"))
  @State private var newController = CourseRowController(
    service: CourseRowService(resource: "new-courses"))
  @State private var tipController = TipController(service: TipService())

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          heroBanner
          courseRow(title: "Popular Courses", controller: popularController)
          courseRow(title: "New Courses", controller: newController)
          tipOfTheDay
        }
        .padding(.vertical, 16)
      }
      .navigationDestination(for: Course.self) { course in
        CourseDetailView(course: course)
      }
      .navigationTitle("Home")
      .task { await loadSections() }
    }
  }

  private func loadSections() async {
    async let banner: Void = heroController.fetchBanner()
    async let popular: Void = popularController.fetchCourses()
    async let new: Void = newController.fetchCourses()
    async let tip: Void = tipController.fetchTip()
    _ = await (banner, popular, new, tip)
  }

  // MARK: - Hero banner

  private var heroBanner: some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(Color.accentColor.gradient)
      .frame(height: 180)
      .overlay(alignment: .bottomLeading) { heroContent }
      .padding(.horizontal, 16)
  }

  @ViewBuilder
  private var heroContent: some View {
    switch heroController.state {
    case .loading:
      ProgressView()
        .tint(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    case .success(let banner):
      VStack(alignment: .leading, spacing: 4) {
        Text(banner.title).font(.title.bold())
        Text(banner.subtitle).font(.subheadline)
      }
      .foregroundStyle(.white)
      .padding(16)
    case .error(let message):
      sectionError(message) { await heroController.fetchBanner() }
        .foregroundStyle(.white)
        .tint(.white)
    }
  }

  // MARK: - Course rows

  private func courseRow(title: LocalizedStringKey, controller: CourseRowController) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionHeader(title)
      courseRowContent(controller)
        .frame(minHeight: 120)
    }
  }

  @ViewBuilder
  private func courseRowContent(_ controller: CourseRowController) -> some View {
    switch controller.state {
    case .loading:
      ProgressView()
        .frame(maxWidth: .infinity)
    case .success(let courses) where courses.isEmpty:
      ContentUnavailableView("No Courses", systemImage: "books.vertical")
    case .success(let courses):
      courseScroller(courses)
    case .error(let message):
      sectionError(message) { await controller.fetchCourses() }
    }
  }

  private func courseScroller(_ courses: [Course]) -> some View {
    ScrollView(.horizontal) {
      LazyHStack(spacing: 12) {
        ForEach(courses) { course in
          NavigationLink(value: course) {
            courseCard(course)
          }
          .buttonStyle(.plain)
        }
      }
      .scrollTargetLayout()
    }
    .scrollIndicators(.hidden)
    .scrollTargetBehavior(.viewAligned)
    .contentMargins(.horizontal, 16, for: .scrollContent)
  }

  private func courseCard(_ course: Course) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      CourseIcon(name: course.image)
        .frame(width: 48, height: 48)
      Spacer(minLength: 0)
      Text(course.name)
        .font(.caption.weight(.medium))
        .lineLimit(2)
        .foregroundStyle(.primary)
    }
    .padding(12)
    .frame(width: 160, height: 120, alignment: .leading)
    .background(.tint.quaternary, in: RoundedRectangle(cornerRadius: 16))
  }

  // MARK: - Tip of the day

  private var tipOfTheDay: some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionHeader("Tip of the Day")
      tipContent
    }
  }

  @ViewBuilder
  private var tipContent: some View {
    switch tipController.state {
    case .loading:
      ProgressView()
        .frame(maxWidth: .infinity)
    case .success(let tip):
      tipCard(tip)
    case .error(let message):
      sectionError(message) { await tipController.fetchTip() }
    }
  }

  private func tipCard(_ tip: Tip) -> some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: "lightbulb")
        .font(.title2)
        .foregroundStyle(.tint)
      Text(tip.text)
        .font(.body)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(.tint.quaternary, in: RoundedRectangle(cornerRadius: 16))
    .padding(.horizontal, 16)
  }

  // MARK: - Shared

  private func sectionHeader(_ title: LocalizedStringKey) -> some View {
    Text(title)
      .font(.title2.bold())
      .padding(.horizontal, 16)
  }

  private func sectionError(_ message: String, retry: @escaping () async -> Void) -> some View {
    ContentUnavailableView {
      Label("Couldn't Load", systemImage: "exclamationmark.triangle")
    } description: {
      Text(message)
    } actions: {
      Button("Try Again") {
        Task { await retry() }
      }
      .buttonStyle(.bordered)
    }
  }
}
