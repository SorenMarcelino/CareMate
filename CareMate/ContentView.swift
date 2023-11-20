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
        
        let lastName = "Marcelino"
        let firstName = "Soren"
        
        var userData: [String: Any] = ["lastname": lastName, "firstname": firstName]
        
        for selectedRow in selectedCategories {
            group.enter()

            if selectedRow == "Heart" {
                let heartDataFetcher = GetHeartData()
                var tasksCompleted = 0 // Conter for completed tasks
                
                heartDataFetcher.getHeartRateData { (heartRate, error) in
                    defer {
                        tasksCompleted += 1
                        if tasksCompleted == 2 {
                            group.leave()
                        }
                    }

                    if let error = error {
                        print("Error fetching heart data: \(error)")
                    } else if let heartRate = heartRate {
                        if let jsonString = JSONHeartRateFormatter.formatHeartRateData(heartRate, dateFormatter: dateFormatter) {
                            print("Formatted and sorted Heart Data:\n\(jsonString)")
                        }
                    }
                }
                
                heartDataFetcher.getHeartRateVariabilityData { (heartRateVariability, error) in
                    defer {
                        tasksCompleted += 1
                        if tasksCompleted == 2 {  // Check if both tasks are completed
                            group.leave()
                        }
                    }

                    if let error = error {
                        print("Error fetching heart data: \(error)")
                    } else if let heartRateVariability = heartRateVariability {
                        if let jsonString = JSONHeartRateFormatter.formatHeartRateData(heartRateVariability, dateFormatter: dateFormatter) {
                            print("Formatted and sorted Heart Data Variability:\n\(jsonString)")
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
