import Foundation

/// A training saved in the training list: only the course fields Book displays.
/// Keeping the saved format separate from `Course` means catalog model changes can't break saved lists.
struct TrainingListItem: Codable, Identifiable, Hashable {
  let id: Course.ID
  let name: String
  let subtitle: String?
  let category: String
  let hours: Int
}

extension TrainingListItem {
  init(_ course: Course) {
    self.init(
      id: course.id, name: course.name, subtitle: course.subtitle,
      category: course.category, hours: course.hours)
  }
}
