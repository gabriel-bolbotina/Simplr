//
//  AddTaskView.swift
//  Simplr
//
//  Created by Gabriel Bolbotina on 22.04.2026.
//

import SwiftUI
import SwiftData

private extension Priority {
    var color: Color {
        switch self {
        case .low:    return .green
        case .medium: return .orange
        case .high:   return .red
        }
    }
}

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var taskDescription = ""
    @State private var dueDate = Date()
    @State private var priority: Priority = .low

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Task Details
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Task Details", systemImage: "pencil.line")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        VStack(spacing: 0) {
                            TextField("Title", text: $title)
                                .font(.body)
                                .padding()
                                .background(.background)

                            Divider().padding(.leading)

                            TextField("Description", text: $taskDescription, axis: .vertical)
                                .font(.body)
                                .lineLimit(3...6)
                                .padding()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }

                    // Schedule
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Schedule", systemImage: "calendar")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .padding()
                            .background(.background)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }

                    // Priority
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Priority", systemImage: "flag.fill")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 10) {
                            ForEach(Priority.allCases, id: \.self) { p in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        priority = p
                                    }
                                } label: {
                                    Text(p.rawValue)
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            priority == p
                                                ? p.color
                                                : p.color.opacity(0.12)
                                        )
                                        .foregroundStyle(
                                            priority == p ? .white : p.color
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(p.color.opacity(priority == p ? 0 : 0.4), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Save button
                    Button {
                        let task = TaskObject(
                            title: title,
                            taskDescription: taskDescription,
                            dueDate: dueDate,
                            priority: priority
                        )
                        modelContext.insert(task)
                        dismiss()
                    } label: {
                        Text("Save Reminder")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(title.isEmpty ? Color.blue.opacity(0.3) : Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .disabled(title.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Color.gray.opacity(0.08))
            .navigationTitle("Add Reminder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AddTaskView()
        .modelContainer(for: TaskObject.self, inMemory: true)
}
