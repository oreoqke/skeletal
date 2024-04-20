//
//  AudioView.swift
//  wanderhub
//
//  Created by Alexey Kovalenko on 4/11/24.
//

import SwiftUI
import Observation

// Feel free to add more into audio View so it can display the text, etc.
struct AudioView: View {
    @Binding var isPresented: Bool
    @Environment(AudioPlayer.self) private var audioPlayer
    let textToSpeechScript: String // Added property

//    let myscript = """
//    (Black screen with text; The sound of buzzing bees can be heard) According to all known laws
//    of aviation,
//     :
//    there is no way a bee
//    should be able to fly.
//     :
//    Its wings are too small to get
//    its fat little body off the ground.
//     :
//    The bee, of course, flies anyway
//     :
//    because bees don't care
//    what humans think is impossible.
//    BARRY BENSON:
//    (Barry is picking out a shirt)
//    Yellow, black. Yellow, black.
//    Yellow, black. Yellow, black.
//     :
//    Ooh, black and yellow!
//    Let's shake it up a little.
//    JANET BENSON:
//    Barry! Breakfast is ready!
//    BARRY:
//    Coming!
//     :
//    Hang on a second.
//    (Barry uses his antenna like a phone)
//     :
//    Hello?
//    ADAM FLAYMAN:
//    
//    (Through phone)
//    - Barry?
//    BARRY:
//    - Adam?
//    ADAM:
//    - Can you believe this is happening?
//    BARRY:
//    - I can't. I'll pick you up.
//    (Barry flies down the stairs)
//    """
    
    var body: some View {
        VStack {
            // view to be defined
            Spacer()
            HStack {
                if audioPlayer.waiting_for_response {
                    VStack{
                        Text("Text to Speech loading")
                        ProgressView()
                    }
                }
                else {
                    Spacer()
                    StopButton()
                    Spacer()
                    RwndButton()
                    Spacer()
                    PlayButton()
                    Spacer()
                    FfwdButton()
                    Spacer()
                }
//                Spacer()
//                DoneButton(isPresented: $isPresented)
            }
            Spacer()
        }
        
        
        
        .onAppear {
            audioPlayer.txt2speech(text: textToSpeechScript) {
                print("sone speaking")
            }
        }
        .onDisappear {
            audioPlayer.doneTapped()
        }
    }
}



@Observable
final class PlayerUIState {
    
    
    var playCtlDisabled = true
    var playDisabled = true
    var playIcon = Image(systemName: "play")
    
    var doneIcon = Image(systemName: "xmark.square") // initial value
    
    private func reset() {
        
        
        playCtlDisabled = true
        
        playIcon = Image(systemName: "play")
        
        
    }
    
    private func playCtlEnabled(_ enabled: Bool) {
        playCtlDisabled = !enabled
    }
    
    private func playEnabled(_ enabled: Bool) {
        playIcon = Image(systemName: "play")
        playDisabled = !enabled
    }
    
    private func pauseEnabled(_ enabled: Bool) {
        playIcon = Image(systemName: "pause")
        playDisabled = !enabled
    }
    
    
    func propagate(_ playerState: PlayerState) {
        switch (playerState) {
        case .start(.play):
            playEnabled(true)
            playCtlEnabled(false)
            doneIcon = Image(systemName: "xmark.square")
        case .start(.standby):
            playEnabled(true)
            playCtlEnabled(false)
        case .paused:
            playIcon = Image(systemName: "play")
        case .playing:
            pauseEnabled(true)
            playCtlEnabled(true)
        }
    }
}


struct DoneButton: View {
    @Binding var isPresented: Bool
    @Environment(AudioPlayer.self) private var audioPlayer
    
    var body: some View {
        Button {
            audioPlayer.doneTapped()
            isPresented.toggle()
        } label: {
            audioPlayer.playerUIState.doneIcon.scaleEffect(2.0).padding(.trailing, 40)
        }
    }
}

//Implement StopButtion
struct StopButton: View {
    @Environment(AudioPlayer.self) private var audioPlayer
    
    var body: some View {
        Button {
            audioPlayer.stopTapped()
        } label: {
            Image(systemName: "stop")
                .scaleEffect(2.0)
                .padding(.trailing, 20)
        }
        .disabled(audioPlayer.playerUIState.playCtlDisabled)
    }
}

//Implement RwndButton
struct RwndButton: View {
    @Environment(AudioPlayer.self) private var audioPlayer
    
    var body: some View {
        Button {
            audioPlayer.rwndTapped()
        } label : {
            Image(systemName: "gobackward.10")
                .scaleEffect(2.0)
                .padding(.trailing, 20)
        }
        .disabled(audioPlayer.playerUIState.playCtlDisabled)
    }
}

//Implement FfwdButton
struct FfwdButton: View {
    @Environment(AudioPlayer.self) private var audioPlayer
    
    var body: some View {
        Button {
            audioPlayer.ffwdTapped()
        } label : {
            Image(systemName: "goforward.10")
                .scaleEffect(2.0)
                .padding(.trailing, 20)
        }
        .disabled(audioPlayer.playerUIState.playCtlDisabled)
    }
}

//Implement PlayButton
struct PlayButton: View {
    @Environment(AudioPlayer.self) private var audioPlayer
    
    var body: some View {
        if audioPlayer.waiting_for_response {
            ProgressView()
        } else {
            Button {
                audioPlayer.playTapped()
            } label: {
                audioPlayer.playerUIState.playIcon
                    .scaleEffect(2.0)
                    .padding(.trailing, 20)
            }
        }
    }
}
