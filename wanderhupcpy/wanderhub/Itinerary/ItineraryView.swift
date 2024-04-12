//
//  ItineraryView.swift
//  wanderhub
//
//  Created by Vivianna Mahtab on 3/17/24.
//

import Foundation
import SwiftUI
import _MapKit_SwiftUI


// TODO: get a date object dynamically from backend
// takes in format ""DD/MM/YYYY", "hh:mm"
func getDateObject(_ date: String, _ time: String) -> Date {
    
    var components = DateComponents()
    
    let date_arr = date.split(separator: "/")
    let time_arr = time.split(separator: ":")
    
    components.month = Int(date_arr[0]) ?? 0
    components.day   = Int(date_arr[1]) ?? 0
    components.year  = Int(date_arr[2]) ?? 0
    
    components.hour   = Int(time_arr[0]) ?? 0
    components.minute = Int(time_arr[1]) ?? 0
    
    let calendar = Calendar.current
    return calendar.date(from: components)!
}



struct ItineraryDropViewDelegate: DropDelegate {
    
    let destinationLandmark: Landmark
    @Binding var landmarks: [Landmark]
    @Binding var draggedLandmark: Landmark?
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedLandmark = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        if let draggedLandmark {
            let fromIndex = landmarks.firstIndex(of: draggedLandmark)
            
            if let fromIndex {
                let toIndex = landmarks.firstIndex(of: destinationLandmark)
                
                if let toIndex, fromIndex != toIndex {
                    withAnimation {
                        self.landmarks.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex))
                    }
                }
            }
        }
    }
}

struct ItineraryHeaderView: View {
    
    // TODO: get this data from backend
    @State var tripName: String = "Paris"
    @State var tripStartDate: Date = getDateObject("11/11/2023", "00:00")
    @State var tripEndDate:   Date = getDateObject("11/15/2023", "00:00")
    
    // surprisingly complex, not inlining in View
    func getTripDateRange() -> String {
        
        let dateFormatter = DateFormatter()
        
        // get months
        dateFormatter.dateFormat = "LLLL"
        let startMonthString = dateFormatter.string(from: tripStartDate)
        let endMonthString   = dateFormatter.string(from: tripEndDate)
        
        dateFormatter.dateFormat = "dd"
        let startDayString = dateFormatter.string(from: tripStartDate)
        let endDayString = dateFormatter.string(from: tripEndDate)
        
        return startMonthString == endMonthString ?
        "\(startMonthString) \(startDayString) - \(endDayString)" :
        "\(startMonthString) \(startDayString) - \(endMonthString) \(endDayString)"
        
    }
    
    var body: some View {
        
        HStack {
            
            // Image of Trip
            VStack {
                Image("umich")
                    .resizable()
                    .frame(width: 50.0, height: 50.0)
                    .foregroundColor(Color.yellow)
                
                //                Text("we need images ;-;\n\t- vivi <3").font(Font.caption)
            }
            .padding()
            
            Spacer()
            
            // Trip Details
            VStack {
                
                // Trip Name
                Text(self.tripName)
                    .multilineTextAlignment(.center)
                    .font(Font.title)
                    .foregroundColor(Color.blue)
                
                // Trip Datess
                Text(self.getTripDateRange())
                    .font(Font.body)
                    .foregroundColor(Color.gray)
            }
            Spacer()
            
        }
        .padding()
        .background(Color(red: 0.9, green: 0.9, blue: 0.9, opacity: 1))
        .cornerRadius(8)
    }
}

struct ItinerarySingleEntryView: View {
    
    @State var index: Int
    @Binding var landmark: Landmark
    
    var body: some View {
        HStack {
            VStack {
                
                // Landmark Name
                TextField("", text: Binding (get: {landmark.name ?? ""}, set: { _ in}))
                    .font(Font.title2)
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 1))
                    .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                
                // Optional Description Message
                TextField("", text: Binding (get: {landmark.message ?? ""}, set: { _ in}))
                    .font(Font.body)
                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7, opacity: 1))
                    .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            }
            Spacer()
            
            Button(action: {
                landmark.favorite.toggle()
                
            }) { // closure dynamically draws favorite star
                landmark.favorite ?
                Image(systemName: "star.fill")
                    .foregroundColor(Color.yellow) :
                Image(systemName: "star")
                    .foregroundColor(Color.blue)
            }
        }
        .padding()
        .background(Color(red: 0.9, green: 0.9, blue: 0.9, opacity: 1))
        .cornerRadius(8)
    }
}

struct ItinerarySingleEntryExpandedView: View {
    
    @State var index: Int
    @Binding var landmark: Landmark
    
