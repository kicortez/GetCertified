import Foundation

struct Course: Codable, Identifiable, Hashable {
  enum CourseType: String, Codable {
    case regular
    case certification
  }

  let id: String
  let name: String
  let subtitle: String?
  let type: CourseType
  let certificationKind: String?
  let category: String
  let description: String
  let hours: Int
  let image: String
}
