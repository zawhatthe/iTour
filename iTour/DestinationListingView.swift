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
    @Query(sort: [SortDescriptor(\Destination.rank), SortDescriptor(\Destination.name)]) var destinations: [Destination]
    @State private var isInboxExpanded = false
    @State private var isArchiveExpanded = false
    
    var body: some View {
        List {
            // Inbox section
                inboxSection
            
            // Regular items section
                regularItemsSection
            
            // Archive section
                archiveSection
        }
    }
    
    // MARK: - Section Views
    
    // Inbox section
    
    private var inboxSection: some View {
        Group {
            // Inbox section for items with rank < 1
            if !inboxItems.isEmpty {
                DisclosureGroup(
                    isExpanded: $isInboxExpanded,
                    content: {
                        ForEach(inboxItems) { destination in
                            NavigationLink(value: destination) {
                                VStack(alignment: .leading) {
                                    Text(destination.name)
                                }
                            }
                        }
                        .onDelete(perform: deleteInboxItems)
                    },
                    label: {
                        Text("Inbox")
                            .font(.headline)
                    }
                )
            }
        }
    }
    
    // Regular items section
    
    private var regularItemsSection: some View {
        Group {
            // Regular items with 1 <= rank <= 5
            ForEach(regularItems) { destination in
                NavigationLink(value: destination) {
                    HStack {
                        Text("\(destination.rank)")
                            .font(.headline)
                        Text(destination.name)
                    }
                }
            }
            .onDelete(perform: deleteRegularItems)
        }
    }
    
    // Archive items section
    
    private var archiveSection: some View {
        Group {
            // Archive section for items with rank > 5
            if !archiveItems.isEmpty {
                DisclosureGroup(
                    isExpanded: $isArchiveExpanded,
                    content: {
                        ForEach(archiveItems) { destination in
                            NavigationLink(value: destination) {
                                VStack(alignment: .leading) {
                                    Text(destination.name)
                                }
                            }
                        }
                        .onDelete(perform: deleteArchiveItems)
                    },
                    label: {
                        Text("Archive")
                            .font(.headline)
                    }
                )
            }
        }
    }
    
    // MARK: - Filters
    
    // Computed properties to filter the destinations
    private var inboxItems: [Destination] {
        destinations.filter { $0.rank < 1}
    }
    
    private var regularItems: [Destination] {
        destinations.filter { $0.rank >= 1 && $0.rank <= 5 }
    }
    
    private var archiveItems: [Destination] {
        destinations.filter { $0.rank > 5 }
    }
    
    init(sort: SortDescriptor<Destination>, filterCategory: Category? = nil) {
        if let filterCategory = filterCategory {
            // Use the id for comparison instead of the Category object itself
            let categoryId = filterCategory.id
            _destinations = Query(filter: #Predicate<Destination> {
                $0.cat?.id == categoryId
            }, sort: [sort])
        } else {
            _destinations = Query(sort: [sort])
        }
    }
    
    func deleteInboxItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { inboxItems[$0] }
        for item in itemsToDelete {
            modelContext.delete(item)
        }
    }
    
    func deleteRegularItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { regularItems[$0] }
        for item in itemsToDelete {
            modelContext.delete(item)
        }
    }
    
    func deleteArchiveItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { archiveItems[$0] }
        for item in itemsToDelete {
            modelContext.delete(item)
        }
    }
}

#Preview {
    DestinationListingView(sort: SortDescriptor(\Destination.name), filterCategory: Category.allCategories.first!)
}
