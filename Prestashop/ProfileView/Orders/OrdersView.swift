//
//  OrdersView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 14/03/2021.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct OrdersView: View {
    @State var orders = [OrderModel]()
    @State var states = [Int: order]()
    @State var isLoaded = false
    typealias order = (name: String, color: String)
    
    var body: some View {
        if isLoaded == true {
            List(orders) { order in
                NavigationLink(destination: OrderDetailsView(selectedOrder: order, states: states)) {
                    VStack(alignment: .leading) {
                        Text("Zamówienie \(order.reference)").bold()
                        Text(order.date_add)
                        Text("\(order.products.count) rzecz\(order.products.count == 1 ? "" : "y")")
                        Text("\(states[order.current_state]!.name)").foregroundColor(Color.init(hex: states[order.current_state]!.color))
                    }
                }
            }
        } else {
            ProgressView()
                .onAppear(perform: getOrders).navigationTitle("Zamówienia")
        }
    }
    
    func getOrders() {
        let downloadGroup = DispatchGroup()
        let userID = UserDefaults.standard.string(forKey: "userID")!
        let link = "\(globalURL)/orders?\(apiKey)&display=full&io_format=JSON&filter[id_customer]=[\(userID)]"
        let statusesLink = "\(globalURL)/order_states?\(apiKey)&display=full&io_format=JSON"
        var tempOrders = [OrderModel]()
        print(link)
        downloadGroup.enter()
        downloadGroup.enter()
        

        AF.request(link.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
            let json = JSON(response.value!)
            for (_,subJson):(String, JSON) in json["orders"] {
                var products = [ProductInOrderModel]()
                for (_,subSubJson):(String, JSON) in subJson["associations"]["order_rows"] {
                    products.append(ProductInOrderModel(id: subSubJson["product_id"].intValue, product_name: subSubJson["product_name"].stringValue, quantity: subSubJson["product_quantity"].intValue, price: subSubJson["unit_price_tax_incl"].doubleValue))
                }
                
                tempOrders.append(OrderModel(id: subJson["id"].intValue, id_carrier: subJson["id_carrier"].intValue, reference: subJson["reference"].stringValue, date_add: subJson["date_add"].stringValue, id_address_delivery: subJson["id_address_delivery"].intValue, products: products, current_state: subJson["current_state"].intValue, total_paid: subJson["total_paid"].doubleValue))
            }

            downloadGroup.leave()
        }
        
        AF.request(statusesLink.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
            
            let json = JSON(response.value!)
            for (_,subJson):(String, JSON) in json["order_states"] {
                self.states[subJson["id"].intValue] = order(name: subJson["name"].stringValue, color: subJson["color"].stringValue)
            }
            
            downloadGroup.leave()
        }
        
        DispatchQueue.global(qos: .background).async {
            downloadGroup.wait()
            DispatchQueue.main.async {
                tempOrders.reverse()
                self.orders = tempOrders
                self.isLoaded = true
            }
        }
    }
}

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersView()
    }
}
