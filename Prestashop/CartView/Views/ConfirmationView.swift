//
//  ConfirmatiionView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 14/03/2021.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import Kingfisher

struct ConfirmationView: View {
    @State var str = ""
    @State var isReadyToOrder = false
    @State var productsDict = [String:String]()
    @State var products = [PreviewProduct]()
    @State var totalPrice = Double()
    typealias PreviewProduct = (id: Int, id_defaultimage: Int, name: String, price: Double, salePrice: Double)
    var finalAddress : AddressModel
    var selectedCarrier : Carrier

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Adres:").font(.title).fontWeight(.bold).padding(.leading, 10)
                    AddressRow(address: finalAddress, isChecked: false).padding(10)
                    Text("Zamówienie:").font(.title).fontWeight(.bold)
                    Divider()
                    ForEach(products.indices, id: \.self) { index in
                        HStack {
                            KFImage.url(URL(string: "\(globalURL)/images/products/\(products[index].id)/\(products[index].id_defaultimage)/medium_default/?\(apiKey)")!).placeholder({ProgressView()}).cacheMemoryOnly().fade(duration: 0.2)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .clipped()
                            VStack(alignment: .leading) {
                                Text(products[index].name)
                                Text("\(productsDict["\(products[index].id)"]!) szt.")
                                if products[index].salePrice == Double() {
                                    Text(String(format: "%.2f", products[index].price * Double(productsDict["\(products[index].id)"]!)!) + "zł")
                                } else {
                                    HStack {
                                        Text(String(format: "%.2f", products[index].salePrice * Double(productsDict["\(products[index].id)"]!)!) + "zł")
                                            .foregroundColor(.orange)
                                        
                                        Text(String(format: "%.2f", products[index].price * Double(productsDict["\(products[index].id)"]!)!) + "zł")
                                            .strikethrough()
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }.padding(5)
                        Divider()
                    }
                    if isReadyToOrder == false {
                        ProgressView().padding()
                    } else {
                        Text(selectedCarrier.id == 17 ? "Płatność przy odbiorze" : "Płatność online").bold().padding()
                    }
                }
            }
            HStack {
                Text("Razem: ").fontWeight(.bold).padding(10)
                if isReadyToOrder == false {
                    ProgressView()
                } else {
                    Text(String(format: "%.2f", totalPrice) + "zł")
                }
                Spacer()
            }
            NavigationLink(destination: GreetingsView(orderStr: str), label: {
                Spacer()
                if isReadyToOrder == false {
                    ProgressView().padding()
                } else {
                    Text(selectedCarrier.id == 17 ? "Zapłać z obowiązkiem zapłaty przy odbiorze" : "Zapłać online").bold().padding()
                }
                Spacer()
            }).background(CColor.dark).foregroundColor(CColor.bright).disabled(!(isReadyToOrder))
        }.navigationTitle("Podsumowanie").onAppear(perform: getOrderReady)
    }
    
    func getOrderReady() {
        let defaults = UserDefaults.standard
        let userID = defaults.integer(forKey: "userID")
        let cartID = defaults.integer(forKey: "cartID")
        
        // TODO: ID guest zmień
        let strCart = "<prestashop xmlns:xlink='http://www.w3.org/1999/xlink'><cart><id>\(cartID)</id><id_shop>1</id_shop><id_guest>693</id_guest><id_shop_group>1</id_shop_group><id_customer>\(userID)</id_customer><id_currency>1</id_currency><id_address_delivery>\(finalAddress.id)</id_address_delivery><id_address_invoice>\(finalAddress.id)</id_address_invoice><id_lang>1</id_lang><id_carrier>\(selectedCarrier.id)</id_carrier></cart></prestashop>"
        let url = URL(string: "\(globalURL)/carts/?\(apiKey)&ps_method=PUT&io_format=JSON")
        var xmlRequest = URLRequest(url: url!)
        xmlRequest.httpBody = strCart.data(using: String.Encoding.utf8, allowLossyConversion: true)
        xmlRequest.httpMethod = "PUT"
        xmlRequest.addValue("application/xml", forHTTPHeaderField: "Content-Type")


        AF.request(xmlRequest).responseJSON() { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_,subJson):(String, JSON) in json["cart"]["associations"]["cart_rows"] {
                    productsDict[subJson["id_product"].stringValue] = subJson["quantity"].stringValue
                }
                getProducts()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getProducts() {
        var productsLink = "\(globalURL)/products/?\(apiKey)&io_format=JSON&filter[active]=[1]&display=[id,id_default_image,price,name]&filter[id]=\(productsDict.keys)"
        productsLink = productsLink.replacingOccurrences(of: ", ", with: "|").replacingOccurrences(of: "\"", with: "").addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        print(productsLink)
        AF.request(productsLink, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_,subJson):(String, JSON) in json["products"] {
                    products.append((id: subJson["id"].intValue, id_defaultimage: subJson["id_default_image"].intValue, name: subJson["name"].stringValue, price: subJson["price"].doubleValue*1.23, salePrice: Double()))
                }
                getSales()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getSales() {
        let formatter = DateFormatter()
        let today = Date()
        formatter.dateFormat = "yyyy-MM-dd"
        let salesLink = "\(globalURL)/specific_prices?\(apiKey)&io_format=JSON&display=full&filter[to]=>[\(formatter.string(from: today))]&filter[from]=<[\(formatter.string(from: today))]&filter[id_product]=\(productsDict.keys)"
        let salesLink2 = "\(globalURL)/specific_prices?\(apiKey)&io_format=JSON&display=full&filter[to]=[0000-00-00]&filter[id_product]=\(productsDict.keys)"
        var funcDone = 0
        
            AF.request(salesLink.replacingOccurrences(of: ", ", with: "|").replacingOccurrences(of: "\"", with: "").addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for (_,subJson):(String, JSON) in json["specific_prices"] {
                        if subJson["reduction_type"] == "amount" {
                            products[searchSale(id: subJson["id_product"].intValue)!].salePrice = products[searchSale(id: subJson["id_product"].intValue)!].price - (subJson["reduction"].doubleValue/1.23)
                        } else {
                            products[searchSale(id: subJson["id_product"].intValue)!].salePrice = products[searchSale(id: subJson["id_product"].intValue)!].price * (1 - subJson["reduction"].doubleValue)
                        }
                    }
                    funcDone+=1
                    if funcDone == 2 {
                        getTotalPrice()
                        print(products)
                    }
                case .failure(let error):
                    print(error)
                }
            }
            AF.request(salesLink2.replacingOccurrences(of: ", ", with: "|").replacingOccurrences(of: "\"", with: "").addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for (_,subJson):(String, JSON) in json["specific_prices"] {
                        if subJson["reduction_type"] == "amount" {
                            products[searchSale(id: subJson["id_product"].intValue)!].salePrice = products[searchSale(id: subJson["id_product"].intValue)!].price - (subJson["reduction"].doubleValue/1.23)
                        } else {
                            products[searchSale(id: subJson["id_product"].intValue)!].salePrice = products[searchSale(id: subJson["id_product"].intValue)!].price * (1 - subJson["reduction"].doubleValue)
                        }
                    }
                    funcDone+=1
                    if funcDone == 2 {
                        getTotalPrice()
                        print(products)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        
        
    }
    
    func searchSale(id: Int) -> Int? {
      return products.firstIndex { $0.id == id }
    }
    
    func getTotalPrice() {
        for product in products {
            if product.salePrice != Double() {
                totalPrice += product.salePrice * Double(productsDict["\(product.id)"]!)!
            } else {
                totalPrice += product.price * Double(productsDict["\(product.id)"]!)!
            }
        }
        
        let defaults = UserDefaults.standard
        let userID = defaults.integer(forKey: "userID")
        let cartID = defaults.integer(forKey: "cartID")
        let selectedAddress = finalAddress.id
        var selectedPayment = [String]()
        var totalPaid = 0.0
        if selectedCarrier.id == 17 {
            selectedPayment.append("ps_cashondelivery") //module
            selectedPayment.append("Płatność przy odbiorze") //payment
            totalPaid = totalPrice
        } else {
            selectedPayment.append("tpay")
            selectedPayment.append("Tpay")
        }
        
        str = "<?xml version='1.0' encoding='UTF-8'?><prestashop xmlns:xlink='http://www.w3.org/1999/xlink'><order><id_cart>\(cartID)</id_cart><id_address_delivery>\(selectedAddress)</id_address_delivery><id_address_invoice>\(selectedAddress)</id_address_invoice><id_currency>1</id_currency><id_lang>1</id_lang><id_customer>\(userID)</id_customer><id_carrier>\(selectedCarrier.id)</id_carrier><payment>\(selectedPayment[1])</payment><module>\(selectedPayment[0])</module><total_paid>\(String(format: "%.5f", totalPrice))</total_paid><total_paid_real>\(String(format: "%.5f", totalPaid))</total_paid_real><total_products>" + String(format: "%.5f", totalPrice/1.23) + "</total_products><total_products_wt>\(String(format: "%.5f", totalPrice))</total_products_wt><conversion_rate>1</conversion_rate></order></prestashop>"
        print(str)
        isReadyToOrder = true
    }
}

//struct ConfirmatiionView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConfirmationView()
//    }
//}
