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
    
    static let shared = TripStore()
    
    private init() {
        
        // TODO: TEMPORARY, remove!!!
        dummyPopulate()
    }
    
    @Published var currentTrip: Trip?
    @Published var upcomingTrips = [Trip]()
    @Published var previousTrips = [Trip]()
    
    func setCurrentTrip(currentTrip: Trip) {
        self.currentTrip = currentTrip
    }
    
    func finishCurrentTrip() -> Bool {
        
        // check if there's a trip to finish
        if currentTrip == nil {
            return false
        }
            
        self.previousTrips.append(self.currentTrip!)
        currentTrip = nil
        return true
    }
    
    func swapCurrentTrip(_ indexOfUpcomingTrips: Int) -> Bool {
        
        // check if there's a trip to swap out of
        if currentTrip == nil {
            return false
        }
        
        // check there's a valid upcoming trip at this index
        if indexOfUpcomingTrips < 0 || !(indexOfUpcomingTrips < self.upcomingTrips.count) {
            return false
        }
        
        // push swap currentTrip with upcomingTrips(index)
        self.upcomingTrips.append(currentTrip!)
        self.setCurrentTrip(currentTrip: self.upcomingTrips[indexOfUpcomingTrips])
        self.upcomingTrips.remove(at: indexOfUpcomingTrips)
        
        return true
    }
    
    func selectUpcomingTrip(upcomingTripsIndex: Int) -> Bool {
        
        // check there's a valid upcoming trip at this index
        if upcomingTripsIndex < 0 || !(upcomingTripsIndex < self.upcomingTrips.count) {
            return false
        }
        
        self.setCurrentTrip(currentTrip: upcomingTrips[upcomingTripsIndex])
        self.upcomingTrips.remove(at: upcomingTripsIndex)
        return true
    }
    
    func pushUpcomingTrip(newTrip: Trip) {
        
        self.upcomingTrips.append(newTrip)
    }
    
    // TODO: API call to backend for a trip (any type)
    
    func dummyPopulate() {
        
        let AnnArborTrip: Trip = Trip(city: "Ann Arbor", country: "USA", startDate: "10/7/2024", endDate: "10/10/2024", itinerary: getAnnArborItinerary())
        
        let parisTrip: Trip = Trip(city: "Paris", country: "France", startDate: "11/11/2024", endDate: "11/13/2024", itinerary: getParisItinerary())
        
        let newYorkTrip: Trip = Trip(city: "New York", country: "USA", startDate: "12/30/2024", endDate: "1/1/2025", itinerary: getNewYorkItinerary())
        
        self.currentTrip = AnnArborTrip
        self.upcomingTrips.append(contentsOf: [parisTrip, newYorkTrip])
    }
    

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


// surprisingly complex, not inlining in View
func getTripDateRange(tripStartDate: Date, tripEndDate: Date) -> String {
    
    let dateFormatter = DateFormatter()
    
    // get months
    dateFormatter.dateFormat = "LLLL"
    let startMonthString = dateFormatter.string(from: tripStartDate)
    let endMonthString   = dateFormatter.string(from: tripEndDate)
    
    // get days
    dateFormatter.dateFormat = "d"
    let startDayString = dateFormatter.string(from: tripStartDate)
    let endDayString = dateFormatter.string(from: tripEndDate)
    
    return startMonthString == endMonthString ?
    "\(startMonthString) \(startDayString) - \(endDayString)" :
    "\(startMonthString) \(startDayString) - \(endMonthString) \(endDayString)"
    
}

// TEMP HELPERS:
func parseTripDays(tripLength: Int, landmarks: [Landmark]) -> [[Landmark]] {
    
    var parsedLandmarks = [[Landmark]]()
    
    // append (tripLength) empty Lists to index directly
    for _ in 1...tripLength {
        parsedLandmarks.append([Landmark]())
    }
    
    // fill according to fed list
    for landmark in landmarks {
        
        var day: Int
        
        // safety
        if(landmark.Day2Visit == nil || landmark.Day2Visit! > tripLength) {
            day = 0
        }
        else {
            day = landmark.Day2Visit!
        }
        
        
        parsedLandmarks[day].append(landmark)
    }
    
    return parsedLandmarks
}


