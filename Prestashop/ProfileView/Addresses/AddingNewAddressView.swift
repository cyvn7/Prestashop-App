//
//  AddingNewAddressView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 14/03/2021.
//

import SwiftUI
import Alamofire

struct AddingNewAddressView: View {
    @State var alias = String()
    @State var name = String()
    @State var surname = String()
    @State var address = String()
    @State var zip = String()
    @State var city = String()
    @State var phoneNumber = String()
    @Environment(\.presentationMode) var presentationMode
    var userID : Int

    var body: some View {
        VStack {
            Text("Uzupełnij adres")
                .font(.largeTitle)
                .padding()
            
            ScrollView {
                CustomTextField(name: "Alias", text: $alias)
                CustomTextField(name: "Name", text: $name)
                CustomTextField(name: "Surname", text: $surname)
                CustomTextField(name: "Address", text: $address)
                CustomTextField(name: "ZIP Code", text: $zip)
                CustomTextField(name: "City", text: $city)
                CustomTextField(name: "Phone number", text: $phoneNumber)
            }.padding()
            
            Button(action: addAddress) {
                Spacer()
                Text("Dodaj")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(height: 60)
                Spacer()
            }
            .background(CColor.purpleGradient)
            .cornerRadius(15)
            .padding(10)
            .navigationBarTitle("", displayMode: .inline)
        }.onAppear(){self.getUserData()}
    }
    
    func getUserData() {
        let defaults = UserDefaults.standard
        name = defaults.string(forKey: "userFirstname")!
        surname = defaults.string(forKey: "userLastname")!
    }
    
    func addAddress() {
        let xmlAddress = "<prestashop xmlns:xlink='http://www.w3.org/1999/xlink'><address><id_customer xlink:href='\(globalURL)/customers/\(userID)'>\(userID)</id_customer><id_country xlink:href='\(globalURL)/countries/14'>14</id_country><alias>\(alias)</alias><lastname>\(surname)</lastname><firstname>\(name)</firstname><address1>\(address)</address1><postcode>\(zip)</postcode><city>\(city)</city><phone>\(phoneNumber)</phone></address></prestashop>"
        
        let url = URL(string:"\(globalURL)/addresses/?\(apiKey)&ps_method=POST")
        var xmlRequest = URLRequest(url: url!)
        xmlRequest.httpBody = xmlAddress.data(using: String.Encoding.utf8, allowLossyConversion: true)
        xmlRequest.httpMethod = "POST"
        xmlRequest.addValue("application/xml", forHTTPHeaderField: "Content-Type")


        AF.request(xmlRequest).responseData { (response) in
            self.presentationMode.wrappedValue.dismiss()
        }
        
    }
}

struct AddingNewAddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddingNewAddressView(userID: 0)
    }
}
