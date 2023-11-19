//
//  GetHeartData.swift
//  CareMate
//
//  Created by Soren Marcelino on 18/11/2023.
//

import Foundation
import HealthKit

class GetHeartData {
    let healthStore = HKHealthStore()

    func getHeartData(completion: @escaping ([String: Any]?, Error?) -> Void) {
        // Define the heart rate type
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

        // Define the date range (last 7 days)
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!

        // Predicate to filter samples within the date range
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        // Sort descriptors to ensure samples are sorted by date in descending order
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        // Prepare a query to get heart rate samples within the date range
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            // Process the heart rate samples
            if let heartRateSamples = samples as? [HKQuantitySample] {
                let heartData = self.processHeartRateSamples(heartRateSamples)
                completion(heartData, nil)
            } else {
                completion(nil, nil)
            }
        }

        // Execute the query
        healthStore.execute(query)
    }

    private func processHeartRateSamples(_ samples: [HKQuantitySample]) -> [String: Any] {
        var heartData: [String: Any] = [:]

        for sample in samples {
            let date = sample.startDate
            let value = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            heartData[date.description] = value
        }

        return heartData
    }
}
