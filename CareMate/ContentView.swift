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
    
    var userData: [String: Any] = ["lastname": "Marcelino", "firstname": "Soren"]
    @State private var heartRateData: Any = ""
    @State private var hrvData: Any = ""
    
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
                            DispatchQueue.main.async {
                                self.heartRateData = jsonString
                                saveJSONStringToFile(jsonString: jsonString, filename: "heartRate.json")
                            }
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
                            DispatchQueue.main.async {
                                self.hrvData = jsonString
                                saveJSONStringToFile(jsonString: jsonString, filename: "heartRateVariability.json")
                            }
                        }
                    }
                }
            }
            
            // Add logic for other selected categories here
        }
        
        group.notify(queue: DispatchQueue.main) {
            // This block will be called when all tasks in the group have completed
            print("Heart Rate Data:\n\(self.heartRateData)")
            print("Heart Rate Variability Data:\n\(self.hrvData)")
            self.sendGraphQLRequest(userData: self.userData, heartRateData: self.heartRateData as! String, hrvData: self.hrvData as! String)
        }
    }
    
    private func sendGraphQLRequest(userData: [String: Any], heartRateData: String, hrvData: String) {
        // GraphQL server URL
        let graphQLURL = URL(string: "http://192.168.1.74:4000/graphql")!
        
        // GraphQL mutation
        let graphQLMutation = """
        mutation SaveData($userData: UserDataInput, $heartRateData: String, $hrvData: String) {
            saveData(userData: $userData, heartRateData: $heartRateData, hrvData: $hrvData)
        }
        """

        var request = URLRequest(url: graphQLURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters = [
            "query": graphQLMutation,
            "variables": [
                "userData": userData,
                "heartRateData": heartRateData,
                "hrvData": hrvData
            ]
        ] as [String : Any]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            print("Error creating JSON data:", error)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Handle response from the server
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print("Server Response: \(responseString ?? "")")
            }
        }
        task.resume()
    }

    
    // Function to save JSON string to a file
    private func saveJSONStringToFile(jsonString: String, filename: String) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(filename)
            // Writing
            do {
                try jsonString.write(to: fileURL, atomically: false, encoding: .utf8)
            } catch {
                // Error handling here
            }
            
            // Reading
            do {
                let text = try String(contentsOf: fileURL, encoding: .utf8)
                //print("File \(filename): \n\(text)")
            } catch {
                // Error handling here
            }
        }
    }

}


#Preview {
    ContentView()
}
