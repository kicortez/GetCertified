import SwiftUI

struct BookView: View {
  @Environment(TrainingListController.self) private var controller
  @State private var isPresentingSubmit = false

  private var items: [TrainingListItem] { controller.items }
  private var summary: TrainingList.Summary { controller.summary }

  private var daysText: String {
    summary.days.formatted(.number.precision(.fractionLength(0...1)))
  }

  var body: some View {
    NavigationStack {
      mainContent
        .navigationTitle("Book")
    }
    .sheet(isPresented: $isPresentingSubmit) {
      SubmitRequestView(list: controller.list)
    }
  }

  @ViewBuilder
  private var mainContent: some View {
    if items.isEmpty {
      ContentUnavailableView(
        "No Trainings Added",
        systemImage: "book",
        description: Text("Add trainings from Courses to see them here."))
    } else {
      trainingList
    }
  }

  private var trainingList: some View {
    List {
      Section { summaryRow }
      Section("Selected Trainings") {
        ForEach(items) { item in
          itemRow(item)
        }
        .onDelete { offsets in
          let ids = Set(offsets.map { items[$0].id })
          Task { await controller.remove(ids: ids) }
        }
      }
    }
    .animation(.default, value: items)
    .safeAreaInset(edge: .bottom) { submitButton }
  }

  private var submitButton: some View {
    Button {
      isPresentingSubmit = true
    } label: {
      Text("Submit Request").frame(maxWidth: .infinity)
    }
    .buttonStyle(.borderedProminent)
    .controlSize(.large)
    .padding(16)
    .background(.bar)
  }

  private func itemRow(_ item: TrainingListItem) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(item.name).font(.headline)
      if let subtitle = item.subtitle {
        Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
      }
      Text("\(item.hours) hrs · \(item.category)")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .padding(.vertical, 2)
  }

  private var summaryRow: some View {
    HStack {
      summaryItem(value: "\(summary.count)", label: summary.count == 1 ? "Training" : "Trainings")
      Divider()
      summaryItem(value: daysText, label: summary.days == 1 ? "Day" : "Days")
      Divider()
      summaryItem(value: "\(summary.hours)", label: summary.hours == 1 ? "Hour" : "Hours")
    }
    .padding(.vertical, 4)
  }

  private func summaryItem(value: String, label: LocalizedStringKey) -> some View {
    VStack(spacing: 2) {
      Text(value).font(.title3.bold()).monospacedDigit()
      Text(label).font(.caption).foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
  }
}
