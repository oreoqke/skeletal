//
//  ChattStore.swift
//  swiftUIChatter
//
//  Created by Alexey Kovalenko on 1/22/24.
//

import Foundation
import Observation


final class LandmarkStore: ObservableObject {
    static let shared = LandmarkStore() // create one instance of the class to be shared
    
    // this is for the nearest locations
    @Published var nearest = [Landmark]()
    
    // instances can be created
    @Published var landmarks = [Landmark]()
    // TODO: FIXME get rid of this and fix setters and getters

    // private constructor (we don't actually want instances of this since dummy data)
    private init() {
        
        self.landmarks.append(contentsOf: [
            
            // Bell Tower
            Landmark(name: "Bell Tower", 
                     message: "Ding Dong",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.2743155694, lon: -83.736413721),
                     Day2Visit:  1,
                     rating: 3),
            
            // UMich
            Landmark(name: "University of Michigan - Ann Arbor", 
                     timestamp: "now",
                     geodata: GeoData(lat:  42.278564, lon: -83.737998),
                     Day2Visit:  1,
                     rating: 3),
            
            // Big House
            Landmark(name: "The Big House", 
                     message: "Hail to The Victors!",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.265649, lon: -83.748443),
                     Day2Visit:  1,
                     rating: 3),
            
            // Arb
            Landmark(name: "Nichols Arboretum", 
                     timestamp: "now",
                     geodata: GeoData(lat: 42.280800, lon: -83.726784),
                     Day2Visit:  1),
            Landmark(name: "The Diag",
                     message: "Center of campus life",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.276045, lon: -83.738211),
                     Day2Visit:  2),
            // Gerald R. Ford Presidential Library
            Landmark(name: "Gerald R. Ford Presidential Library",
                     message: "A glimpse into U.S. presidential history",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.280791, lon: -83.739841),
                     Day2Visit:  2),

            // Kelsey Museum of Archaeology
            Landmark(name: "Kelsey Museum of Archaeology",
                     message: "Ancient and medieval artifacts on display",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.275652, lon: -83.735666),
                     Day2Visit:  3),

            // Matthaei Botanical Gardens
            Landmark(name: "Matthaei Botanical Gardens",
                     message: "Explore plant diversity in natural habitats",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.299780, lon: -83.662117),
                     Day2Visit:  4),

            // Power Center for the Performing Arts
            Landmark(name: "Power Center for the Performing Arts",
                     message: "Modernist architecture and performing arts venue",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.281538, lon: -83.738224),
                     Day2Visit:  4),

            // Ann Arbor Hands-On Museum
            Landmark(name: "Ann Arbor Hands-On Museum",
                     message: "Interactive science and technology exhibits",
                     timestamp: "now",
                     geodata: GeoData(lat: 42.280684, lon: -83.747073),
                     Day2Visit:  4)

        ])
    }
    
    private let nFields = Mirror(reflecting: Landmark()).children.count
    
    // FIX the URL TODO: FIXME
