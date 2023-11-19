//
//  ContentView.swift
//  CareMate
//
//  Created by Soren Marcelino on 13/11/2023.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    let categories = ["Heart", "Periods", "Nutrition", "Sleep", "Mental Health"]
    @State private var selectedCategories: Set<String> = []

    var body: some View {
        NavigationView {
            List(categories, id: \.self) { category in
                HStack {
                    Image(systemName: self.selectedCategories.contains(category) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(self.selectedCategories.contains(category) ? .blue : .gray)
                        .frame(width: 30, height: 30)

                    Text(category)
                }
                .contentShape(Rectangle()) // Make the entire row tappable
                .onTapGesture {
                    self.toggleCategorySelection(category)
                }
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Share") {
                        self.shareSelectedRows()
                    }
                    .disabled(selectedCategories.isEmpty) // Disable the button if no row is selected
                }
            }
        }
    }

    private func toggleCategorySelection(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }

    private func shareSelectedRows() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

        let group = DispatchGroup()

        for selectedRow in selectedCategories {
            group.enter()

            if selectedRow == "Heart" {
                let heartDataFetcher = GetHeartData()
                heartDataFetcher.getHeartData { (heartData, error) in
                    defer {
                        group.leave()
                    }

                    if let error = error {
                        print("Error fetching heart data: \(error)")
                    } else if let heartData = heartData {
                        if let jsonString = JSONFormatter.formatAndSortJSON(heartData, dateFormatter: dateFormatter) {
                            print("Formatted and sorted Heart Data:\n\(jsonString)")
                        }
                    }
                }
            }
            
            // Add logic for other selected categories here
        }

    }

}


#Preview {
    ContentView()
}
