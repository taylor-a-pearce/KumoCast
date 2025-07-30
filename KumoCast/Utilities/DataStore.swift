//
//  DataStore.swift
//  KumoCast
//
//  Created by Taylor on 7/12/25.
//

import Foundation
import os

@Observable
class DataStore {
    var forPreviews: Bool
    var cities: [City] = []
    let filemanager = FileManager()
    private let citiesURL = FileManager.documentsDir.appendingPathComponent("cities.json", conformingTo: .json)

    init(forPreviews: Bool = false) {
        self.forPreviews = forPreviews
        loadCities()
    }
    func loadCities() {
        if forPreviews {
            cities = City.mockCityList
        } else {
            if filemanager.fileExists(at: citiesURL) {
                do {
                    let data = try filemanager.readData(from: citiesURL)
                    cities = try JSONDecoder().decode([City].self, from: data)
                    Logger.cache.debug("Loaded \(self.cities) cities from cities.json")
                } catch {
                    Logger.cache.error("Failed to load cities from cities.json: \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }

    func saveCities() {
        if !forPreviews {
            do {
                let data = try JSONEncoder().encode(cities)
                try filemanager.saveData(data, to: citiesURL)
                Logger.cache.debug("Saved \(self.cities) cities to cities.json")
            } catch {
                Logger.cache.error("Failed to save cities to cities.json: \(error.localizedDescription, privacy: .public)")
            }
        }
    }
}
