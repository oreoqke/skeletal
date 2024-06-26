//
//  SignUp.swift
//  wanderhub
//
//  Created by Alexey Kovalenko on 3/23/24.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var email:    String = ""
    
    var user = User.shared
    @Binding var signinProcess: Bool
    
    @State private var showAlert = false
    @State private var loginFailed = false
    
    @State private var navigateToOnboarding = false
    @State private var showDismiss = false
    func signup() {
        if username.isEmpty || password.isEmpty || email.isEmpty {
            showAlert = true
            return
        }
        Task {
            do {
                if let _ = await user.signup(username: username, password: password, email: email) {
                    navigateToOnboarding = true
                    signinProcess.toggle()
//                    presentationMode.wrappedValue.dismiss()
                } else {
                    loginFailed = true
                }
            }
        }
        
    }
    
    var body: some View {
        NavigationView{
            VStack {
                Spacer()
                    .frame(height: 200)
                Text("Find your next trip")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(titleCol)
                
                TextField("Enter name", text: $username)
                    .autocapitalization(.none)
                    .foregroundColor(greyCol)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 1)
                            .foregroundColor(greyCol)
                    )
                    .padding(.horizontal, 40)
                
                SecureField("Enter password", text: $password)
                    .autocapitalization(.none)
                    .foregroundColor(greyCol)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 1)
                            .foregroundColor(greyCol)
                    )
                    .padding(.horizontal, 40)
                
                TextField("Enter Email", text: $email)
                    .autocapitalization(.none)
                    .foregroundColor(greyCol)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 1)
                            .foregroundColor(greyCol)
                    )
                    .padding(.horizontal, 40)
                
                Button("Sign Up") {
                    //IF you don't want to sign up uncomment this
//                    navigateToOnboarding = true
//                    signinProcess.toggle()
                    signup()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(backCol)
                .cornerRadius(10)
                .padding(.horizontal, 40)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text("Username and password cannot be empty"), dismissButton: .default(Text("OK")))
                }
                .alert(isPresented: $loginFailed) {
                    Alert(title: Text("Error"), message: Text("Signup Failed"), dismissButton: .default(Text("OK")))
                }
                
                .fullScreenCover(isPresented: $navigateToOnboarding) {
                    Onboard(signinProcess: $navigateToOnboarding, showDismiss: $showDismiss)
                    
               }
                if showDismiss {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        signinProcess.toggle()
                    } label: {
                        Text("Sign Up Successful!")
                            .bold()
                            .foregroundColor(titleCol)
                        Text("Start planning my trip")
                    }
                }
                
                
                
                Spacer()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backCol)
            .edgesIgnoringSafeArea(.all)
        }
    }
}