func getAnnArborItinerary() -> [[Landmark]] {
    
    let Landmarks: [Landmark] = [
    
            // Bell Tower
            Landmark(name: "Bell Tower",
                     message: "Ding Dong",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.2743155694, lon: -83.736413721),
                     Day2Visit:  0,
                     rating: 3),
            
            // UMich
            Landmark(name: "University of Michigan - Ann Arbor",
                     timestamp: "now",
                     geodata: GeoData(lat:  42.278564, lon: -83.737998),
                     Day2Visit:  0,
                     rating: 3),
            
            // Big House
            Landmark(name: "The Big House",
                     message: "Hail to The Victors!",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.265649, lon: -83.748443),
                     Day2Visit:  0,
                     rating: 3),
            
            // Arb
            Landmark(name: "Nichols Arboretum",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.280800, lon: -83.726784),
                     Day2Visit:  0),
            Landmark(name: "The Diag",
                     message: "Center of campus life",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.276045, lon: -83.738211),
                     Day2Visit:  1),
            // Gerald R. Ford Presidential Library
            Landmark(name: "Gerald R. Ford Presidential Library",
                     message: "A glimpse into U.S. presidential history",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.280791, lon: -83.739841),
                     Day2Visit:  1),

            // Kelsey Museum of Archaeology
            Landmark(name: "Kelsey Museum of Archaeology",
                     message: "Ancient and medieval artifacts on display",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.275652, lon: -83.735666),
                     Day2Visit:  2),

            // Matthaei Botanical Gardens
            Landmark(name: "Matthaei Botanical Gardens",
                     message: "Explore plant diversity in natural habitats",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.299780, lon: -83.662117),
                     Day2Visit:  3),

            // Power Center for the Performing Arts
            Landmark(name: "Power Center for the Performing Arts",
                     message: "Modernist architecture and performing arts venue",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.281538, lon: -83.738224),
                     Day2Visit:  3),

            // Ann Arbor Hands-On Museum
            Landmark(name: "Ann Arbor Hands-On Museum",
                     message: "Interactive science and technology exhibits",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.280684, lon: -83.747073),
                     Day2Visit:  3)
    ]
    
    return parseTripDays(tripLength: 4, landmarks: Landmarks)
}

func getParisItinerary() -> [[Landmark]] {
    
    let Landmarks: [Landmark] = [
    
            // Eiffel Tower
            Landmark(name: "Eiffel Tower",
                     message: "OMG",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.2743155694, lon: -83.736413721),
                     Day2Visit:  0,
                     rating: 3),
            
            // Louvre
            Landmark(name: "Louvre",
                     message: "art wow",
                     timestamp: "now",
                     geodata: GeoData(lat:  42.278564, lon: -83.737998),
                     Day2Visit:  0,
                     rating: 3),
            
            // Arc de Triomphe
            Landmark(name: "Arc de Triomphe",
                     message: "Big ol Arch",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.265649, lon: -83.748443),
                     Day2Visit:  1,
                     rating: 3),
            
            // Palace of Versailles
            Landmark(name: "Palace of Versailles",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.280800, lon: -83.726784),
                     Day2Visit:  2),
            
            // Random
            Landmark(name: "Landmark 1",
                     message: "sadness",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.276045, lon: -83.738211),
                     Day2Visit:  1),
            
    ]
    
    return parseTripDays(tripLength: 3, landmarks: Landmarks)
}

func getNewYorkItinerary() -> [[Landmark]] {
    
    let Landmarks: [Landmark] = [
    
            // Time Square
            Landmark(name: "Times Square",
                     message: "Ball Drop!",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.2743155694, lon: -83.736413721),
                     Day2Visit:  0,
                     rating: 3),
            
            // M&M's World
            Landmark(name: "M&M's World",
                     message: "I <3 chocolate",
                     timestamp: "now",
                     geodata: GeoData(lat:  42.278564, lon: -83.737998),
                     Day2Visit:  2,
                     rating: 3),
            
            // Broadway
            Landmark(name: "Broadway",
                     message: "Musicals!!!",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.265649, lon: -83.748443),
                     Day2Visit:  1,
                     rating: 3),
            
            // 42nd Street
            Landmark(name: "42nd Street",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.280800, lon: -83.726784),
                     Day2Visit:  2),
            
            // 43rd Street
            Landmark(name: "43rd Street",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.280800, lon: -83.726784),
                     Day2Visit:  1),
            
            // 44th Street
            Landmark(name: "44th Street",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.280800, lon: -83.726784),
                     Day2Visit:  0),
            
            // 45th Street
            Landmark(name: "45th Street",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.280800, lon: -83.726784),
                     Day2Visit:  2),
            
            // 46th Street
            Landmark(name: "46th Street",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.280800, lon: -83.726784),
                     Day2Visit:  0),
            
    ]
    
    return parseTripDays(tripLength: 3, landmarks: Landmarks)
}



