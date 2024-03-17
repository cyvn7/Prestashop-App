//
//  PaymentSelectionView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 14/03/2021.
//

import SwiftUI
import SwiftyJSON
import Alamofire

struct CarrierSelectionView: View {
    let supportedCarriers = [17, 18]
    @State public var carrierSelected = Carrier(id: Int(), name: String(), delay: String())
    @State var carriers = [Carrier]()
    //@State var carriers = [Int : Carrier]()

    var body: some View {
        VStack(alignment: .leading) {
//            let keys = carriers.map{$0.key}
//            let values = carriers.map {$0.value}
            
            Text("Wybierz dostawę")
                .font(.title)
                .fontWeight(.semibold)
                .padding()
//            List(keys.indices) { index in
//                Button(action: {self.carrierSelected = keys[index]}, label: {
//                    HStack {
//                        VStack(alignment: .leading) {
//                            Text(values[index].name)
//                                .font(.title2)
//                                .fontWeight(.semibold)
//                            Text(values[index].delay)
//                                .font(.title3)
//                        }
//                        if keys[index] == carrierSelected {
//                            Spacer()
//                            Image(systemName: "checkmark")
//                        }
//                    }.foregroundColor(keys[index] == carrierSelected ? .orange : CColor.dark)
//                })
//            }
            
            List(carriers.indices, id: \.self) { index in
                Button(action: {self.carrierSelected = carriers[index]}, label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(carriers[index].name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text(carriers[index].delay)
                                .font(.title3)
                        }
                        if carriers[index] == carrierSelected {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }.foregroundColor(carriers[index] == carrierSelected ? .orange : CColor.dark)
                })
            }
            if supportedCarriers.contains(carrierSelected.id) {
                HStack {
                    NavigationLink(destination: AddressSelectionView(carrierSelected: carrierSelected), label: {
                        Spacer()
                        Text("Dalej")
                        Image(systemName: "arrowtriangle.right.circle.fill")
                        Spacer()
                    }).padding().accentColor(CColor.bright).background(CColor.dark)
                    
                }
            }
        }.onAppear(perform: getOptions)
    }
    
    func getOptions() {
        let link = "\(globalURL)/carriers?\(apiKey)&io_format=JSON&display=full&filter[deleted]=[0]&filter[active]=[1]"
        if carriers.isEmpty {
            AF.request(link, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print(json)
                    for (_,subJson):(String,JSON) in json["carriers"] {
                        if supportedCarriers.contains(subJson["id"].intValue) {
                            self.carriers.append((id: subJson["id"].intValue, name: subJson["name"].stringValue, delay: subJson["delay"].stringValue))
                            print("added")
                        }
                    }
                    print(carriers)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

struct PaymentSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CarrierSelectionView()
    }
}
