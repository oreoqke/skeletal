//
//  UserProfileView.swift
//  wanderhub
//
//  Created by Neha Tiwari on 3/24/24.
//

import SwiftUI
import Foundation
import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: NavigationControllerViewModel
    @ObservedObject var userHistorystore = UserHistoryStore.shared
    @State private var isDataLoaded = false
    
    @State private var refreshID = UUID()
    @State var identified: [LandmarkVisit]
    
    
    var body: some View {
        VStack{
            GreetUser()
            ProfileOptions()
            HStack{
                Text("Past Landmarks:")
                    .font(Font.custom("Poppins", size: 16).weight(.semibold))
                    .foregroundColor(Color(red: 0.96, green: 0.40, blue: 0.33))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 352, height: 39)
            VStack {
                    List(identified.indices, id: \.self) { index in
                        LandmarkListRow(visit: identified[index])
                            .listRowSeparator(.hidden)
                            .listRowBackground(backCol)
                            .id(refreshID)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        printLandmarkVisits()
                        refreshID = UUID()
                        Task {
                            await userHistorystore.getHistory()
                            identified = UserHistoryStore.shared.visitedPlaces()
                        }
                    }
                .frame(maxHeight: .infinity)
            }
            .onAppear {
                Task {
                    await userHistorystore.getHistory()
                    identified = UserHistoryStore.shared.visitedPlaces()
                }
                
                
            }
            .onChange(of: userHistorystore.landmarkVisits) {  oldValue, newValue in
                refreshID = UUID() // Update UUID to force redraw
            }
            
            Spacer()
            ChildNavController(viewModel: viewModel)
        }
        .background(backCol)

    }
    
    @ViewBuilder
    private func GreetUser()-> some View {
        HStack(spacing: 161) {
            Text("Hello \(User.shared.username ?? "User")")
                .font(Font.custom("Poppins", size: 26).weight(.semibold))
                .foregroundColor(Color(red: 0, green: 0.15, blue: 0.71))
                .frame(maxWidth: .infinity, alignment: .leading) //
        }
        .frame(width: 352, height: 39)
    }
    
    @ViewBuilder
    private func ProfileOptions()-> some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack(spacing: 12) {
                Text("Settings")
                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                    .foregroundColor(Color(red: 0.96, green: 0.40, blue: 0.33))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 16))
            .frame(width: 343)
            .background(Color(red: 0.94, green: 0.92, blue: 0.87))
            .cornerRadius(10)
            
            HStack(spacing: 12) {
                Text("Preferences")
                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                    .foregroundColor(Color(red: 0.96, green: 0.40, blue: 0.33))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 16))
            .frame(width: 343)
            .background(Color(red: 0.94, green: 0.92, blue: 0.87))
            
            HStack(spacing: 12) {
                Text("FAQs")
                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                    .foregroundColor(Color(red: 0.96, green: 0.40, blue: 0.33))
                    .frame(maxWidth: .infinity, alignment: .leading) //
            }
            .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 16))
            .frame(width: 343)
            .background(Color(red: 0.94, green: 0.92, blue: 0.87))
            .cornerRadius(10)
        }
        .frame(width: 356, height: 170)
        .background(Color(red: 0.94, green: 0.92, blue: 0.87))
        .cornerRadius(10)
    }
    

    
    private func printLandmarkVisits() {
        print("tetsign from profile view",userHistorystore.landmarkVisits)
    }
}



struct LandmarkListRow: View {
    let visit: LandmarkVisit
    
    var body: some View {
        HStack() {
            if let urlString = visit.image_url, let imageUrl = URL(string: urlString) {
                                            AsyncImage(url: imageUrl) {
                                                $0.resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                .frame(width: 60, height: 60)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .scaledToFit()
                                            .frame(height: 181)
            } else {
                Image(systemName: "airplane.departure")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading){
                Text(visit.landmark_name).font(.headline)
                Text("\(visit.city_name), \(visit.country_name)").font(.subheadline)
                if visit.description != "Unknown" {
                            Text("\(visit.description), \(visit.tags.joined(separator: ", "))")
                }              
//                if let visitDate = getDateObject(visit.visit_date, visit.visit_time) {
//                    let formattedDate = formatDate(visitDate)
//                    print(formattedDate) // Output: "Apr 20, 2029 4:00 PM"
//                } else {
//                    print("Invalid date or time format")
//                }
                Text("\(visit.rating)/5, \(visit.visit_time)")
                
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .frame(width: 370, height: 96)
        .background(Color(red: 0.94, green: 0.92, blue: 0.87))
        .cornerRadius(8)
        .shadow(
            color: Color(red: 0.71, green: 0.74, blue: 0.79, opacity: 0.12), radius: 16, y: 6
        )
        
    }
//    
//    func formatDate(_ String: Date) -> String {
//        let components = dateTimeString.components(separatedBy: " ")
//
//        // Extract date and time components
//        let dateString = components[0] // "2024-04-22"
//        let timeString = components[1] // "01:25:30"
//
//        print("Date: \(dateString)")
//        print("Time: \(timeString)")
//        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM d, yyyy h:mm a"
//        return formatter.string(from: date)
//    }
}
