//
//  MainTripView.swift
//  wanderhub
//
//  Created by Alexey Kovalenko on 3/23/24.
//

import SwiftUI


struct Itinerary: Decodable {
    var id: Int
    var city_name: String
    var it_name: String
    var start_date: String
}

struct MainTripView: View {
    @ObservedObject var viewModel: NavigationControllerViewModel
    @ObservedObject var userItineraryStore = UserItineraryStore.shared // Observe the UserItineraryStore
    
    var body: some View {
        NavigationStack{
            VStack {
                Text("What's next?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                    .foregroundColor(titleCol)
                
                // Options for starting a new trip or viewing the current itinerary
                VStack {
                    NavigationLink(destination: BookingView(viewModel: viewModel)) {
                        OptionCardView(optionTitle: "Start New Trip", iconName: "plus.circle.fill", backgroundColor: Color.blue)
                    }
                    .background(backCol)
                    NavigationLink(destination: ItineraryView(viewModel: viewModel)) {
                        OptionCardView(optionTitle: "Current Itinerary", iconName: "list.bullet", backgroundColor: Color.green)
                    }
                    .background(backCol)
                    HStack {
                        Text("Upcoming Trips:")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(titleCol)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        
                        Button(action: {
                            Task {
                                await userItineraryStore.getUpcomingTrips()
                            }
                        }) {
                            Text("Refresh")
                                .foregroundColor(.blue)
                                .padding(.trailing)
                        }
                    }
                    
                    ScrollView(showsIndicators: false) {
                        ForEach(userItineraryStore.itineraries, id: \.id) { itinerary in
                            
                            HStack{
                                VStack(alignment: .leading) {
                                    Text(itinerary.it_name).font(.headline)
                                    Text("\(itinerary.city_name), \(itinerary.start_date)").font(.subheadline)
                                }
                                
                            }
                            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .frame(width: 370, height: 96)
                            .background(Color(red: 0.94, green: 0.92, blue: 0.87))
                            .cornerRadius(8)
                            .shadow(
                                color: Color(red: 0.71, green: 0.74, blue: 0.79, opacity: 0.12), radius: 16, y: 6
                            )
                        }
                    }
                }
            }
            .background(backCol)
            .padding()
            
            Spacer()
            ChildNavController(viewModel: viewModel)
        }
        .background(backCol)
        .navigationDestination(isPresented: $viewModel.NavigatingToCurrentTrip) {
            ItineraryView(viewModel: viewModel)
        }
        
    }
}




struct OptionCardView: View {
    var optionTitle: String
    var iconName: String
    var backgroundColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .padding()
                .background(backgroundColor)
                .cornerRadius(25)
            
            Text(optionTitle)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(orangeCol)
            
            Spacer()
        }
        .padding()
        .frame(height: 80)
        .background(navBarCol)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}



class UserItineraryStore :ObservableObject {
    
    static let shared = UserItineraryStore()
    private init() {}
    @Published var itineraries: [Itinerary] = [] // Use @Published here instead of @ObservedObject
    
    func getUpcomingTrips() async {
        
        guard let apiUrl = URL(string: "\(serverUrl)get-user-itineraries/") else { // TODO REPLACE URL
            print("addUser: Bad URL")
            return
        }
        guard let token = UserDefaults.standard.string(forKey: "usertoken") else {
            return
        }
        var request = URLRequest(url: apiUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept") // expect response in JSON
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("get upcoming trips: HTTP STATUS: \(httpStatus.statusCode)")
                print("Response:")
                print(response)
                return
            }
            
            print("get nearby  trips::")
            //            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
            //                print("addUser: failed JSON deserialization")
            //                return
            //            }
            let decoder = JSONDecoder()
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let landmarksArray = jsonObject["itineraries"] as? [[String: Any]] else {
                    print("Failed to parse JSON data")
                    return
                }
                print(landmarksArray)
                
                let decodedLandmarks = try landmarksArray.map { landmarkDict in
                    return try JSONDecoder().decode(Itinerary.self, from: JSONSerialization.data(withJSONObject: landmarkDict))
                }
                
                DispatchQueue.main.async {
                    self.itineraries = decodedLandmarks
                }
                
            } catch {
                print("Error decoding JSON: \(error)")
            }
            
        } catch {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        
        return
        
    }
    
    func getTripDetails() async {
        
        guard let apiUrl = URL(string: "\(serverUrl)get-user-itineraries/") else { // TODO REPLACE URL
            print("addUser: Bad URL")
            return
        }
        guard let token = UserDefaults.standard.string(forKey: "usertoken") else {
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept") // expect response in JSON
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("get upcoming trips: HTTP STATUS: \(httpStatus.statusCode)")
                print("Response:")
                print(response)
                return
            }
            print("Response:")
            print(response)
            print("get upcoming trips::")
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("addUser: failed JSON deserialization")
                return
            }
            print(jsonObj)
            
        } catch {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        
        return
        
    }
    
    
    
}



