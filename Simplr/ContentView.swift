//
//  ContentView.swift
//  new_swift_app
//
//  Created by Gabriel Bolbotina on 27.08.2024.
//
//new thing

import SwiftUI

struct ContentView: View {
  @State private var counter: Int = 0
  @State private var dued: Bool = false
  var tasks = TaskObject(title: "Go get some omelette", description: "vegan of course", dueDate: "12.01.2025", priority: Priority.low)
    var body: some View {
        VStack {
          HStack {
            Text("\(tasks.getTitle()) ").font(.title2)
            
          }
          
            @State var days = tasks.getRemainingDays()
            
            if(days < 0){
              Text("\(abs(days)) due").font(.subheadline)
            }
            else {
              Text("\(days) days remaining").font(.subheadline)
            }

          HStack {
            Text("\(tasks.getDescription()) ").font(.title3)
            Text("\(tasks.getPriority())").font(.title3.bold()).foregroundStyle(.red)
            //Button(action: void) {
             // task.setStatus(status: true)
              //Text("Done")
            //}
            Text("\(counter)")
          }.padding(.horizontal)
         
          
        }
        .padding()
        
    }
  }









#Preview {
    ContentView()
}
