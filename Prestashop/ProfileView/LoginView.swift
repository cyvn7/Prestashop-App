//
//  LoginView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 15/03/2021.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct LoginView: View {
    @State var login = String()
    @State var password = String()
    @State private var btnText = "Sign in"
    @State private var isDisabled = false
    @State private var showingAlert = false
    @State private var isPwdCorrect = false
    
    var body: some View {
        VStack {
            Text("logo")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.bottom, 60.0)
            
            CustomTextField(name: "Login", text: $login)
            
            CustomTextField(name: "", text: $password, isPassword: true)
            
            NavigationLink(destination: ProfileView(), isActive: $isPwdCorrect) {
                Button(action: {self.checkPwd()}) {
                    Spacer()
                    Text("Sign in")
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(20.0)
                .foregroundColor(.white)
                .background(CColor.purpleGradient)
                .cornerRadius(15)
            }
            .disabled(isDisabled)
            Button(action: {print("BUTTON PRESSED: Sign In with Apple")}) {
                Spacer()
                Image(systemName: "applelogo")
                Text("Sign in with Apple")
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(20.0)
            .foregroundColor(CColor.bright)
            .background(CColor.dark)
            .cornerRadius(15)
            Button(action: {print("BUTTON PRESSED: Sign In with Facebook")}) {
                Spacer()
                Text("Sign in with Facebook")
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(20.0)
            .foregroundColor(.white)
            .background(CColor.fbBlue)
            .cornerRadius(15)
            Spacer()
        }
        .padding()
        .navigationBarTitle("LOG IN", displayMode: .inline)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Błąd"), message: Text("Nieprawidłowy login lub hasło"), dismissButton: .default(Text("OK")))
        }
    }
    
    func checkPwd() {
        btnText = "Ładowanie..."
        isDisabled = true
        AF.request("\(globalURL)/customers/?\(apiKey)&io_format=JSON&filter[email]=[\(login)]&display=full", method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json["customers"][0]["passwd"])
                if json["customers"][0]["passwd"].stringValue != "" {
                    //TODO: Better password checking
                    //do {
                        //let result = try BCrypt.Hash.verify(message: pwd, matches: json["customers"][0]["passwd"].stringValue)
                        //if result == true {
                            let defaults = UserDefaults.standard
                            defaults.set(json["customers"][0]["id"].intValue, forKey: "userID")
                            defaults.set(json["customers"][0]["lastname"].stringValue, forKey: "userLastname")
                            defaults.set(json["customers"][0]["firstname"].stringValue, forKey: "userFirstname")
                            print(json["customers"][0])
                            self.isPwdCorrect = true
                        //}
//                    } catch {
//                        print(error)
//                        self.showingAlert = true
//                        self.isDisabled = false
//                    }
                    //let result = try BCrypt.Hash.verify(message: pwd, matches: encryptedPwd)
                }
            case .failure(let error):
                print(error)
                self.showingAlert = true
                self.isDisabled = false
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
