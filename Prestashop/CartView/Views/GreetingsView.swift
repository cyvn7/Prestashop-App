//
//  GreetingsView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 14/03/2021.
//

import SwiftUI
import Alamofire

struct GreetingsView: View {
    @State var isLoaded = true //zmien
    @AppStorage("itemsBadge") var itemsBadge: Int = 0
    var orderStr: String
    
    var body: some View {
        if isLoaded == false {
            ProgressView().onAppear(perform: makeOrder).navigationTitle("").navigationBarHidden(true)
        } else {
            VStack(alignment: .leading) {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                Text("Thank you for shopping")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
                HStack {
                    Button(action: {print("pressed")}, label: {
                        Spacer()
                        Text("Continue shopping")
                        Spacer()
                    })
                    .padding(20.0)
                    .foregroundColor(CColor.bright)
                    .background(CColor.purpleGradient)
                }
            }.navigationTitle("").navigationBarHidden(true)
        }
    }
    
    func makeOrder() {
        let defaults = UserDefaults.standard
        let url = URL(string: "\(globalURL)/orders?\(apiKey)&display=full&io_format=JSON&ps_method=POST")
        var xmlRequest = URLRequest(url: url!)
        xmlRequest.httpBody = orderStr.data(using: String.Encoding.utf8, allowLossyConversion: true)
        xmlRequest.httpMethod = "POST"
        xmlRequest.addValue("application/xml", forHTTPHeaderField: "Content-Type")


        AF.request(xmlRequest).responseJSON() { (response) in
            defaults.removeObject(forKey: "cartDict")
            defaults.removeObject(forKey: "cartID")
            self.itemsBadge = 0
            self.isLoaded = true
        }
    }
}

struct GreetingsView_Previews: PreviewProvider {
    static var previews: some View {
        GreetingsView(orderStr: "bhj")
    }
}
