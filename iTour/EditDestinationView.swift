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
    @Environment(\.modelContext) private var modelContext
    @Query var allDestinations: [Destination]
    @State private var categories: [Category] = []
    
    // Store the original rank when editing begins
    @State private var originalRank: Int
    
    init(destination: Destination) {
        self.destination = destination
        self._originalRank = State(initialValue: destination.rank)
        self._allDestinations = Query()
    }
    
    var body: some View {
        Form {
            Section("Category") {
                Picker("Category", selection: $destination.cat) {
                    ForEach(categories) { category in
                        Text(category.name).tag(category as Category?)
                    }
                }
            }
            
            TextField("Name", text: $destination.name)
            TextField("Details", text: $destination.details, axis: .vertical)
            
            Section("Rank") {
                Picker("Rank", selection: $destination.rank) {
                    Text("Inbox").tag(-1)
                    ForEach(1...5, id: \.self) { number in
                        Text("\(number)").tag(number)
                    }
                    Text("Archive").tag(6)
                }
                .pickerStyle(.wheel)
                .onChange(of: destination.rank) { oldValue, newValue in
                    updateRanks(from: oldValue, to: newValue)
                }
            }
            
            Section("Sights") {
                ForEach(destination.sights) { sight in
                    Text(sight.name)
                }
                
                HStack {
                    TextField("Add a new sight in \(destination.name)", text: $newSightName)
                    Button("Add", action: addSight)
                }
            }
        }
        .navigationTitle("Edit Destination")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Load categories from the database
            categories = Category.getAllCategories(modelContext: modelContext)
            
            // If destination doesn't have a category yet, set the first one
            if destination.cat == nil && !categories.isEmpty {
                destination.cat = categories.first
            }
        }
    }
    
    func addSight() {
        guard newSightName.isEmpty == false else { return }
        
        withAnimation {
            let sight = Sight(name: newSightName)
            destination.sights.append(sight)
            newSightName = ""
        }
    }
    
    func updateRanks(from oldRank: Int, to newRank: Int) {
        // If rank didn't actually change, do nothing
        if oldRank == newRank { return }
        
        // First, determine the current destination's category
        guard let currentCategory = destination.cat else { return }
        
        // Filter to only destinations that belong to the same category
        let sameCategory = allDestinations.filter { $0.cat?.id == currentCategory.id }
        
        // Remove the destination from its old position
        for otherDestination in sameCategory {
            if otherDestination.id != destination.id && otherDestination.rank > oldRank {
                otherDestination.rank -= 1
            }
        }
        
        // Insert the destination at its new position
        for otherDestination in sameCategory {
            if otherDestination.id != destination.id && otherDestination.rank >= newRank {
                otherDestination.rank += 1
            }
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
