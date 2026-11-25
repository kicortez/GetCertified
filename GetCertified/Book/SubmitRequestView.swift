import SwiftUI

/// Collects contact details and a preferred schedule, then sends the training list to the training center.
struct SubmitRequestView: View {
  @Environment(TrainingListController.self) private var trainingListController
  @Environment(\.dismiss) private var dismiss
  @State private var controller: SubmitRequestController

  init(items: [TrainingListItem], service: BookingServiceProtocol = MockBookingService()) {
    _controller = State(initialValue: SubmitRequestController(items: items, service: service))
  }

  private var isSubmitting: Bool { controller.status == .submitting }

  private var confirmation: BookingConfirmation? {
    if case .submitted(let confirmation) = controller.status { return confirmation }
    return nil
  }

  private var errorMessage: String? {
    if case .failed(let message) = controller.status { return message }
    return nil
  }

  private var isShowingError: Binding<Bool> {
    Binding(
      get: { errorMessage != nil },
      set: { if !$0 { controller.dismissError() } })
  }

  private var showsEmailHint: Bool {
    !controller.email.isEmpty && !controller.isEmailValid
  }

  var body: some View {
    NavigationStack {
      Group {
        if let confirmation {
          confirmationView(confirmation)
        } else {
          form
        }
      }
      .navigationBarTitleDisplayMode(.inline)
    }
    .interactiveDismissDisabled(isSubmitting)
  }

  // MARK: - Form

  private var form: some View {
    Form {
      trainingsSection
      contactSection
      scheduleSection
    }
    .disabled(isSubmitting)
    .navigationTitle("Submit Request")
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") { dismiss() }
          .disabled(isSubmitting)
      }
      ToolbarItem(placement: .confirmationAction) { submitButton }
    }
    .alert("Request Not Sent", isPresented: isShowingError) {
      Button("OK", role: .cancel) {}
    } message: {
      Text(errorMessage ?? "")
    }
  }

  @ViewBuilder
  private var submitButton: some View {
    if isSubmitting {
      ProgressView()
    } else {
      Button("Submit") {
        Task { await submit() }
      }
      .disabled(!controller.canSubmit)
    }
  }

  private var trainingsSection: some View {
    Section {
      ForEach(controller.items) { item in
        LabeledContent(item.name, value: "\(item.hours) hrs")
      }
    } header: {
      Text("Trainings")
    } footer: {
      Text("\(controller.items.count) trainings · \(controller.totalHours) hours total")
    }
  }

  private var contactSection: some View {
    Section {
      TextField("Full Name", text: $controller.name)
        .textContentType(.name)
      TextField("Email", text: $controller.email)
        .textContentType(.emailAddress)
        .keyboardType(.emailAddress)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
      TextField("Phone (optional)", text: $controller.phone)
        .textContentType(.telephoneNumber)
        .keyboardType(.phonePad)
      TextField("Company (optional)", text: $controller.company)
        .textContentType(.organizationName)
    } header: {
      Text("Contact")
    } footer: {
      if showsEmailHint {
        Text("Enter a valid email address.").foregroundStyle(.red)
      }
    }
  }

  private var scheduleSection: some View {
    Section {
      DatePicker(
        "Preferred Start",
        selection: $controller.preferredStartDate,
        in: controller.earliestStartDate...,
        displayedComponents: .date)
      TextField("Notes (optional)", text: $controller.notes, axis: .vertical)
        .lineLimit(3...6)
    } header: {
      Text("Schedule")
    } footer: {
      Text("The training center will confirm the final schedule with you.")
    }
  }

  // MARK: - Confirmation

  private func confirmationView(_ confirmation: BookingConfirmation) -> some View {
    ContentUnavailableView {
      Label("Request Sent", systemImage: "checkmark.circle.fill")
        .foregroundStyle(.tint)
    } description: {
      Text("Reference **\(confirmation.reference)**\nThe training center will contact you at \(controller.email) to confirm your schedule.")
    } actions: {
      Button("Done") { dismiss() }
        .buttonStyle(.borderedProminent)
    }
    .navigationTitle("")
  }

  // MARK: - Actions

  private func submit() async {
    guard await controller.submit() != nil else { return }
    await trainingListController.remove(ids: Set(controller.items.map(\.id)))
  }
}
