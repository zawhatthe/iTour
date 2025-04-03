//
//  EditDestinationView.swift
//  iTour
//
//  Created by Jonathan Zawada on 1/4/2025.
//

import SwiftUI
import SwiftData

struct EditDestinationView: View {
    @Bindable var destination: Destination
    @State private var newSightName: String = ""
    
    var body: some View {
        Form {
            TextField("Name", text: $destination.name)
            TextField("Details", text: $destination.details, axis: .vertical)
            DatePicker("Date", selection: $destination.date)
            
            Section("Rank") {
                Picker("Rank", selection: $destination.rank) {
                    ForEach(1...5, id: \.self) { number in
                        Text("\(number)").tag(number)
                                    }
                }
                .pickerStyle(.wheel)
            }
            
            Section("Priority") {
                Picker("Priority", selection: $destination.priority) {
                    Text("Megh").tag(1)
                    Text("Maybe").tag(2)
                    Text("Must").tag(3)
                }
                .pickerStyle(.segmented)
            }
            
            Section("Sights") {
                ForEach(destination.sights) { sight in                        Text(sight.name)
                }
                
                HStack {
                    TextField("Add a new sight in \(destination.name)", text: $newSightName)
                    Button("Add", action: addSight)
                }
            }
            
        }
        .navigationTitle("Edit Destination")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func addSight() {
        guard newSightName.isEmpty == false else { return }
        
        withAnimation {
            let sight = Sight(name: newSightName)
            destination.sights.append(sight)
            newSightName = ""
        }
    }
    
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Destination.self, configurations: config)
        let example = Destination(name:"Example Destination", details: "Example details go here and will automatically expand as edited.")
        return EditDestinationView(destination: example)
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}
