//
//  GetSleepData.swift
//  CareMate
//
//  Created by Soren Marcelino on 18/11/2023.
//

import Foundation
import HealthKit

class GetSleepData {
    private let healthStore = HKHealthStore()

    func getSleepData(completion: @escaping ([String: Any]?, Error?) -> Void) {
        // Check if HealthKit is available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(nil, HealthKitError.notAvailable)
            return
        }

        // Define the type of data you want to read (Sleep Analysis)
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!

        // Request authorization to read sleep data
        healthStore.requestAuthorization(toShare: nil, read: [sleepType]) { (success, error) in
            guard success else {
                completion(nil, error)
                return
            }

            // Predicate to query for sleep samples
            let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictStartDate)

            // Sort the query results by start date in descending order
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

            // Create a query to fetch sleep samples
            let query = HKSampleQuery(sampleType: sleepType,
                                      predicate: predicate,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }

                // Process sleep samples if available
                if let sleepSamples = samples as? [HKCategorySample] {
                    let sleepData = self.processSleepData(samples: sleepSamples)
                    completion(sleepData, nil)
                }
            }

            // Execute the query
            self.healthStore.execute(query)
        }
    }

    private func processSleepData(samples: [HKCategorySample]) -> [String: Any] {
        var sleepData: [String: Any] = [:]

        let dateFormatter = ISO8601DateFormatter()

        for sample in samples {
            let startDateString = dateFormatter.string(from: sample.startDate)
            let endDateString = dateFormatter.string(from: sample.endDate)
            let value = sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue ? "In Bed" : "Asleep"

            let entry: [String: Any] = [
                "startDate": startDateString,
                "endDate": endDateString,
                "value": value
            ]

            sleepData["\(startDateString)-\(endDateString)"] = entry
        }

        return sleepData
    }
}

enum HealthKitError: Error {
    case notAvailable
}

