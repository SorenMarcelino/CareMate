//
//  JSONFormatter.swift
//  CareMate
//
//  Created by Soren Marcelino on 19/11/2023.
//

import Foundation

class JSONFormatter {
    static func formatAndSortJSON(_ data: [String: Any], dateFormatter: DateFormatter, additionalData: [String: Any]?) -> String? {
        var jsonData: [String: Any] = [:]
        
        // Include additional data under "user" key if available
        /*if let additionalData = additionalData {
            jsonData["user"] = additionalData
        } else {
            print("Error: Last name or first name is missing.")
            return nil
        }*/
        
        var dataPoints: [[String: Any]] = []
        
        for (dateString, value) in data {
            if let date = dateFormatter.date(from: dateString) {
                let dataPoint: [String: Any] = ["x": dateFormatter.string(from: date), "y": value]
                dataPoints.append(dataPoint)
            }
        }
        
        // Add sorted dataPoints under "data" key
        jsonData["data"] = dataPoints
        
        // Convert jsonData to formatted JSON string
        if let formattedText = try? JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted),
           let jsonString = String(data: formattedText, encoding: .utf8) {
            return jsonString
        }
        
        return nil
    }
}
