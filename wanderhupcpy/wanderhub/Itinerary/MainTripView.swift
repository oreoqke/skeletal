//
//  MainTripView.swift
//  wanderhub
//
//  Created by Alexey Kovalenko on 3/23/24.
//

import SwiftUI

struct MainTripView: View {
    @ObservedObject var viewModel: NavigationControllerViewModel
    
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
                print("onboard: HTTP STATUS: \(httpStatus.statusCode)")
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
    


