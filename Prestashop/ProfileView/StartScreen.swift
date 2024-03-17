//
//  LoginView.swift
//  dynashop
//
//  Created by Maciej Przybylski on 22/07/2020.
//  Copyright © 2020 Maciej Przybylski. All rights reserved.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import FBSDKLoginKit

struct StartScreen: View {
    @AppStorage("logged") var logged = false
    @AppStorage("email") var email = "" //najpewniej do usunięcia
    @State var manager = LoginManager()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                
                Text("dynashop")
                    .multilineTextAlignment(.center)
                    .foregroundColor(CColor.dark)
                    .font(.system(size: 45))
                    .padding()
                
                Spacer()
                
                HStack {
                    NavigationLink(destination: LoginView()) {
                        Spacer()
                        Text("Log in")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(20.0)
                    .foregroundColor(CColor.fPurple)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(CColor.fPurple, lineWidth: 0.7)
                    )

                    Spacer()
                    NavigationLink(destination: SignUpView()) {
                        Spacer()
                        Text("Sign Up")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(20.0)
                    .foregroundColor(.white)
                    .background(CColor.fPurple)
                    .cornerRadius(15)
                }
                .padding(.bottom, 6.0)
                
                
//                Button(action: {
//                    Settings.setApi
//                    if logged {
//                        manager.logOut()
//                        email = ""
//                        logged = false
//                    } else {
//                        manager.logIn(permissions: ["public_profile","email"], from: nil) { (result,err) in
//                            if err != nil {
//                                print(err!.localizedDescription)
//                                return
//                            }
//                            logged = true
//                            
//                            let request = GraphRequest(graphPath: "me", parameters: ["fields" : "email"])
//                            
//                            request.start { (_, res, _) in
//                                guard let profileData = res as? [String : Any] else {return}
//                                print(profileData)
//                            }
//                        }
//                    }
//                    
//                    
//                }) {
//                    Spacer()
//                    Text("Sign in with Facebook")
//                    Spacer()
//                }
//                .padding(20.0)
//                .foregroundColor(.white)
//                .background(CColor.fbBlue)
            }
            .padding()
        }.accentColor(CColor.dark)
    }
            
}



struct StartScreen_Previews: PreviewProvider {
    static var previews: some View {
        StartScreen()
            .preferredColorScheme(.dark)
          //.environment(\.colorScheme, .dark)
    }
}
