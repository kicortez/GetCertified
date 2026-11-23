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
          courseRow(title: "Popular Courses", courses: popularController.courses)
          courseRow(title: "New Courses", courses: newController.courses)
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

  private var heroBanner: some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(Color.accentColor.gradient)
      .frame(height: 180)
      .overlay(alignment: .bottomLeading) {
        if let banner = heroController.banner {
          VStack(alignment: .leading, spacing: 4) {
            Text(banner.title).font(.title.bold())
            Text(banner.subtitle).font(.subheadline)
          }
          .foregroundStyle(.white)
          .padding(16)
        }
      }
      .padding(.horizontal, 16)
  }

  private func courseRow(title: LocalizedStringKey, courses: [Course]) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionHeader(title)
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
  }

  private func courseCard(_ course: Course) -> some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(.quaternary)
      .frame(width: 160, height: 120)
      .overlay { Text(course.name).font(.caption).foregroundStyle(.primary) }
  }

  @ViewBuilder
  private var tipOfTheDay: some View {
    if let tip = tipController.tip {
      VStack(alignment: .leading, spacing: 12) {
        sectionHeader("Tip of the Day")
        HStack(alignment: .top, spacing: 12) {
          Image(systemName: "lightbulb")
            .font(.title2)
            .foregroundStyle(.yellow)
          Text(tip.text)
            .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
      }
    }
  }

  private func sectionHeader(_ title: LocalizedStringKey) -> some View {
    Text(title)
      .font(.title2.bold())
      .padding(.horizontal, 16)
  }
}
