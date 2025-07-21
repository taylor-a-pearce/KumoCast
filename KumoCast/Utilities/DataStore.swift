//
//  DataStore.swift
//  KumoCast
//
//  Created by Taylor on 7/12/25.
//

import Foundation

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
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func saveCities() {
        if !forPreviews {
            do {
                let data = try JSONEncoder().encode(cities)
                try filemanager.saveData(data, to: citiesURL)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func saveWeatherBundle() {
        if !forPreviews {
            do {
                let data = try JSONEncoder().encode(cities)
                try filemanager.saveData(data, to: citiesURL)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
