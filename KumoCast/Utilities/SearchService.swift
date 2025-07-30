//
//  SearchService.swift
//  KumoCast
//
//  Created by Taylor on 7/12/25.
//

import MapKit
import os

class SearchService: NSObject, MKLocalSearchCompleterDelegate {
    private let completer: MKLocalSearchCompleter
    var cities: [City] = []

    init(completer: MKLocalSearchCompleter) {
        self.completer = completer
        super.init()
        self.completer.delegate = self
    }

    func update(queryFragment: String) {
        Logger.search.debug("Updating search query with fragment: \(queryFragment, privacy: .public)")
        completer.resultTypes = [.address]
        completer.queryFragment = queryFragment
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Logger.search.debug("Received \(completer.results.count) search completion results")
        cities = completer.results.compactMap { completion in
            if let mapItem = completion.value(forKey: "_mapItem") as? MKMapItem {
                return City(
                    name: completion.title,
                    latitude: mapItem.placemark.coordinate.latitude,
                    longitude: mapItem.placemark.coordinate.longitude
                )
            } else {
                return nil
            }
        }
    }

}
