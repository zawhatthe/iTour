//
//  DestinationListingView.swift
//  iTour
//
//  Created by Jonathan Zawada on 1/4/2025.
//

import SwiftData
import SwiftUI

struct DestinationListingView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: [SortDescriptor(\Destination.priority, order: .reverse), SortDescriptor(\Destination.name)]) var destinations: [Destination]
    
    var body: some View {
        List {
            ForEach(destinations) { destination in
                VStack(alignment: .leading) {
                    NavigationLink(value: destination) {
                        Text(destination.name)
                            .font(.headline)
                        Text(String(destination.rank))
                    }
                }
            }
            .onDelete(perform: deleteDestinations)
        }
    }
    
    init(sort: SortDescriptor<Destination>, searchString: String) {
        
        _destinations = Query(filter: #Predicate {
            if searchString.isEmpty {
                return true
            } else {
                return $0.name.localizedStandardContains(searchString)
            }
        }, sort: [sort])
    }
    
    func deleteDestinations(_ indexSet: IndexSet) {
        for index in indexSet {
            let destinationToDelete = destinations[index]
            modelContext.delete(destinationToDelete)
        }
    }
}

#Preview {
    DestinationListingView(sort: SortDescriptor(\Destination.name), searchString: "")
}
