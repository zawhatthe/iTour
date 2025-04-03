//
//  ContentView.swift
//  iTour
//
//  Created by Jonathan Zawada on 1/4/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @State private var path = [Destination]()
    @State private var sortOrder = SortDescriptor(\Destination.rank)
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack(path: $path) {
            DestinationListingView(sort: sortOrder, searchString: searchText)
            .navigationTitle("Pentangle")
            .navigationDestination(for: Destination.self, destination: EditDestinationView.init)
            .searchable(text: $searchText)
            .toolbar {
                Button("Add Destination", systemImage: "plus", action: addDestination)
                Menu("Sort", systemImage: "arrow.up.arrow.down") {
                    Picker("Sort", selection: $sortOrder) {
                        Text("Name")
                        .tag(SortDescriptor(\Destination.name))
                        Text("Ranking")
                            .tag(SortDescriptor(\Destination.rank))
                    }
                    .pickerStyle(.inline)
                }
            }
        }
    }
    
    func addDestination() {
        let destination = Destination()
        
//        // Find the highest current rank and add 1
//        let highestRank = try? modelContext.fetch(FetchDescriptor<Destination>(sortBy: [SortDescriptor(\.rank, order: .reverse)])).first?.rank ?? -1
//        destination.rank = ((highestRank ?? -1) + 1)
        
        modelContext.insert(destination)
        path = [destination]
    }
    
    
    }


#Preview {
    ContentView()
}
