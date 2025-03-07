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
        
      }.padding(EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 10))
        
        @State var days = tasks.getRemainingDays()
        
      HStack {
        Text("\(tasks.getDescription()) ").font(.caption).padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
        Spacer(minLength: 1)
        if(days < 0){
          Text("\(abs(days)) days due").font(.subheadline).foregroundStyle(.red)
        }
        else {
          Text("\(days) days remaining").font(.subheadline).foregroundStyle(.gray)
        }
      }.padding(EdgeInsets(top: 0, leading: 10, bottom: 8, trailing: 10))
        
        //Button(action: void) {
        // task.setStatus(status: true)
        //Text("Done")
        //}
      Spacer(minLength: 1)
    }.background(Color.gray.opacity(0.1)).cornerRadius(10)

  }
  
}
