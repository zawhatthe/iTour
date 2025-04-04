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
    @State private var categories: [Category] = []
    @State private var selectedCategoryIndex = 0
    @State private var selectedRankIndex = 0
    
    // New state to track view mode
    @State private var viewMode: ViewMode = .categories
    
    enum ViewMode {
        case categories
        case ranks
    }
    
    // Map category names to SF Symbols
    func symbolForCategory(_ category: Category) -> String {
        switch category.name {
        case "Book":
            return "book.fill"
        case "Music":
            return "music.note"
        case "Film":
            return "film.fill"
        case "TV Show":
            return "tv.fill"
        case "Video Game":
            return "gamecontroller.fill"
        case "Podcast":
            return "mic.fill"
        case "Artist":
            return "paintbrush.fill"
        default:
            return "star.fill"
        }
    }
    
    // Map rank to displayable values
    func labelForRank(_ rank: Int) -> String {
        switch rank {
        case -1:
            return "Inbox"
        case 6:
            return "Archive"
        default:
            return "\(rank)"
        }
    }
    
    // Computed property for the dynamic navigation title
    var navigationTitle: String {
        if viewMode == .categories {
            if selectedCategoryIndex == -1 {
                return "All Categories"
            } else if selectedCategoryIndex >= 0 && selectedCategoryIndex < categories.count {
                return categories[selectedCategoryIndex].name
            }
        } else {
            // Ranks mode
            let rank = rankValues[selectedRankIndex]
            return labelForRank(rank)
        }
        
        // Fallback title
        return "Pentangle"
    }
    
    // Map rank to SF Symbols
    func symbolForRank(_ rank: Int) -> String {
        switch rank {
        case -1:
            return "tray.fill"
        case 6:
            return "archivebox.fill"
        default:
            return "\(rank).circle.fill"
        }
    }
    
    // Array of rank values in order
    let rankValues = [-1, 1, 2, 3, 4, 5, 6]
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                // View mode toggle at the top
                Picker("View Mode", selection: $viewMode) {
                    Text("Categories").tag(ViewMode.categories)
                    Text("Rankings").tag(ViewMode.ranks)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Tab bar changes based on view mode
                if viewMode == .categories {
                    // Category tabs
                    categoryTabsView
                } else {
                    // Rank tabs
                    rankTabsView
                }
                
                // Main content area
                if viewMode == .categories {
                    // Filter by category
                    DestinationListingView(
                        sort: sortOrder,
                        filterCategory: selectedCategoryIndex >= 0 && selectedCategoryIndex < categories.count ? categories[selectedCategoryIndex] : nil
                    )
                } else {
                    // Filter by rank
                    let rankFilter = rankValues[selectedRankIndex]
                    RankFilterView(rank: rankFilter)
                }
                
                Spacer()
            }
            .navigationTitle(navigationTitle)
            .navigationDestination(for: Destination.self, destination: EditDestinationView.init)
            //.searchable(text: $searchText)
            .toolbar {
                Button("Add", systemImage: "plus", action: addDestination)
            }
        }
        .onAppear {
            // Load categories from the database on appear
            categories = Category.getAllCategories(modelContext: modelContext)
        }
    }
    
    // MARK: - Tab Views
    
    var categoryTabsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                // "All" tab
//                VStack {
//                    Button(action: {
//                        selectedCategoryIndex = -1
//                    }) {
//                        Image(systemName: "square.grid.2x2.fill")
//                            .font(.system(size: 22))
//                            .foregroundColor(selectedCategoryIndex == -1 ? .primary : .secondary)
//                    }
//                    
//                    Rectangle()
//                        .frame(height: 2)
//                        .foregroundColor(selectedCategoryIndex == -1 ? .blue : .clear)
//                }
                
                // Category tabs with SF Symbols
                ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                    VStack {
                        Button(action: {
                            selectedCategoryIndex = index
                        }) {
//                            VStack {
                                Image(systemName: symbolForCategory(category))
                                    .font(.system(size: 22))
                                    .foregroundColor(selectedCategoryIndex == index ? .primary : .secondary)
                                
//                                Text(category.name)
//                                    .font(.caption2)
//                                    .foregroundColor(selectedCategoryIndex == index ? .primary : .secondary)
//                            }
                        }
                        
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(selectedCategoryIndex == index ? .blue : .clear)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 4)
            .padding(.bottom, 2)
        }
    }
    
    var rankTabsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                // Rank tabs
                ForEach(Array(rankValues.enumerated()), id: \.element) { index, rank in
                    VStack {
                        Button(action: {
                            selectedRankIndex = index
                        }) {
//                            VStack {
                                Image(systemName: symbolForRank(rank))
                                    .font(.system(size: 22))
                                    .foregroundColor(selectedRankIndex == index ? .primary : .secondary)
                                
//                                Text(labelForRank(rank))
//                                    .font(.caption2)
//                                    .foregroundColor(selectedRankIndex == index ? .primary : .secondary)
//                            }
                        }
                        
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(selectedRankIndex == index ? .blue : .clear)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 4)
            .padding(.bottom, 2)
        }
    }
    
    func addDestination() {
        // Make sure categories exist
        let allCategories = Category.getAllCategories(modelContext: modelContext)
        
        let destination = Destination()
        
        // Set default rank or category based on the current view mode
        if viewMode == .categories {
            // Set category based on selected tab
            if selectedCategoryIndex >= 0 && selectedCategoryIndex < allCategories.count {
                destination.cat = allCategories[selectedCategoryIndex]
            } else if !allCategories.isEmpty {
                destination.cat = allCategories.first
            }
        } else {
            // Set rank based on selected tab
            destination.rank = rankValues[selectedRankIndex]
        }
        
        modelContext.insert(destination)
        path = [destination]
    }
}

// New view to filter by rank value
struct RankFilterView: View {
    @Environment(\.modelContext) var modelContext
    @Query var destinations: [Destination]
    
    init(rank: Int) {
        // Create a predicate based on the rank
        if rank == -1 {
            // Inbox: rank < 1
            _destinations = Query(filter: #Predicate<Destination> { $0.rank < 1 })
        } else if rank == 6 {
            // Archive: rank > 5
            _destinations = Query(filter: #Predicate<Destination> { $0.rank > 5 })
        } else {
            // Specific rank
            _destinations = Query(filter: #Predicate<Destination> { $0.rank == rank })
        }
    }
    
    var body: some View {
        List {
            ForEach(destinations) { destination in
                NavigationLink(value: destination) {
                    VStack(alignment: .leading) {
                        Text(destination.name)
                        if let cat = destination.cat {
                            Text(cat.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(destinations[index])
        }
    }
}

#Preview {
    ContentView()
}
