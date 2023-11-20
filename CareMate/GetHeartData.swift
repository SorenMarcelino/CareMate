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

    // MARK: Heart Rate
    func getHeartRateData(completion: @escaping ([String: Any]?, Error?) -> Void) {
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
    
    
    // MARK: Heart Rate Variability
    // MARK: Heart Rate Variability
    func getHeartRateVariabilityData(completion: @escaping ([String: Any]?, Error?) -> Void) {
        // Define the heart rate variability type
        let heartRateVariabilityType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!

        // Define the date range (last 7 days)
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!

        // Predicate to filter samples within the date range
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        // Sort descriptors to ensure samples are sorted by date in descending order
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        // Prepare a query to get heart rate variability samples within the date range
        let query = HKSampleQuery(sampleType: heartRateVariabilityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            // Process the heart rate variability samples
            if let hrvSamples = samples as? [HKQuantitySample] {
                let hrvData = self.processHeartRateVariabilitySamples(hrvSamples)
                completion(hrvData, nil)
            } else {
                completion(nil, nil)
            }
        }

        // Execute the query
        healthStore.execute(query)
    }

    private func processHeartRateVariabilitySamples(_ samples: [HKQuantitySample]) -> [String: Any] {
        var hrvData: [String: Any] = [:]

        for sample in samples {
            let date = sample.startDate
            let value = sample.quantity.doubleValue(for: HKUnit(from: "ms")) // Correct unit for HRV (milliseconds)
            hrvData[date.description] = value
        }

        return hrvData
    }


}
