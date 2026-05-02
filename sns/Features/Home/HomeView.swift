import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    let logbookItems: [ActivityItem] = MockData.logbookItems

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("Weekly Batch")
                    .font(.headline)

                SlideToEnrollControl(
                    isEnrolledInBatch: viewModel.isEnrolledInBatch,
                    resetTrigger: viewModel.sliderResetTrigger
                ) {
                    viewModel.showEnrollConfirmation = true
                }

                if !viewModel.isEnrolledInBatch {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(width: 20)

                        Text("Enrolling is final and cannot be undone.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, -4)
                }

                if viewModel.isEnrolledInBatch {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                            .frame(width: 20)

                        Text("You're enrolled for this week (final).")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    }
                    .padding(.top, -4)
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Text("Message Match")
                            .font(.headline)

                        Button {
                            viewModel.showMatchInfoSheet = true
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.gray)
                        }
                        .buttonStyle(.plain)
                    }

                    if viewModel.hasMatchThisWeek {
                        Text("A match profile is ready.")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    } else {
                        Text("No match for the previous week.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Logbook")
                        .font(.headline)
                        .padding(.bottom, 2)

                    ForEach(logbookItems) { item in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: item.symbol)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(width: 20)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.subheadline)
                                Text(item.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(item.timestamp)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding()
            .sheet(isPresented: $viewModel.showMatchInfoSheet) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Match Messaging Info")
                        .font(.headline)

                    Text("Your conversation is deleted when you move on to the next match.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .presentationDetents([.fraction(0.22)])
                .presentationDragIndicator(.visible)
            }
            .alert("Confirm Enrollment", isPresented: $viewModel.showEnrollConfirmation) {
                Button("Cancel", role: .cancel) {
                    viewModel.cancelEnrollment()
                }
                Button("Confirm Enroll") {
                    viewModel.confirmEnrollment()
                }
            } message: {
                Text("This action cannot be undone.")
            }
            .onDisappear {
                viewModel.cancelMatchSimulation()
            }
            .navigationTitle("Home")
        }
    }
}
