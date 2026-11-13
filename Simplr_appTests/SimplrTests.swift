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
