import SwiftUI
import MapKit
import Observation

struct Destination {
    var destination: String
    var city: String
    var country: String
    var interests: String
    var startDate: Date = Date()
    var endDate: Date = Date()
}


class Destinations: ObservableObject {
    @Published var destinations: [Destination]
    init() {
        do{
            self.destinations = []
            Task{
                await get_destinations()
            }
        }
    }
    
    func get_destinations() async  {
    //   self.destinations = [destination1, destination2, destination3, destination4]
       
        guard let apiUrl = URL(string: "\(serverUrl)destinations/") else { // TODO REPLACE URL
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
            print("get destinations::")
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

struct HomeView: View {
    @State var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State var selected: Landmark?
    @StateObject var viewmodel = NavigationControllerViewModel()
    @ObservedObject var destinations = Destinations()
    
    init () {
        Task {
           // await LandmarkStore.shared.getLandmarks(day: 1)
            await UserHistoryStore.shared.getHistory()
            await UserItineraryStore.shared.getUpcomingTrips() // Call getUpcomingTrips here

        }
    }
    
    var body: some View {
            VStack() {
                // This uses hardcoded spacing value from the top
                GreetUser()
                
                //Search Bar if Needed
                SearchBarViewControllerRepresentable()
                    .frame(height: 44)
                    .offset(x: 0, y: 30)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                
                QuickAccess()
                
                HStack{
                    Text("Destinations for you")
                        .font(Font.custom("Poppins", size: 18).weight(.semibold))
                        .foregroundColor(Color(red: 0, green: 0.15, blue: 0.71))
                        .offset(x: 10, y: 40)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                
                DisplayDestinations()
                
                
                Spacer()
                
                MainNavController(viewModel: viewmodel)
                Spacer()
                    .frame(height:15)
                
            }
            .background(backCol)
    }
    
    @ViewBuilder
    private func DisplayDestinations()-> some View {
            ScrollView(showsIndicators: false) {
                ForEach(destinations.destinations, id: \.destination){ destination in
                    NavigationLink(destination: BookingView(viewModel: viewmodel,
                                                            destination: destination.destination,
                                                            city: destination.city,
                                                            country: destination.country,
                                                            interests: destination.interests) ) {
                        DisplayDestination(destination: destination)
                    }
                }
            }
            .refreshable {
                Task{
                  await destinations.get_destinations()
                }
            }
            .offset(x: 0, y: 40)
    }
    
    @ViewBuilder
    private func DisplayDestination(destination: Destination)-> some View {
        HStack() {
            Image(systemName: "airplane.departure")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading){
                Text(destination.destination).font(.headline)
                Text("\(destination.city), \(destination.country)").font(.subheadline)
                Text(destination.interests)
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
    
    
    @ViewBuilder
    private func GreetUser() -> some View {
        Spacer().frame(height: 75)
        HStack(){
            Spacer().frame(width: 5)
            Text("Hello \(User.shared.username ?? "User")")
                .font(Font.custom("Poppins", size: 26).weight(.bold))
                .foregroundColor(Color(red: 0, green: 0.15, blue: 0.71))
                .offset(x: 10, y: 30)
                .frame(alignment: .leading)
            Spacer()
            
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    // Display Quick Access buttons:
    // Go to current Trip and Explore Nearby
    @ViewBuilder
    private func QuickAccess() -> some View {
        HStack(spacing: 23) {
            ZStack() {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 166, height: 84)
                    .background(Color(red: 1, green: 0.83, blue: 0.51))
                    .cornerRadius(10)
                    .offset(x: 0, y: 0)
                
                NavigationLink(destination: ItineraryView(viewModel: viewmodel)) {
                    Text("Go to current trip")
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(Color(red: 0.96, green: 0.40, blue: 0.33))
                }
                
                // Switch it if
//                Button(action: {
//                    viewmodel.viewState = ViewState.itinerary
//                    viewmodel.isPresented = true
//                    viewmodel.NavigatingToCurrentTrip = true
//                }) {
//                    Text("Go to current trip")
//                        .font(Font.custom("Poppins", size: 16).weight(.medium))
//                        .foregroundColor(Color(red: 0.96, green: 0.40, blue: 0.33))
//                    
//                }
            }
            
            ZStack() {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 165, height: 84)
                    .background(Color(red: 1, green: 0.83, blue: 0.51))
                    .cornerRadius(10)
                    .offset(x: 0, y: 0)
                Button(action: {
                    viewmodel.viewState = ViewState.map(nil)
                    viewmodel.isPresented = true
                }) {
                    Text("Explore Nearby")
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(Color(red: 0.96, green: 0.40, blue: 0.33))
                    
                }
                
                
            }
            
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        .frame(width: 393, height: 86)
        .offset(x: 0, y: 50)
    }
    
   
 
}




// Create individual Destination objects
let destination1 = Destination(
    destination: "Great Wall of China",
    city: "Beijing",
    country: "China",
    interests: "Historical sites, Hiking, Photography",
    startDate: Date(),  // Initialized to the current date
    endDate: Date()     // Initialized to the current date
)

let destination2 = Destination(
    destination: "Eiffel Tower",
    city: "Paris",
    country: "France",
    interests: "Architecture, Culture, Dining",
    startDate: Date(),  // Initialized to the current date
    endDate: Date()     // Initialized to the current date
)

let destination3 = Destination(
    destination: "Grand Canyon",
    city: "Flagstaff",
    country: "USA",
    interests: "Nature, Hiking, Photography",
    startDate: Date(),  // Initialized to the current date
    endDate: Date()     // Initialized to the current date
)

let destination4 = Destination(
    destination: "Santorini",
    city: "Thera",
    country: "Greece",
    interests: "Beaches, Sunsets, History",
    startDate: Date(),  // Initialized to the current date
    endDate: Date()     // Initialized to the current date
)

