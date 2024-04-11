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
//                //Talk()
//                var inputMessage = "The Eiffel Tower is a big metal tower in Paris, France."
//                Spacer()
//                Button{
//                    SpeechService.shared.speak(text: inputMessage) {
//                        print("done")
//                    }
//                }label: {
//                    Text("click me")
//                }
//                Spacer()
//                Button {
//                    SpeechService.shared.stopSpeaking()
//                } label: {
//                    Image(systemName: "stop.fill")
//                        .scaleEffect(3)
//                }
//                Spacer()
//                Button {
//                    SpeechService.shared.rewindPlayback(by: 10000)
//                } label: {
//                    Image(systemName: "backward.fill")
//                        .scaleEffect(3)
//                }
//                Spacer()
                
                if isActive {
                    if SigninPresented {
                        SigninView(isPresented: $SigninPresented)
                    } else {
                        HomeView()
                    }
                } else {
                    Spacer()
                    Text("WanderHub")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(titleCol)
                    Spacer()
                }
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
