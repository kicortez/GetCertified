import SwiftUI

struct HomeView: View {
  private static let placeholderCount = 6

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          heroBanner
          courseRow(title: "Popular Courses")
          courseRow(title: "New Courses")
          tipOfTheDay
        }
        .padding(.vertical, 16)
      }
      .navigationTitle("Home")
    }
  }

  private var heroBanner: some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(Color.accentColor.gradient)
      .frame(height: 180)
      .overlay(alignment: .bottomLeading) {
        VStack(alignment: .leading, spacing: 4) {
          Text("Get Certified").font(.title.bold())
          Text("Level up your skills with our latest trainings.")
            .font(.subheadline)
        }
        .foregroundStyle(.white)
        .padding(16)
      }
      .padding(.horizontal, 16)
  }

  private func courseRow(title: LocalizedStringKey) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionHeader(title)
      ScrollView(.horizontal) {
        LazyHStack(spacing: 12) {
          ForEach(0..<Self.placeholderCount, id: \.self) { _ in
            placeholderCard
          }
        }
        .scrollTargetLayout()
      }
      .scrollIndicators(.hidden)
      .scrollTargetBehavior(.viewAligned)
      .contentMargins(.horizontal, 16, for: .scrollContent)
    }
  }

  private var placeholderCard: some View {
    RoundedRectangle(cornerRadius: 16)
      .fill(.quaternary)
      .frame(width: 160, height: 120)
      .overlay { Text("Course").font(.caption).foregroundStyle(.secondary) }
  }

  private var tipOfTheDay: some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionHeader("Tip of the Day")
      HStack(alignment: .top, spacing: 12) {
        Image(systemName: "lightbulb")
          .font(.title2)
          .foregroundStyle(.yellow)
        Text("Short, focused study sessions beat long cramming before an exam.")
          .font(.body)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(16)
      .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))
      .padding(.horizontal, 16)
    }
  }

  private func sectionHeader(_ title: LocalizedStringKey) -> some View {
    Text(title)
      .font(.title2.bold())
      .padding(.horizontal, 16)
  }
}