    @ObservedObject var viewModel: NavigationControllerViewModel
    @StateObject var itineraryEntries = LandmarkStore.shared
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    
                    // Landmark Name
                    TextField("", text: Binding (get: {landmark.name ?? ""}, set: { _ in}))
                        .font(Font.title2)
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 1))
                        .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    
                    // Optional Description Message
                    TextField("", text: Binding (get: {landmark.message ?? ""}, set: { _ in}))
                        .font(Font.body)
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7, opacity: 1))
                        .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    
                }
                Spacer()
                
                Button(action: {
                    landmark.favorite.toggle()
                    
                }) { // closure dynamically draws favorite star
                    landmark.favorite ?
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.yellow) :
                    Image(systemName: "star")
                        .foregroundColor(Color.blue)
                }
            }
            
            HStack {
                Button(action: {
                    viewModel.itineraryDirectNavigation(landmark: landmark)
                }) {
                    Text("View on Map")
                        .font(Font.body)
                }
                .padding()
                .background(Color(red: 0, green: 0.5, blue: 0))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                
                Spacer()
                
                Button(action: {
                    itineraryEntries.removeLandmark(id: landmark.id)
                }) {
                    Text("Delete")
                        .font(Font.body)
                }
                .padding()
                .background(Color(red: 0.5, green: 0, blue: 0))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                
                Spacer()
                
                NavigationLink(destination: LandmarkView(viewModel: viewModel,
                                                         landmark: $landmark)){
                    Text("More...")
                        .font(Font.body)
                }
                .padding()
                .background(Color(.systemBlue))
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
           
        }
       
        .padding()
        .background(Color(red: 0.9, green: 0.9, blue: 0.9, opacity: 1))
        .cornerRadius(8)
    }
}

struct DayView: View {
    @Binding var day: Int
    
    
    @ObservedObject var viewModel: NavigationControllerViewModel
    // moving a landmark around
    @State var draggedLandmark: Landmark?
    
    // expanding information on individual landmark
    @State var expandedLandmark: Landmark?
    
    @StateObject var itineraryEntries = LandmarkStore.shared
    
    @State var landmarks: [Landmark] = []
    
    var body: some View {
        // itinerary list
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(Array(landmarks.enumerated()), id: \.element.id) { index, landmark in

                    Group {
                        if (self.expandedLandmark?.id == landmark.id)
                        {
                            ItinerarySingleEntryExpandedView(index: index, landmark: $landmarks[index], viewModel: viewModel, itineraryEntries: itineraryEntries)
                        }
                        else
                        {
                            ItinerarySingleEntryView(index: index, landmark: $landmarks[index])
                        }
                      }
                
                        .onDrag {
                            self.draggedLandmark = landmark
                            return NSItemProvider()
                        }
                        .onDrop(
                            of: [.text],
                            delegate: ItineraryDropViewDelegate(
                                destinationLandmark: landmark,
                                landmarks: $landmarks,
                                draggedLandmark: $draggedLandmark
                            ))
                    
                        .onTapGesture(count: 1) {
                            self.expandedLandmark = landmark
                        }
                }
            }
        }
        .onAppear{
            landmarks = getDay(day: day)
            print("\(landmarks)")
        }
        .onChange(of: day, initial: true, {
            landmarks = getDay(day: day)
        })
        .onChange(of: itineraryEntries.landmarks, initial: false, {
            landmarks = getDay(day: day)
        })
        .refreshable {
            // This refreshes the entire itinerary
            await itineraryEntries.getLandmarks(day: day)
            //this selects the places recommended for the day
        }
        .padding(.horizontal)
    }
    
    //Return Landmarks for a specific day
    func getDay(day: Int)-> [Landmark] {
        var results: [Landmark] = []
        for landmark in itineraryEntries.landmarks {
            if landmark.Day2Visit == day {
                results.append(landmark)
            }
        }
        return results
    }
    
}




struct ItineraryView: View {
    
    @State var days = [1,2,3,4,5,6,7, 9, 10, 11, 12]
    @State var selectedDay = 1
    
    @ObservedObject var viewModel: NavigationControllerViewModel
    
    // moving a landmark around
    @State var draggedLandmark: Landmark?
    
    // expanding information on individual landmark
    @State var expandedLandmark: Landmark?
    
    @StateObject var itineraryEntries = LandmarkStore.shared
    
    @State var newDescription: String = ""
    
    
    var body: some View {
        
        VStack {
            
            ItineraryHeaderView()
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                    Spacer()
                    ForEach(days, id: \.self) { day in
                        Button(action: {
                            print("\(day) was tapped")
                            selectedDay = day
                        }) {
                            Text("\(day)")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        Spacer()
                    }
                }
            }
            Spacer()
            DayView(day: $selectedDay, viewModel: viewModel)
            Spacer()
            Text("Add new destation")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(titleCol)
            
            TextField("Describe what you want to visit", text: $newDescription)
                .autocapitalization(.none)
                .foregroundColor(greyCol)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .foregroundColor(greyCol)
                )
                .padding(.horizontal, 40)
        }
        .background(backCol)
        Spacer()
        ChildNavController(viewModel: viewModel)
    }
}
