//
//  AddressSelectionView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 14/03/2021.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct AddressSelectionView: View {
    var carrierSelected : Carrier
    @State var addresses = [AddressModel]()
    @State var addressSelected = AddressModel(id: Int(), alias: String(), name: String(), phoneNumber: String(), address: String(), city: String(), postcode: String())
    @State public var btnSelected = String()
    @State public var carrierID = Int()
    @State public var isAddressSelected = false
    
    var body: some View {
        VStack {
            Text("Wybierz sposób wysyłki")
                .font(.title)
                .fontWeight(.semibold)
                .padding()
            List {
                ForEach(addresses) { address in
                    AddressRow(address: address, isChecked: address == addressSelected ? true : false).onAppear(){print(address)}.frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            addressSelected = address
                            isAddressSelected = true
                        }
                }
            }
            
            Spacer()
            
            if isAddressSelected == true {
                HStack {
                    NavigationLink(destination: ConfirmationView(finalAddress: addressSelected, selectedCarrier: carrierSelected), label: {
                        Spacer()
                        Text("Dalej")
                        Image(systemName: "arrowtriangle.right.circle.fill")
                        Spacer()
                    }).padding().accentColor(CColor.bright).background(CColor.dark)
                }
            }
        }
        .onAppear(){
            getAddresses()
        }
    }
    
    func getAddresses() {
        addresses = [AddressModel]()
        
        AF.request("\(globalURL)/addresses/?\(apiKey)&display=full&io_format=JSON&filter[id_customer]=[\(UserDefaults.standard.integer(forKey: "userID"))]", method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_,subJson):(String,JSON) in json["addresses"] {
                    self.addresses.append(AddressModel(id: subJson["id"].intValue, alias: subJson["alias"].stringValue, name: "\(subJson["firstname"]) \(subJson["lastname"])", phoneNumber: subJson["phone"].stringValue, address: subJson["address1"].stringValue, city: subJson["city"].stringValue, postcode: subJson["postcode"].stringValue))
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

struct ChooseBlock: View {
    var isSelected: String
    var name: String
    var symbolName: String
    @State var borderColor = CColor.dark
    let uiSize = UIScreen.main.bounds.size
    var body: some View {
        VStack {
            Image(systemName: symbolName)
                .font(.system(size: 50))
                .padding(6)
                .frame(height: 60)
            
            Text(name)
                .font(.system(size: 27))
                .fontWeight(.heavy)
        }
        .frame(width: uiSize.width/2.1, height: 140)
        .border(isSelected == name ? Color.orange : CColor.dark, width: 5.0)
        .accentColor(isSelected == name ? Color.orange : CColor.dark)
    }
}
//
//struct AddressSelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddressSelectionView()
//    }
//}
