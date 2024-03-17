//
//  ProfileView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 14/03/2021.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct ProfileView: View {
    @AppStorage("totalPrice") var localTotalPrice: Double = 0
    @AppStorage("itemsBadge") var itemsBadge: Int = 0
    @State var isLoggined = false
    @State var username = "Ładowanie..."
    @State var userID = Int()
    @State var isAlertOn = false
    let defaults = UserDefaults.standard
    private let categories = ["Informacje", "Adresy", "Historia zamówień"]
    
    var body: some View {
        VStack {
            if isLoggined == true {
                NavigationView {
                    VStack {
                        Text(username)
                            .font(.title)
                        List {
                            NavigationLink(destination: AddressesView(userID: userID)) {
                                Text("Adresy")
                            }
                            NavigationLink(destination: OrdersView()) {
                                Text("Zamówienia")
                            }
                            Button(action: {self.isAlertOn = true}) {
                                Text("Usuń konto")
                                    .foregroundColor(Color.red)
                            }
                            NavigationLink(destination: SwiftUIWebView(url: URL(string: "https://support.tpay.com/pl/developerr/openapi/tworzenie-transakcji-przez-api"))) {
                                Text("debug_webview")
                            }
                        }
                    }
                    .navigationBarItems(trailing:
                        Button(action: logOut) {
                            Text("Wyloguj się")
                        }
                    )
                }
                .accentColor(CColor.dark)
            } else {
                StartScreen()
            }
        }.onAppear(){
            if let name = self.defaults.string(forKey: "userFirstname") {
                print("appeared")
                self.username = "Witaj, " + name + " " + self.defaults.string(forKey: "userLastname")!
                self.userID = self.defaults.integer(forKey: "userID")
                self.isLoggined = true
            }
        }
        .alert(isPresented: $isAlertOn) {
            Alert(title: Text("Uwaga!"), message: Text("Czy na pewno chcesz usunąć konto?"), primaryButton: .destructive(Text("Usuń"), action: removeUser), secondaryButton: .cancel())
        }
    }
    
    func logOut() {
        defaults.removeObject(forKey: "userID")
        defaults.removeObject(forKey: "userFirstname")
        defaults.removeObject(forKey: "userLastname")
        defaults.removeObject(forKey: "cartID")
        defaults.removeObject(forKey: "totalPrice")
        defaults.removeObject(forKey: "cartDict")
        localTotalPrice = 0
        itemsBadge = 0
        isLoggined = false
    }
    
    func removeUser() {
        AF.request("\(globalURL)/customers/\(defaults.integer(forKey: "userID"))/?\(apiKey)&io_format=JSON&ps_method=DELETE", method: .delete).validate().responseData { response in
            self.logOut()
        }
    }
    
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
