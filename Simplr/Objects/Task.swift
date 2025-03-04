//
//  Task.swift
//  Simplr
//
//  Created by Gabriel Bolbotina on 04.03.2025.
//

import Foundation
import AppKit

enum Priority{
  case low
  case medium
  case high
}

struct TaskObject{
  //variables
  private var title: String
  private var description: String
  private var dueDate: String
  private var priority: Priority
  private var status: Bool

  init(title: String, description: String, dueDate: String, priority: Priority) {
    self.title = title
    self.description = description
    self.dueDate = dueDate
    self.priority = priority
    self.status = false
  }
  
  // getters
  
  func getTitle() -> String {
    return self.title
  }
  
  func getDescription() -> String {
    return self.description
  }
  
  func getDueDate() -> Date {
    return getDate(self.dueDate)
  }
  
  func getPriority() -> String {
    if self.priority == .low {
      return "Low"
    }
    else if self.priority == .medium {
      return "Medium"
    }
    else if self.priority == .high {
      return "High"
    }
    return ""
  }
  
  func getRemainingDays() -> Int {
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.day], from: Date(), to: getDate(self.dueDate))
    return (dateComponents.day!)
  }
  
  mutating func setStatus(_ status: Bool) {
    self.status = status
  }
  
  
  func dateFormatter(_ dateString: String, dateFormat: String = "dd.MM.yyyy") -> Date? {
      let formatter = DateFormatter()
      formatter.dateFormat = dateFormat

      // Check if the dateString is empty
      if dateString.isEmpty {
          return nil // Or return Date() if you want to return the current date
      }

      // Attempt to create a Date from the dateString
      return formatter.date(from: dateString)
  }
  
  func getDate(_ dateString: String) -> Date {
      if let date = dateFormatter(dateString) {
          return date
      } else {
          // Return a default date or handle the error
          return Date()
      }
  }
  
}
