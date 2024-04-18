//
//  Onboard.swift
//  wanderhub
//
//  Created by Neha Tiwari on 3/24/24.
//

import SwiftUI

struct Preference {
    let name: String
    var isSelected: Bool
}

struct Onboard: View {
    @Binding var signinProcess: Bool
    @Binding var showDismiss: Bool
//    private let selectedRowColor = Color.blue.opacity(0.3) // You can adjust the opacity and color as needed

    @State private var preferences: [Preference] = [
        Preference(name: "Art", isSelected: false),
        Preference(name: "Architecture", isSelected: false),
        Preference(name: "Beach", isSelected: false),
        Preference(name: "Entertainment", isSelected: false),
        Preference(name: "Food", isSelected: false),
        Preference(name: "Hiking", isSelected: false),
        Preference(name: "History", isSelected: false),
        Preference(name: "Mountains", isSelected: false),
        Preference(name: "Museum", isSelected: false),
        Preference(name: "Music", isSelected: false),
        Preference(name: "Recreation", isSelected: false),
        Preference(name: "Scenic Views", isSelected: false),
        Preference(name: "Sports", isSelected: false),
    ]
    
    var body: some View {
        VStack {
            VStack(spacing: 10) {
                Text("Hello \(User.shared.username ?? "User")")
                    .font(Font.custom("Poppins", size: 20))
                    .foregroundColor(titleCol)
                Text("What do you like to do?")
                    .font(Font.custom("Poppins", size: 19))
                    .foregroundColor(orangeCol)
            }
            
            VStack {
                List(preferences.indices, id: \.self) { index in
                    Toggle(isOn: self.binding(for: index)) {
                        Text(self.preferences[index].name)
                        
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .listRowSeparator(.hidden)
                    .listRowBackground(backCol)
//                    .listRowBackground(self.preferences[index].isSelected ? selectedRowColor : Color.clear)

                }
                .scrollContentBackground(.hidden)
                
            }
            
            Button(action: {
                sendPreferencesToBackend()
                showDismiss.toggle()
                signinProcess.toggle()
                
            }) {
                VStack(spacing: 10) {
                    Image("arrow_right")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .padding(EdgeInsets(top: 30, leading: 40, bottom: 0, trailing: 40))
        .background(backCol)
        
    }
    
    private func binding(for index: Int) -> Binding<Bool> {
        Binding(
            get: { self.preferences[index].isSelected },
            set: { newValue in
                self.preferences[index].isSelected = newValue
            }
        )
    }
    
    
    private func sendPreferencesToBackend() {
        // Code to send selected preferences to backend via API call
        let selectedPreferencesDict = preferences.reduce(into: [String: Int]()) { result, preference in
            result[preference.name] = preference.isSelected ? 1 : 0
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: selectedPreferencesDict, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Selected preferences JSON: \(jsonString)")
            } else {
                print("Error converting dictionary to JSON string")
            }
        } catch {
            print("Error converting dictionary to JSON: \(error)")
        }


    }
    
}

//struct Onboard_Previews: PreviewProvider {
//    static var previews: some View {
//        Onboard()
//    }
//}
