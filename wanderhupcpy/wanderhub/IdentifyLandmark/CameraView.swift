//
//  PostView.swift
//  swiftUIChatter
//
//  Created by Neha Tiwari on 2/5/24.
//
import SwiftUI

struct CameraView: View {
    @ObservedObject var viewModel: NavigationControllerViewModel
    
    private let username = "tiwarin"
    @State private var message = "Some short sample text."
    @State private var image: UIImage? = nil
    @State private var videoUrl: URL? = nil
    @State private var isPresenting = false
    @State private var sourceType: UIImagePickerController.SourceType? = nil
    
    var body: some View {
        VStack {
            HStack{
                Spacer()
                Button(action: submitAction) {
                    Image(systemName: "paperplane")
                        .padding(EdgeInsets(top: 6, leading: 50, bottom: 20, trailing: 30))
                        .scaleEffect(1.2)
                }
                .foregroundColor(.black)
            }
//            Text("Hello \(User.shared.username ?? "User")")
//                .padding(.top, 30.0)
//                .foregroundColor(titleCol)
//                .font(Font.custom("Poppins", size: 26).weight(.semibold))
            Spacer().frame(height:200)
            VStack () {
                GeometryReader { geometry in
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: geometry.size.height * 0.5)
                            .frame(width: geometry.size.width * 0.5)
                            .frame(maxWidth: .infinity, alignment: .center)
//                            .padding(.trailing, 18)
                    }
                }
            }
            Spacer().frame(height:100)
            HStack(spacing: 23) {
                ZStack() {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 166, height: 84)
                        .background(Color(red: 1, green: 0.83, blue: 0.51))
                        .cornerRadius(10)
                        .offset(x: 0, y: 0)
                    CameraButton()
                }
                
                ZStack() {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 165, height: 84)
                        .background(Color(red: 1, green: 0.83, blue: 0.51))
                        .cornerRadius(10)
                        .offset(x: 0, y: 0)
                    AlbumButton()
                    
                    
                }
                
            }
            Spacer().frame(height:25)
//            CameraButton()
//            Spacer().frame(height:100)
//            AlbumButton()
            
            Spacer()
            ChildNavController(viewModel: viewModel)
        }
        .background(backCol)
        .navigationTitle("Identify Landmark")

        .fullScreenCover(isPresented: $isPresenting) {
            ImagePicker(sourceType: $sourceType, image: $image)
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    @ViewBuilder
    func SubmitButton() -> some View {
        Button(action: submitAction) {
            Image(systemName: "paperplane")
                .padding(EdgeInsets(top: 6, leading: 60, bottom: 20, trailing: 0))
                .scaleEffect(1)
        }
        .foregroundColor(.black)
        
    }
    
    func submitAction() {
        // Create a new Chatt object with the message, image, and geoData if available
        let geoData = GeoData(lat: 0.0, lon: 0.0, place: "Unknown", facing: "Unknown", speed: "Unknown")
        let imagedata = ImageData(username: username, timestamp: Date().description, imageUrl: nil, geoData: geoData)
        
        // Call the postChatt function to send the post request
        Task {
            let _ = await ImageStore.shared.postImage(imagedata, image: image)
            print("success")
            print(imagedata)
        }
    }
    
    @ViewBuilder
    func CameraButton() -> some View {
        Button {
            sourceType = .camera
            isPresenting.toggle()
        } label: {
            HStack{
                Image(systemName: "camera")
                    .scaleEffect(1.2)
            Text("Take picture")
            }
            .foregroundColor(orangeCol)
            }
    }
    
    @ViewBuilder
    func AlbumButton() -> some View {
        Button {
            sourceType = .photoLibrary
            isPresenting.toggle()
        } label: {
            HStack{
                
                Image(systemName: "photo.on.rectangle")
                    .scaleEffect(1.2)
            
            Text("Camera Roll")
            }}
        .foregroundColor(orangeCol)
    }
}
