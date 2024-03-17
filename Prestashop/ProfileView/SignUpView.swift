//
//  SignUpView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 16/03/2021.
//

import SwiftUI
import SwiftyJSON
import Alamofire

struct SignUpView: View {
    @State var psswd = String()
    @State var firstname = String()
    @State var lastname = String()
    @State var email = String()
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Welcome\nuser")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.leading)
                    Spacer()
                } .padding(.bottom, 1)
                HStack {
                    Text("Sign up to join")
                        .font(.callout)
                        .fontWeight(.light)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.gray)
                    Spacer()
                }.padding(.bottom)
                CustomTextField(name: "Firstname", text: $firstname)
                CustomTextField(name: "Lastname", text: $lastname)
                CustomTextField(name: "E-mail", text: $email)
                CustomTextField(name: "Password", text: $psswd)
                Button(action: {addUser()}) {
                    Spacer()
                    Text("Sign up")
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(20.0)
                .foregroundColor(.white)
                .background(CColor.purpleGradient)
                .cornerRadius(15)
                Spacer()
                Text("By signing up, you agree to our terms of use and privacy policy")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding()
            }
            .padding()
            .navigationBarTitle("SIGN UP", displayMode: .inline)
        }
    }
    
    func addUser() {
        let strToXML = "<prestashop xmlns:xlink='http://www.w3.org/1999/xlink'><customer><id_default_group>3</id_default_group><passwd>\(psswd)</passwd><lastname>\(lastname)</lastname><firstname>\(firstname)</firstname><email>\(email)</email><active>1</active></customer></prestashop>"
        let url = URL(string:"\(globalURL)/customers/?\(apiKey)&ps_method=POST&io_format=JSON")
        
        var xmlRequest = URLRequest(url: url!)
        xmlRequest.httpBody = strToXML.data(using: String.Encoding.utf8, allowLossyConversion: true)
        xmlRequest.httpMethod = "POST"
        xmlRequest.addValue("application/xml", forHTTPHeaderField: "Content-Type")
        
        
        AF.request(xmlRequest).responseJSON() { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                let defaults = UserDefaults.standard
                defaults.set(json["customer"]["id"].intValue, forKey: "userID")
                defaults.set(json["customer"]["lastname"].stringValue, forKey: "userLastname")
                defaults.set(json["customer"]["firstname"].stringValue, forKey: "userFirstname")
                
            case .failure(let error):
                print(error)
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
