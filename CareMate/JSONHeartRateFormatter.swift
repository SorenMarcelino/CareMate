//
//  JSONHeartRateFormatter.swift
//  CareMate
//
//  Created by Soren Marcelino on 20/11/2023.
//

import Foundation

class JSONHeartRateFormatter {
    static func formatHeartRateData(_ data: [String: Any], dateFormatter: DateFormatter) -> String? {
        var jsonData: [[String: Any]] = []
        
        for (dateString, value) in data {
            if let date = dateFormatter.date(from: dateString) {
                let dataPoint: [String: Any] = ["x": dateFormatter.string(from: date), "y": value]
                jsonData.append(dataPoint)
            }
        }
        
        // Sort jsonData based on "x" values (dates) in descending order
        jsonData.sort { (dict1, dict2) -> Bool in
            if let date1 = dateFormatter.date(from: dict1["x"] as! String), let date2 = dateFormatter.date(from: dict2["x"] as! String) {
                return date1 > date2
            }
            return false
        }
        
        // Convert jsonData to formatted JSON string
        if let formattedText = try? JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted),
           let jsonString = String(data: formattedText, encoding: .utf8) {
            return jsonString
        }
        
        return nil
    }
}
