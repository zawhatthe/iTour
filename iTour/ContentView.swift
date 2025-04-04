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
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
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
                            filterCategory: selectedCategoryIndex >= 0 && selectedCategoryIndex < categories.count ? categories[selectedCategoryIndex] : nil,
                            showCategory: false
                        )
                    } else {
                        // Filter by rank
                        let rankFilter = rankValues[selectedRankIndex]
                        RankFilterView(rank: rankFilter, showCategory: true)
                    }
                    
                    // Add spacing at the bottom to account for the custom tab bar
                    Spacer(minLength: 70)
                }
                .navigationTitle(navigationTitle)
                .navigationDestination(for: Destination.self, destination: EditDestinationView.init)
                
                // Custom bottom navigation bar
                bottomNavigationBar
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
    
    // Custom bottom navigation bar
    var bottomNavigationBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 0) {
                // View mode toggle
                Button(action: {
                    viewMode = .categories
                }) {
                    VStack {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 20))
                        Text("Categories")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .foregroundColor(viewMode == .categories ? .blue : .gray)
                }
                
                // Add button
                Button(action: addDestination) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 56, height: 56)
                            .shadow(radius: 2)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(y: -15)
                }
                .frame(width: 60)
                
                // Rankings toggle
                Button(action: {
                    viewMode = .ranks
                }) {
                    VStack {
                        Image(systemName: "list.number")
                            .font(.system(size: 20))
                        Text("Rankings")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .foregroundColor(viewMode == .ranks ? .blue : .gray)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .background(Color(.systemBackground))
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
    var showCategory: Bool
    
    init(rank: Int, showCategory: Bool = false) {
        self.showCategory = showCategory
        
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
    
    var body: some View {
        List {
            ForEach(destinations) { destination in
                NavigationLink(value: destination) {
                    HStack {
                        if showCategory, let cat = destination.cat {
                            Image(systemName: symbolForCategory(cat))
                                .foregroundColor(.secondary)
                                .frame(width: 24)
                        }
                        
                        Text(destination.name)
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
