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
    // @StateObject private var userHistoryStore = UserHistoryStore()
    // @State private var landmarkVisits: [LandmarkVisit] = []
    @ObservedObject var userHistorystore = UserHistoryStore.shared
    @State private var isDataLoaded = false
    // @State private var landmarkVisits: [LandmarkVisit]
    // @State private var landmarkVisits: [LandmarkVisit] = []
    let landmarkVisits = UserHistoryStore.shared.landmarkVisits
   
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
//                if isDataLoaded {
                    List(userHistorystore.landmarkVisits.indices, id: \.self) { index in
                        LandmarkListRow(visit: userHistorystore.landmarkVisits[index])
                            .listRowSeparator(.hidden)
                            .listRowBackground(backCol)
                    }
                    .listStyle(.plain)
                    .refreshable {
                       printLandmarkVisits()
                    }
//                } else {
//                    ProgressView()
//                }
            }
            
            Spacer()
            ChildNavController(viewModel: viewModel)
        }
        .background(backCol)
//        .onChange(of: isDataLoaded) { isLoaded in
//            if isLoaded {
//                isDataLoaded = true
//            }
//        }
//
//        .onAppear {
//            fetchLandmarkVisits()
//        }
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
    
    
//    private func fetchLandmarkVisits() {
//        Task {
//            if userHistorystore.getHistory() {
//                isDataLoaded = true
//            }
//            
//        }
//    }
    
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
                                        }//            Image(systemName: "airplane.departure")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading){
                Text(visit.landmark_name).font(.headline)
                Text("\(visit.city_name), \(visit.country_name)").font(.subheadline)
                Text(visit.visit_time)
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
}
