//
//  SettingsView.swift
//  Simplr
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("Categories", systemImage: "tag") {
                CategorySettingsView()
            }
        }
        .frame(width: 560, height: 420)
    }
}

struct CategorySettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @State private var selection: Category?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            List(selection: $selection) {
                ForEach(categories) { category in
                    CategoryRow(category: category)
                        .tag(category)
                }
            }
            .onDeleteCommand(perform: deleteSelection)
            .overlay {
                if categories.isEmpty {
                    ContentUnavailableView(
                        "No Categories",
                        systemImage: "tag",
                        description: Text("Categories colour your tasks' glass fill.")
                    )
                }
            }

            HStack(spacing: 2) {
                Button(action: addCategory) {
                    Image(systemName: "plus").frame(width: 20, height: 20)
                }
                .help("Add Category")
                Button(action: deleteSelection) {
                    Image(systemName: "minus").frame(width: 20, height: 20)
                }
                .help("Delete Category")
                .disabled(selection == nil)
                Spacer()
                Text("Deleting a category keeps its tasks.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
        }
        .padding()
    }

    private static let palette = ["#0A84FF", "#FF9F0A", "#30D158", "#BF5AF2", "#FF375F", "#64D2FF"]

    private func addCategory() {
        let category = Category(
            name: "New Category",
            colorHex: Self.palette[categories.count % Self.palette.count],
            sortOrder: (categories.map(\.sortOrder).max() ?? -1) + 1
        )
        modelContext.insert(category)
        selection = category
    }

    private func deleteSelection() {
        guard let selection else { return }
        modelContext.delete(selection)
        self.selection = nil
    }
}

private struct CategoryRow: View {
    @Bindable var category: Category

    private var color: Binding<Color> {
        Binding(
            get: { category.color },
            set: { category.colorHex = $0.hexString ?? category.colorHex }
        )
    }

    var body: some View {
        HStack(spacing: 12) {
            ColorPicker("Colour", selection: color, supportsOpacity: false)
                .labelsHidden()
            TextField("Name", text: $category.name)
                .textFieldStyle(.plain)
            Spacer()
            Picker("Pattern", selection: $category.pattern) {
                ForEach(CategoryPattern.allCases, id: \.self) { pattern in
                    Text(pattern.title).tag(pattern)
                }
            }
            .labelsHidden()
            .frame(width: 110)
            RoundedRectangle(cornerRadius: 6)
                .fill(category.color.opacity(0.25))
                .overlay { CategoryPatternView(pattern: category.pattern, color: category.color.opacity(0.6)) }
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .frame(width: 44, height: 22)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    SettingsView()
        .modelContainer(PreviewData.container)
}
