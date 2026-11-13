//
//  SimplrTests.swift
//  SimplrTests
//
//  Created by Gabriel Bolbotina on 27.08.2024.
//

import Foundation
import SwiftData
import Testing
@testable import Simplr

@MainActor
struct TaskProgressTests {
    let container: ModelContainer
    let context: ModelContext
    let board: Board

    init() throws {
        container = try ModelContainer(
            for: Board.self, TaskItem.self, Category.self, Shortcut.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = container.mainContext
        board = Board(name: "Test")
        context.insert(board)
    }

    private func makeTask() -> TaskItem {
        let task = TaskItem(title: "Task", board: board)
        context.insert(task)
        return task
    }

    @Test func newTaskStartsInTodoAtZero() {
        let task = makeTask()
        #expect(task.status == .todo)
        #expect(task.progress == 0)
        #expect(task.completedAt == nil)
    }

    @Test func partialProgressMovesToInProgress() {
        let task = makeTask()
        task.setProgress(0.4)
        #expect(task.status == .inProgress)
        #expect(task.progress == 0.4)
    }

    @Test func fullProgressCompletesTask() {
        let task = makeTask()
        let now = Date(timeIntervalSince1970: 1_000)
        task.setProgress(1, now: now)
        #expect(task.status == .done)
        #expect(task.progress == 1)
        #expect(task.completedAt == now)
    }

    @Test(arguments: [(-0.5, TaskStatus.todo, 0.0), (1.5, TaskStatus.done, 1.0)])
    func progressIsClamped(input: Double, status: TaskStatus, progress: Double) {
        let task = makeTask()
        task.setProgress(input)
        #expect(task.status == status)
        #expect(task.progress == progress)
    }

    @Test func draggingSliderBackToZeroReturnsToTodo() {
        let task = makeTask()
        task.setProgress(0.6)
        task.setProgress(0)
        #expect(task.status == .todo)
    }

    @Test func leavingDoneRestoresPreviousProgress() {
        let task = makeTask()
        task.setProgress(0.4)
        task.move(to: .done)
        task.move(to: .inProgress)
        #expect(task.status == .inProgress)
        #expect(task.progress == 0.4)
        #expect(task.completedAt == nil)
    }

    @Test func movingToInProgressFromTodoKeepsZero() {
        let task = makeTask()
        task.move(to: .inProgress)
        #expect(task.status == .inProgress)
        #expect(task.progress == 0)
    }

    @Test func movingToTodoResetsProgress() {
        let task = makeTask()
        task.setProgress(0.7)
        task.move(to: .todo)
        #expect(task.status == .todo)
        #expect(task.progress == 0)
    }

    @Test func completingTwiceKeepsFirstCompletionDate() {
        let task = makeTask()
        let first = Date(timeIntervalSince1970: 1_000)
        task.move(to: .done, now: first)
        task.move(to: .done, now: Date(timeIntervalSince1970: 2_000))
        #expect(task.completedAt == first)
    }
}

@MainActor
struct RelationshipTests {
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        container = try ModelContainer(
            for: Board.self, TaskItem.self, Category.self, Shortcut.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = container.mainContext
    }

    @Test func deletingBoardDeletesTasksAndShortcuts() throws {
        let board = Board(name: "Board")
        let task = TaskItem(title: "Task", board: board)
        context.insert(board)
        context.insert(task)
        context.insert(Shortcut(kind: .url, target: "https://apple.com", title: "Apple", task: task))
        try context.save()

        context.delete(board)
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<TaskItem>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Shortcut>()) == 0)
    }

    @Test func deletingCategoryKeepsTasks() throws {
        let category = Category(name: "Work")
        let task = TaskItem(title: "Task", category: category)
        context.insert(category)
        context.insert(task)
        try context.save()

        context.delete(category)
        try context.save()

        let tasks = try context.fetch(FetchDescriptor<TaskItem>())
        #expect(tasks.count == 1)
        #expect(tasks.first?.category == nil)
    }
}

@MainActor
struct KanbanPlacementTests {
    let container: ModelContainer
    let context: ModelContext
    let board: Board

    init() throws {
        container = try ModelContainer(
            for: Board.self, TaskItem.self, Category.self, Shortcut.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = container.mainContext
        board = Board(name: "Board")
        context.insert(board)
    }

    private func makeTasks(_ titles: String...) -> [TaskItem] {
        titles.enumerated().map { index, title in
            let task = TaskItem(title: title, board: board)
            task.sortOrder = index
            context.insert(task)
            return task
        }
    }

    private func column(_ status: TaskStatus) -> [String] {
        board.sortedTasks.filter { $0.status == status }.map(\.title)
    }

    @Test func droppingOnColumnAppendsAndChangesStatus() {
        let tasks = makeTasks("A", "B")
        tasks[1].move(to: .inProgress)

        board.place(tasks[0], in: .inProgress)

        #expect(tasks[0].status == .inProgress)
        #expect(column(.inProgress) == ["B", "A"])
        #expect(column(.todo).isEmpty)
    }

    @Test func droppingOnCardInsertsBeforeIt() {
        let tasks = makeTasks("A", "B", "C")

        board.place(tasks[2], in: .todo, before: tasks[0])

        #expect(column(.todo) == ["C", "A", "B"])
    }

    @Test func droppingIntoDoneCompletesAndBackRestoresProgress() {
        let task = makeTasks("A")[0]
        task.setProgress(0.3)

        board.place(task, in: .done)
        #expect(task.progress == 1)

        board.place(task, in: .inProgress)
        #expect(task.progress == 0.3)
    }

    @Test func droppingOnItselfChangesNothing() {
        let tasks = makeTasks("A", "B")

        board.place(tasks[0], in: .todo, before: tasks[0])

        #expect(column(.todo) == ["A", "B"])
    }
}

struct ProgressHapticsTests {
    @Test(arguments: [(0.2, 0.3), (0.3, 0.2), (0.6, 0.4), (0.8, 0.7)])
    func crossingAQuarterTicks(from: Double, to: Double) {
        #expect(ProgressHaptics.feedback(from: from, to: to) == .milestone)
    }

    @Test(arguments: [(0.3, 0.4), (0.0, 0.1), (0.76, 0.99)])
    func movingWithinAQuarterIsSilent(from: Double, to: Double) {
        #expect(ProgressHaptics.feedback(from: from, to: to) == nil)
    }

    @Test func reachingFullIsComplete() {
        #expect(ProgressHaptics.feedback(from: 0.9, to: 1) == .complete)
        #expect(ProgressHaptics.feedback(from: 0.1, to: 1) == .complete)
    }

    @Test func leavingFullWithoutCrossingAQuarterIsSilent() {
        #expect(ProgressHaptics.feedback(from: 1, to: 0.9) == nil)
    }

    @Test func jumpingOverSeveralQuartersTicksOnce() {
        #expect(ProgressHaptics.feedback(from: 0.1, to: 0.8) == .milestone)
    }
}

struct SliderSnappingTests {
    @Test(arguments: [(0.98, 1.0), (1.2, 1.0), (0.02, 0.0), (-0.3, 0.0), (0.5, 0.5), (0.96, 0.96)])
    func snapsNearTheEnds(input: Double, expected: Double) {
        #expect(GlassProgressSlider.snapped(input) == expected)
    }

    @MainActor
    @Test func releasingAtFullCompletesTheTask() {
        let task = TaskItem(title: "Task")
        task.setProgress(GlassProgressSlider.snapped(0.985))
        #expect(task.status == .done)
    }
}
