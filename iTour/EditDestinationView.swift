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
        
        // Filter to only destinations that belong to the same category (excluding the current one)
        let sameCategoryDestinations = allDestinations.filter {
            $0.cat?.id == currentCategory.id && $0.id != destination.id
        }
        
        // STEP 1: Handle basic movement between ranks
        
        // Moving FROM a numeric rank (1-5) TO Inbox or Archive
        if (oldRank >= 1 && oldRank <= 5) && (newRank == -1 || newRank == 6) {
            // We need to shift all other items up to fill the gap
            // We'll do this in the renumbering step below
        }
        // Moving FROM Inbox/Archive TO a numeric rank (1-5)
        else if (oldRank == -1 || oldRank == 6) && (newRank >= 1 && newRank <= 5) {
            // We need to make space for the new item at its rank
            for otherDest in sameCategoryDestinations {
                if otherDest.rank >= newRank && otherDest.rank <= 5 {
                    otherDest.rank += 1
                    
                    // If this pushes an item beyond 5, move it to Archive
                    if otherDest.rank > 5 {
                        otherDest.rank = 6
                    }
                }
            }
        }
        // Moving between numeric ranks (1-5)
        else if (oldRank >= 1 && oldRank <= 5) && (newRank >= 1 && newRank <= 5) {
            if oldRank < newRank {
                // Moving DOWN the list (e.g., 1→3): shift items in between UP
                for otherDest in sameCategoryDestinations {
                    if otherDest.rank > oldRank && otherDest.rank <= newRank {
                        otherDest.rank -= 1
                    }
                }
            } else {
                // Moving UP the list (e.g., 3→1): shift items in between DOWN
                for otherDest in sameCategoryDestinations {
                    if otherDest.rank >= newRank && otherDest.rank < oldRank {
                        otherDest.rank += 1
                    }
                }
            }
        }
        
        // STEP 2: Always renumber all ranked items to ensure proper sequence
        
        // This happens regardless of the type of movement
        let rankedItems = sameCategoryDestinations
            .filter { $0.rank >= 1 && $0.rank <= 5 }
            .sorted { $0.rank < $1.rank }
        
        // Skip renumbering if we're moving TO a numeric rank (we already made space)
        if !(newRank >= 1 && newRank <= 5) {
            // Renumber all items starting from 1
            for (index, item) in rankedItems.enumerated() {
                item.rank = index + 1
            }
        }
        
        // STEP 3: Double-check for any items that may have been pushed out of range
        for otherDest in sameCategoryDestinations {
            // Make sure nothing got pushed below 1
            if otherDest.rank < 1 && otherDest.rank != -1 {
                otherDest.rank = 1
            }
            
            // Make sure nothing got pushed above 5 (except Archive)
            if otherDest.rank > 5 && otherDest.rank != 6 {
                otherDest.rank = 6
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
