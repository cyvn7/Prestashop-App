//
//  AddressesView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 14/03/2021.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct AddressesView: View {
    @State var isFull = Bool()
    @State var addresses = [AddressModel]()
    
    var userID: Int
    
    var body: some View {
        VStack {
            if isFull == false {
                ProgressView()
            } else if addresses == [AddressModel]() {
                Text("Brak adresów")
            } else {
                List {
                    ForEach(addresses) { address in
                        AddressRow(address: address, isChecked: false)
                    }
                    .onDelete(perform: delete)
                }
            }
        }
        .navigationBarTitle("Adresy")
        .navigationBarItems(trailing:
            NavigationLink(destination: AddingNewAddressView(userID: userID)) {
                Image(systemName: "plus")
                }
        )
        .onAppear(){self.getAddresses()}
    }
    
    func delete(at indexSet: IndexSet) {
        indexSet.forEach { tmp in
            AF.request("\(globalURL)/addresses/\(addresses[tmp].id)/?\(apiKey)&io_format=JSON&ps_method=DELETE", method: .delete).validate().responseData { response in
                self.addresses.remove(atOffsets: indexSet)
            }
        }
    }
    
    func getAddresses() {
        addresses = [AddressModel]()
        
        AF.request("\(globalURL)/addresses/?\(apiKey)&display=full&io_format=JSON&filter[id_customer]=[\(userID)]", method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_,subJson):(String,JSON) in json["addresses"] {
                    self.addresses.append(AddressModel(id: subJson["id"].intValue, alias: subJson["alias"].stringValue, name: "\(subJson["firstname"]) \(subJson["lastname"])", phoneNumber: subJson["phone"].stringValue, address: subJson["address1"].stringValue, city: subJson["city"].stringValue, postcode: subJson["postcode"].stringValue))
                    self.isFull = true
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
}

struct AddressRow: View {
    var address: AddressModel
    var isChecked: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(address.alias)
                    .fontWeight(.bold)
                Text(address.name)
                Text(address.address)
                Text("\(address.city), \(address.postcode)")
                Text(address.phoneNumber)
            }
            Spacer()
            if isChecked == true {
                Image(systemName: "checkmark")
            }
        }
    }
}

struct AddressesView_Previews: PreviewProvider {
    static var previews: some View {
        AddressesView(userID: 3)
    }
}
