//
//  Trip.swift
//  wanderhub
//
//  Created by Vivianna Mahtab on 4/18/24.
//

import Foundation
import Observation

final class Trip: ObservableObject {
    
    // Geodata on trip
    var city: String
    var country: String
    
    // Date information about trips
    var lengthOfTrip: Int
    var startDate: Date
    var endDate:   Date
    
    // Landmarks to visit during trip
    var itinerary: [[Landmark]] // Landmark[Day #][Landmark #] => one landmark
    
    
    init(city: String, country: String, startDate: String, endDate: String, itinerary: [[Landmark]]) {
        self.city = city
        self.country = country
        self.itinerary = itinerary
        
        self.startDate = getDateObject(startDate)
        self.endDate = getDateObject(endDate)
        
        let tripTimeInterval = self.endDate.timeIntervalSince1970 - self.startDate.timeIntervalSince1970
        self.lengthOfTrip = Int(tripTimeInterval / 86400)
    }
    
} // class Trip

final class TripStore: ObservableObject {
    
    public static let shared = TripStore()
    
    private init() {
        // lmao
    }
    
    @Published var currentTrip: Trip?
    @Published var upcomingTrips: [Trip]?
    @Published var previousTrips: [Trip]?
    
    func setCurrentTrip(currentTrip: Trip) {
        self.currentTrip = currentTrip
    }
    
    // TODO: push/pop from upcoming and previous trips
    
    // TODO: swap upcoming trip with current trip
    
    // TODO: API call to backend for a trip (any type)
    

} // class TripStore




// Requires @param: dateString to be in format:: MM/DD/YYYY
func getDateObject(_ dateString: String) -> Date {
    
    var components = DateComponents()
    
    let dateArr = dateString.split(separator: "/")
    components.month = Int(dateArr[0]) ?? 0
    components.day   = Int(dateArr[1]) ?? 0
    components.year  = Int(dateArr[2]) ?? 0
    
    let calendar = Calendar.current
    return calendar.date(from: components)!
}


