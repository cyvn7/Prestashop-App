//
//  OrderDetailsView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 14/03/2021.
//

import SwiftUI
import Kingfisher
import Alamofire
import SwiftyJSON

struct OrderDetailsView: View {
    @State private var images = [Int : Int]()
    var selectedOrder: OrderModel
    var states: [Int: order]
    typealias order = (name: String, color: String)

    var body: some View {
        if images.isEmpty {
            ProgressView().onAppear(perform: getImages)
        } else {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Zamówienie \(selectedOrder.reference)").font(.title).bold()
                    Text(selectedOrder.date_add)
                    Text("\(states[selectedOrder.current_state]!.name)").foregroundColor(Color.init(hex: states[selectedOrder.current_state]!.color))
                }.padding()
                
                List(selectedOrder.products) { product in
                    HStack {
                        KFImage.url(URL(string: "\(globalURL)/images/products/\(product.id)/\(images[product.id]!)/medium_default/?\(apiKey)")!).placeholder({ProgressView()}).cacheMemoryOnly().fade(duration: 0.2)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipped()
                        VStack(alignment: .leading) {
                            Text(product.product_name)
                            Text("\(product.quantity) szt.")
                            Text(String(format: "%.2f", product.price) + "zł")
                        }
                    }
                }
                HStack {
                    Text("Zapłacono").bold()
                    Spacer()
                    Text(String(format: "%.2f", selectedOrder.total_paid) + "zł").bold()
                }.padding()
            }.navigationBarTitle("", displayMode: .inline)
        }
    }
    
    func getImages() {
        let productLink = "\(globalURL)/products?\(apiKey)&display=full&io_format=JSON&filter[id]=[\(selectedOrder.products)]"
        
        AF.request(productLink.replacingOccurrences(of: ", ", with: "|").addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                for (_,subJson):(String, JSON) in json["products"] {
                    self.images[subJson["id"].intValue] = subJson["id_default_image"].intValue
                }
                
                
            case .failure(let error):
                print(error)
            }
        }
    }
}

//struct OrderDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        OrderDetailsView()
//    }
//}