//    private let serverUrl = "https://3.22.222.79/"
    
    // TODO: ADD AUTHORIZATION. USE WanderHubID.shared.id TO SEND REQUEST TO BACKEND
    func removeLandmark(id: String) async {
        
        // TODO: Call backend to remove the landmark from the itinerary
        
        landmarks.removeAll{ $0.id == id }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: id) else {
            print("addUser: jsonData serialization error")
            return
        }

        guard let token = UserDefaults.standard.string(forKey: "usertoken") else {
            return
        }
        guard let apiUrl = URL(string:  "\(serverUrl)remove-from-itinerary/") else {
            print("remove landmarks: bad URL")
            return
        }
        var request = URLRequest(url: apiUrl)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept") // expect response in JSON
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")

        request.httpBody = jsonData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("onboard: HTTP STATUS: \(httpStatus.statusCode)")
                print("Response:")
                print(response)
                return
            }
            print("Response:")
            print(response)

        } catch {
            print("Error: \(error.localizedDescription)")
            return
        }

    }
    
    func submitRating(rating: Int, id: String) async {
        var landmark2Rate = landmarks.first { $0.id == id }
        landmark2Rate?.rating = rating
        //make a post request to rate the landmark
    }
    
    func getNearest() async {
        
        
    }
    
    func getLandmarksDay(day: Int?) async {
        await getLandmarks(ItinId: 1)
    }

    // TODO: ADD AUTHORIZATION. USE WanderHubID.shared.id TO SEND REQUEST TO BACKEND
    func getLandmarks(ItinId: Int) async {

        let jsond = [ "ItineraryId": ItinId ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsond) else {
            print("addUser: jsonData serialization error")
            return
        }

        
        // get the token
        guard let token = UserDefaults.standard.string(forKey: "usertoken") else {
            return
        }
        guard let apiUrl = URL(string:  "\(serverUrl)get-itinerary-details/") else {
            print("remove landmarks: bad URL")
            return
        }
        var request = URLRequest(url: apiUrl)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept") // expect response in JSON
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")

        request.httpBody = jsonData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("onboard: HTTP STATUS: \(httpStatus.statusCode)")
                print("Response:")
                print(response)
                return
            }
            print("Response:")
            print(response)
            
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("getChatts: failed JSON deserialization")
                return
            }
            print(jsonObj)
            // this might be something diffferent
            let chattsReceived = jsonObj["chatts"] as? [[String?]] ?? []
            

        } catch {
            print("Error: \(error.localizedDescription)")
            return
        }

        return
        
        //        guard let apiUrl = URL(string: "\(serverUrl)getmaps/") else {
        //            print("getChatts: Bad URL")
        //            return
        //        }
        //
        //        var request = URLRequest(url: apiUrl)
        //        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept") // expect response in JSON
        //        request.httpMethod = "GET"
        //
        //        URLSession.shared.dataTask(with: request) { data, response, error in
        //            guard let data = data, error == nil else {
        //                print("getChatts: NETWORKING ERROR")
        //                return
        //            }
        //            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
        //                print("getChatts: HTTP STATUS: \(httpStatus.statusCode)")
        //                return
        //            }
        //
        //            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
        //                print("getChatts: failed JSON deserialization")
        //                return
        //            }
        //            let chattsReceived = jsonObj["chatts"] as? [[String?]] ?? []
        //
        //            DispatchQueue.main.async {
        //                self.chatts = [Chatt]()
        //                for chattEntry in chattsReceived {
        //                    if chattEntry.count == self.nFields {
        //                        let geoArr = chattEntry[3]?.data(using: .utf8).flatMap {
        //                            try? JSONSerialization.jsonObject(with: $0) as? [Any]
        //                        }
        //                        self.chatts.append(Chatt(username: chattEntry[0],
        //                                                message: chattEntry[1],
        //                                                timestamp: chattEntry[2],
        //                                                 geodata: geoArr.map {
        //                                                    GeoData(lat: $0[0] as! Double,
        //                                                            lon: $0[1] as! Double,
        //                                                            place: $0[2] as! String,
        //                                                            facing: $0[3] as! String,
        //                                                            speed: $0[4] as! String)
        //                                                 }
        //                        ))
        //                    } else {
        //                        print("getChatts: Received unexpected number of fields: \(chattEntry.count) instead of \(self.nFields).")
        //                    }
        //                }
        //            }
        //        }.resume()
    }
    
    
    // TODO: ADD AUTHORIZATION. USE WanderHubID.shared.id TO SEND REQUEST TO BACKEND
    func postLandmark(_ landmark: Landmark, completion: @escaping () -> ()) async {
        
        // TODO: FIXME IMPLEMENT ME
        return
        //        var geoObj: Data?
        //        if let geodata = chatt.geodata {
        //            geoObj = try? JSONSerialization.data(withJSONObject: [geodata.lat, geodata.lon, geodata.place, geodata.facing, geodata.speed])
        //        }
        //
        //        let jsonObj = ["username": chatt.username,
        //                       "message": chatt.message,
        //                       "geodata": (geoObj == nil) ? nil : String(data: geoObj!, encoding: .utf8)]
        //
        //        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
        //            print("postChatt: jsonData serialization error")
        //            return
        //        }
        //
        //        guard let apiUrl = URL(string: "\(serverUrl)postmaps/") else {
        //            print("postChatt: Bad URL")
        //            return
        //        }
        //
        //        var request = URLRequest(url: apiUrl)
        //        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        //        request.httpMethod = "POST"
        //        request.httpBody = jsonData
        //
        //        URLSession.shared.dataTask(with: request) { data, response, error in
        //            guard let _ = data, error == nil else {
        //                print("postChatt: NETWORKING ERROR")
        //                return
        //            }
        //
        //            if let httpStatus = response as? HTTPURLResponse {
        //                if httpStatus.statusCode != 200 {
        //                    print("postChatt: HTTP STATUS: \(httpStatus.statusCode)")
        //                    return
        //                } else {
        //                    completion()
        //                }
        //            }
        //
        //        }.resume()
        //    }
        
    }
}
