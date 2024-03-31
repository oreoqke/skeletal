//
//  StartupPage.swift
//  wanderhub
//
//  Created by Alexey Kovalenko on 3/23/24.
//

import SwiftUI
import AVKit
import AVFoundation

struct StartupPage: View {
    @State private var isActive = false
    @State private var SigninPresented: Bool = true

    
    var body: some View {
        NavigationView{
            VStack {
                //Talk()
                var inputMessage = "The Eiffel Tower is a big metal tower in Paris, France. It was built in 1889 for a big fair called the World's Fair to show off France's engineering skills. It's named after Gustave Eiffel, the engineer whose company designed and built it. When it was first built, it was the tallest building in the world. It's 324 meters tall, that's like stacking about 81 stories of a building on top of each other! People from all over the world come to see it, making it one of the most visited monuments that you have to pay to enter. At first, not everyone liked it, but now it's a famous symbol of France. It has lights that make it sparkle at night, and you can go up to see a beautiful view of Paris."
                Button{
                    SpeechService.shared.speak(text: inputMessage) {
                        print("done")
                    }
                }label: {
                    Text("click me")
                }
                
//                if isActive {
//                    if SigninPresented {
//                        SigninView(isPresented: $SigninPresented)
//                    } else {
//                        HomeView()
//                    }
//                } else {
//                    Spacer()
//                    Text("WanderHub")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundColor(titleCol)
//                    Spacer()
//                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backCol)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
