//
//  wanderhubApp.swift
//  wanderhub
//
//  Created by Hasan Zengin on 3/12/24.
//

import SwiftUI
import AVFoundation

@main
struct wanderhubApp: App {
    init() {
        LocManager.shared.startUpdates()
        //Uncomment to require log in every time (clears out defaults)
//        if let appDomain = Bundle.main.bundleIdentifier {
//            UserDefaults.standard.removePersistentDomain(forName: appDomain)
//        }
        UserDefaults.standard
        Task {
            await LandmarkStore.shared.getLandmarks(day: 1)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Onboard()
            //testView()
            //StartupPage()
            //HomeView()
            //UserProfileView()
        }
    }
}

