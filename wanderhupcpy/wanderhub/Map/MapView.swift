//
//  MapView.swift
//  swiftUIChatter
//
//  Created by Alexey Kovalenko on 3/22/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel: NavigationControllerViewModel
    @Binding var cameraPosition: MapCameraPosition
    let landmark: Landmark?
    @State var selected: Landmark?
    
    var body: some View {
        VStack {
            Map(position: $cameraPosition, selection: $selected) {
                if let landmark {
                    if let geodata = landmark.geodata {
                        Marker(landmark.name!, systemImage: "figure.wave",
                               coordinate: CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon))
                        .tint(.red)
                        .tag(landmark)
                    }
                } else {
                    ForEach(LandmarkStore.shared.landmarks, id: \.self) { landmark in
                        if let geodata = landmark.geodata {
                            Marker(landmark.name!, systemImage: "figure.wave",
                                   coordinate: CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon))
                            .tint(.mint)
                        }
                    }
                }
                if let landmark = selected, let geodata = landmark.geodata {
                    Annotation(landmark.name!, coordinate: CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon), anchor: .topLeading
                    ) {
                        InfoView(landmark: landmark)
                    }
                    .annotationTitles(.hidden)
                }
                
                UserAnnotation() // shows user location
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
        }
        Spacer()
        ChildNavController(viewModel: viewModel)
    }
}

struct InfoView: View {
    let landmark: Landmark
    
    var body: some View {
        VStack(alignment: .leading) {
                
                if let name = landmark.name, let message = landmark.message {
                    // Landmark Name
                    Text(name)
                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 0, trailing: 0))
                        .font(.system(size: 16))
                        .lineLimit(2, reservesSpace: true)
                    Spacer()
                    Text(message)
                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 0, trailing: 4))
                        .font(.system(size: 12))
                        .lineLimit(2, reservesSpace: true)
                }
                
                else if let name = landmark.name {
                    // Landmark Name
                    // Optional Description Message
                    Text(name)
                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 0, trailing: 0))
                        .font(.system(size: 16))
                        .lineLimit(2, reservesSpace: true)
                }
        }
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .cornerRadius(4.0)
        }
        .frame(width: 300)
    }
}
