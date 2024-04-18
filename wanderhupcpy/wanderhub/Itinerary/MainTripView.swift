//
//  MainTripView.swift
//  wanderhub
//
//  Created by Alexey Kovalenko on 3/23/24.
//

import Foundation
import SwiftUI

struct CurrentTripView: View {
    
    @Binding var trip: Trip?
    @ObservedObject var viewModel: NavigationControllerViewModel
    
    var body: some View {
        VStack {
            
            Text("Current Trip")
                .font(.title2)
                .foregroundColor(orangeCol)
                .padding(.bottom, -8)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .frame(height: 3)
                .overlay(orangeCol)
            
            // there is a current trip
            if let currentTrip = self.trip {
                
//                let city = currentTrip.city
//                let county = currentTrip.country
//                let dateRange = getTripDateRange(tripStartDate: currentTrip.startDate, tripEndDate: currentTrip.endDate)
//                
                NavigationLink(destination: ItineraryView(viewModel: viewModel)) {
                    TripCardView(trip: currentTrip)
                }
//                .background(backCol)
            }
            
            // no current trip
            else {
                Text("No Current Trip")
                    .font(.title2)
                    .foregroundColor(greyCol)
                    .padding(.bottom, -8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            
        } // VStack
        
    } // body
    
} // currentTripView

struct SingleUpcomingTripView: View {
    
    @State var index: Int
    @Binding var landmark: Landmark
    
    var body: some View {
        VStack {
            
        }
    }
}

struct MainTripView: View {
    
    @StateObject var tripStore = TripStore.shared
    @ObservedObject var viewModel: NavigationControllerViewModel
    
    var body: some View {
        NavigationStack{
            VStack {
                Text("Your Trips")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(titleCol)
                    .padding(.bottom, -8)
                
                //                Divider()
                //                    .overlay(titleCol)
                //                    .frame(width: 250, height: 3)
                //                    .padding(.bottom, -8)
                
                
                // Current Trip, Previous Trips
                CurrentTripView(trip: $tripStore.currentTrip, viewModel: viewModel)
                
                // Upcoming Trips
                VStack {
                    
                    Text("Upcoming Trips")
                        .font(.title2)
                        .foregroundColor(greyCol)
                        .padding(.bottom, -8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                        .frame(height: 3)
                        .overlay(greyCol)
                    
                    // upcomingTrips[] is empty
                    if(tripStore.upcomingTrips.count == 0) {
                        Text("No Upcoming Trips")
                            .font(.title2)
                            .foregroundColor(greyCol)
                            .padding(.bottom, -8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // write out upcoming trips
                    else {
                        
                        ForEach(Array(tripStore.upcomingTrips.enumerated()), id: \.element.city) { index, upcomingTrip in
                            
                            TripCardView(trip: upcomingTrip)
//                            let city = upcomingTrip.city
//                            let county = upcomingTrip.country
//                            let dateRange = getTripDateRange(tripStartDate: upcomingTrip.startDate, tripEndDate: upcomingTrip.endDate)
//                            
//                            NavigationLink(destination: ItineraryView(viewModel: viewModel)) {
//                                OptionCardView(optionTitle: "\(city), \(county)", iconName: "list.bullet", backgroundColor: Color.green)
//                            }
//                            .background(backCol)
                        }
                    }
                    
                }
                
//                VStack {
//                    
//                    Text("Add New Trip")
//                        .font(.title2)
//                        .foregroundColor(titleCol)
//                        .padding(.bottom, -8)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    
//                    Divider()
//                        .frame(height: 3)
//                        .overlay(titleCol)
//                    
//                    NavigationLink(destination: BookingView(viewModel: viewModel)) {
//                        OptionCardView(optionTitle: "Start New Trip", iconName: "plus.circle.fill", backgroundColor: Color.blue)
//                    }
//                }
                
                
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

struct TripCardView: View {
    
    @State var trip: Trip
    @State var dateRange: String
    
    init(trip: Trip) {
        self.trip = trip
        self.dateRange = getTripDateRange(tripStartDate: trip.startDate, tripEndDate: trip.endDate)
    }
    
    var body: some View {
        
        HStack {
            
            // Image of Trip
            VStack {
                Image("umich")
                    .resizable()
                    .frame(width: 100.0, height: 100)
            }
            .padding()
            
            Spacer()
            
            // Trip Details
            VStack {
                
                HStack {
                    // Trip City
                    Text("\(self.trip.city), \(self.trip.country)")
                        .multilineTextAlignment(.center)
                        .font(Font.body)
                        .fontWeight(.bold)
                        .foregroundColor(orangeCol)
                }
                
                
                // Trip Dates
                Text(self.dateRange)
                    .font(Font.body)
                    .foregroundColor(Color.gray)
            }
            Spacer()
            
        }
        .padding()
        .background(Color(red: 0.9, green: 0.9, blue: 0.9, opacity: 1))
        .cornerRadius(20)
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

