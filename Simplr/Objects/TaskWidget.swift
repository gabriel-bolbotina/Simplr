//
//  TaskWidget.swift
//  Simplr
//
//  Created by Gabriel Bolbotina on 04.03.2025.
//

import SwiftUI

struct TaskWidget : View {
  //creating the widget for different tasks
  private var tasks: TaskObject
  init(tasks: TaskObject) {
    self.tasks = tasks
  }
  
  var body: some View{
    VStack(alignment: .leading){
      HStack {
        Text("\(tasks.getTitle()) ").font(.title2).multilineTextAlignment(.leading)
        Text("\(tasks.getPriority())").font(.title3.bold()).foregroundStyle(.red)
        
      }
        
        @State var days = tasks.getRemainingDays()
        
      HStack {
        Text("\(tasks.getDescription()) ").font(.title3)
        Spacer(minLength: 1)
        if(days < 0){
          Text("\(abs(days)) days due").font(.subheadline).foregroundStyle(.red)
        }
        else {
          Text("\(days) days remaining").font(.subheadline).foregroundStyle(.gray)
        }
      }
        
        //Button(action: void) {
        // task.setStatus(status: true)
        //Text("Done")
        //}
      Spacer(minLength: 1)
    }

    }
  
}
