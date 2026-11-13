//
//  TaskEditorView.swift
//  Simplr
//
//  Created by Gabriel Bolbotina on 22.04.2026.
//

import SwiftUI
import SwiftData

/// Creates a task in `board`, or edits `task` when one is passed in.
struct TaskEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    var board: Board?
    var task: TaskItem?

    @State private var title: String
    @State private var notes: String
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var priority: Priority
    @State private var category: Category?

    init(board: Board?, task: TaskItem? = nil) {
        self.board = board
        self.task = task
        _title = State(initialValue: task?.title ?? "")
        _notes = State(initialValue: task?.notes ?? "")
        _hasDueDate = State(initialValue: task?.dueDate != nil)
        _dueDate = State(initialValue: task?.dueDate ?? .now)
        _priority = State(initialValue: task?.priority ?? .medium)
        _category = State(initialValue: task?.category)
    }

    private var isEditing: Bool { task != nil }
    private var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }

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

                            TextField("Description", text: $notes, axis: .vertical)
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

                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Due date", isOn: $hasDueDate.animation())
                            if hasDueDate {
                                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .labelsHidden()
                            }
                        }
                        .padding()
                        .background(.background)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }

                    // Category
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Category", systemImage: "tag")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            SettingsLink {
                                Text("Manage Categories…")
                            }
                            .buttonStyle(.link)
                            .font(.caption)
                        }

                        if categories.isEmpty {
                            Text("No categories yet.")
                                .foregroundStyle(.secondary)
                        } else {
                            Picker("Category", selection: $category) {
                                Text("None").tag(Category?.none)
                                ForEach(categories) { category in
                                    Label {
                                        Text(category.name)
                                    } icon: {
                                        Image(systemName: "circle.fill").foregroundStyle(category.color)
                                    }
                                    .tag(Category?.some(category))
                                }
                            }
                            .labelsHidden()
                        }
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
                    Button(action: save) {
                        Text(isEditing ? "Save Changes" : "Add Task")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(trimmedTitle.isEmpty ? Color.blue.opacity(0.3) : Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.return, modifiers: .command)
                    .disabled(trimmedTitle.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Color.gray.opacity(0.08))
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .frame(minWidth: 440, idealWidth: 480, minHeight: 560, idealHeight: 680)
    }

    private func save() {
        guard !trimmedTitle.isEmpty else { return }
        let target = task ?? {
            let new = TaskItem(title: trimmedTitle, board: board)
            new.sortOrder = (board?.tasks?.map(\.sortOrder).max() ?? -1) + 1
            modelContext.insert(new)
            return new
        }()
        target.title = trimmedTitle
        target.notes = notes
        target.dueDate = hasDueDate ? dueDate : nil
        target.priority = priority
        target.category = category
        dismiss()
    }
}

#Preview {
    TaskEditorView(board: nil)
        .modelContainer(PreviewData.container)
}
