//
//  CartView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 14/03/2021.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import Kingfisher

struct CartView: View {
    let defaults = UserDefaults.standard
  //  @EnvironmentObject var globalVars: GlobalVars
    @State var quantities = [String : String]()
    @State var isCartDisabled = true
    @State var cartItems = [ProductModel]()
    @State var totalPrice: Double = 0
    @State var cartString = String()
    @State var isPriceLoaded = true
    @State var willDeleteBtnDisappear = false
    @State var sales = [Int : SpecificPrice]()
    //@AppStorage("hhhh") var hhhh: Int = 0

    
    var body: some View {
        NavigationView {
            VStack {
                if isCartDisabled == true {
                    ProgressView()
                } else if cartItems == [ProductModel]() {
                    Text("Nie masz żadnych przedmiotów w koszyku!")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(2)
                }
                else {
                    ScrollView {
                        ForEach(cartItems) { cartItem in
                            HStack {
                                CartProductRow(localCartItem: cartItem, cartString: $cartString, pcs: Int(quantities["\(cartItem.id)"]!)!)
                                
                                Button(action: {
                                    withAnimation {
                                        let cartClass: ModyfingCart = ModyfingCart();
                                        //isTotalPriceLoaded = false
                                        cartString = cartClass.modifyProduct(productID: cartItem.id, quantity: 0, ifDelete: true, pricePerPiece: cartItem.price, isCartVisible: true)
                                        cartItems = cartItems.filter {$0 != cartItem}
                                        self.willDeleteBtnDisappear = true
                                    }
                                }, label: {
                                    Image(systemName: "trash").font(.system(size: 24))
                                }).accentColor(.red).padding(20)
                                .disabled(willDeleteBtnDisappear)
                            }.transition(.moveAndFade)
                        }.navigationBarTitle("Koszyk", displayMode: .inline)
                    }
                    
                    
                    VStack {
                        HStack{
                            Text("Razem:")
                            Spacer()
                            if isPriceLoaded == true {
                                Text(String(format: "%.2f", totalPrice) + "zł")
                            } else {
                                ProgressView()
                            }
                        }.padding()
                        if totalPrice>0 {
                            NavigationLink(destination: CarrierSelectionView(), label: {
                                Spacer()
                                Text("Zamów")
                                    .padding([.leading, .vertical])
                                Image(systemName: "cart.circle.fill")
                                Spacer()
                            }).accentColor(CColor.bright)
                            .background(CColor.dark)
                        }
                    }
                }
            }//.navigationBarItems(leading: Button("debug_print", action: {print("totalPrice: \(totalPrice), itemsBadge: \(itemsBadge)")}), trailing: Button("debug_reset", action: {totalPrice = 0; itemsBadge = 0}))
        }
        .onAppear(){print("pooof!!! i'm here :)"); self.isCartDisabled = true; self.cartItems = [ProductModel](); self.getSales()}
        .onChange(of: cartString, perform: { value in
            updateCart()
            print(cartString)
        })
   
    }

    func getSales() {
        let formatter = DateFormatter()
        let today = Date()
        formatter.dateFormat = "yyyy-MM-dd"
        let salesLink = "\(globalURL)/specific_prices?\(apiKey)&io_format=JSON&display=full&filter[to]=>[\(formatter.string(from: today))]&filter[from]=<[\(formatter.string(from: today))]"
        let salesLink2 = "\(globalURL)/specific_prices?\(apiKey)&io_format=JSON&display=full&filter[to]=[0000-00-00]"
        var funcDone = 0
        
        if defaults.integer(forKey: "cartID") != 0  {
            print("getSales")
            AF.request(salesLink.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for (_,subJson):(String, JSON) in json["specific_prices"] {
                        let dateFormatterGet = DateFormatter()
                        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"

                        let dateFormatterPrint = DateFormatter()
                        dateFormatterPrint.dateFormat = "dd.MM.yyyy"
                        
                        let date = dateFormatterGet.date(from: subJson["to"].stringValue)
                        
                        sales[subJson["id_product"].intValue] = SpecificPrice(id: subJson["id"].intValue, reduction_type: subJson["reduction_type"].stringValue, reduction: subJson["reduction"].doubleValue, endDate: dateFormatterPrint.string(from: date!))
                    }
                    funcDone+=1
                    if funcDone == 2 {
                        getCartItems()
                    }
                case .failure(let error):
                    print(error)
                }
            }
            AF.request(salesLink2.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for (_,subJson):(String, JSON) in json["specific_prices"] {
                        sales[subJson["id_product"].intValue] = SpecificPrice(id: subJson["id"].intValue, reduction_type: subJson["reduction_type"].stringValue, reduction: subJson["reduction"].doubleValue, endDate: subJson["to"].stringValue)
                    }
                    funcDone+=1
                    if funcDone == 2 {
                        getCartItems()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            isCartDisabled = false
        }
        
    }

    func updateCart() {
        isPriceLoaded = false
        let cartID = defaults.integer(forKey: "cartID")
        let url = URL(string: "\(globalURL)/carts/\(cartID)?\(apiKey)&display=full&io_format=JSON&ps_method=PUT")
        var xmlRequest = URLRequest(url: url!)
        xmlRequest.httpBody = cartString.data(using: String.Encoding.utf8, allowLossyConversion: true)
        xmlRequest.httpMethod = "PUT"
        xmlRequest.addValue("application/xml", forHTTPHeaderField: "Content-Type")
        
        AF.request(xmlRequest).responseJSON() { (response) in
            print(response)
            getTotalPrice()
        }
    }
    
    func getTotalPrice() {
        let quantities = defaults.dictionary(forKey: "cartDict")!
        let totalPriceLink = "\(globalURL)/products/?\(apiKey)&filter[id]=\(quantities.keys.map { Int($0)! })&display=[id,price]&io_format=JSON"
        var tempTotPrice = Double()
        
        AF.request(totalPriceLink.replacingOccurrences(of: ", ", with: "|").addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_,subJson):(String, JSON) in json["products"] {
                    print(totalPriceLink.replacingOccurrences(of: ", ", with: "|"))
                    print("quantities: \(quantities)")
                    print("id: \(subJson["id"].stringValue)")
                    print("sub: \(quantities[subJson["id"].stringValue])")
                    // FIXME: Niech oblicza cenę po obniżce
                    if let productSale = self.sales[subJson["id"].intValue] {
                        if productSale.reduction_type == "amount" {
                            tempTotPrice+=(subJson["price"].doubleValue - (productSale.reduction/1.23)) * Double(quantities[subJson["id"].stringValue] as! String)!
                        } else {
                            tempTotPrice+=(subJson["price"].doubleValue * (1 - productSale.reduction)) * Double(quantities[subJson["id"].stringValue] as! String)!
                        }
                    } else {
                        tempTotPrice+=(subJson["price"].doubleValue * Double(quantities[subJson["id"].stringValue] as! String)!)
                    }
                }
                
                self.totalPrice = tempTotPrice*1.23
                self.isPriceLoaded = true
                self.willDeleteBtnDisappear = false
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getCartItems() {
        print("getCardItems")
        if isCartDisabled == true {
            let cartID = defaults.integer(forKey: "cartID")
            let cartLink = "\(globalURL)/carts/\(cartID)?\(apiKey)&ps_method=GET&io_format=JSON"
            //MARK - ZASTĄP!!!!
            var productsLink = "\(globalURL)/products?\(apiKey)&display=full&io_format=JSON"
            let downloadGroup = DispatchGroup()
            quantities = (defaults.dictionary(forKey: "cartDict") ?? [String:String]()) as [String:String]

            downloadGroup.enter()
            
                
                AF.request(cartLink, method: .get).validate().responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        productsLink = ("\(productsLink)&filter[id]=\(self.quantities.keys.map { Int($0)! })").replacingOccurrences(of: ", ", with: "|")
                        var tmpDict = [String:String]()
                        print("before: \(tmpDict)")
                        for (_,subJson):(String, JSON) in json["cart"]["associations"]["cart_rows"] {
                            tmpDict[subJson["id_product"].stringValue] = subJson["quantity"].stringValue
                        }
                        self.defaults.setValue(tmpDict, forKey: "cartDict")
                        quantities = tmpDict
                        print("after: \(tmpDict)")
                        downloadGroup.leave()

                        
                    case .failure(let error):
                        print(error)
                    }
                }
            DispatchQueue.global(qos: .background).async {
                downloadGroup.wait()
                DispatchQueue.main.async {
                    if !(quantities.isEmpty) {
                        AF.request(productsLink.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
                            switch response.result {
                            case .success(let value):
                                let json = JSON(value)
                                var tempCartItems = [ProductModel]()
                                var tempTotPrice = Double()
                                
                                for (_,subJson):(String, JSON) in json["products"] {
                                    var product_option_valuesArray = [Int]()
                                    var accessoriesTab = [Int]()
                                    var product_featuresDict = Dictionary<Int,Int>()
                                    for (_,subSubJson):(String, JSON) in subJson["associations"]["product_option_values"] {
                                        product_option_valuesArray.append(subSubJson["id"].intValue)
                                    }
                                    
                                    for (_,subSubJson):(String, JSON) in subJson["associations"]["product_features"] {
                                        product_featuresDict[subSubJson["id"].intValue] = subSubJson["id_feature_value"].intValue
                                    }
                                    
                                    for (_,subSubJson):(String, JSON) in subJson["associations"]["accessories"] {
                                        accessoriesTab.append(subSubJson["id"].intValue)
                                    }
                                    
                                    var tmpProduct = ProductModel(id: subJson["id"].intValue, name: subJson["name"].stringValue, description: subJson["description"].stringValue, defaultImage: subJson["id_default_image"].intValue, price: subJson["price"].doubleValue, description_short: subJson["description_short"].stringValue, product_option_values: product_option_valuesArray, product_features: product_featuresDict, manufacturer_name: subJson["manufacturer_name"].stringValue, reference: subJson["reference"].stringValue, accessories: accessoriesTab)
                                    if let productSale = self.sales[tmpProduct.id] {
                                        tmpProduct.specificPrice = productSale
                                        if productSale.reduction_type == "amount" {
                                            tmpProduct.salePrice = tmpProduct.price - (productSale.reduction/1.23)
                                        } else {
                                            tmpProduct.salePrice = tmpProduct.price * (1 - productSale.reduction)
                                        }
                                        //tmpProduct.sale = productSale
                                        print("\(tmpProduct.name) ~ \(tmpProduct.salePrice)")
                                        tempTotPrice+=(tmpProduct.salePrice * Double(quantities[subJson["id"].stringValue] as! String)!)
                                    } else {
                                        tempTotPrice+=(tmpProduct.price * Double(quantities[subJson["id"].stringValue] as! String)!)
                                    }
                                    if !(tempCartItems.contains(tmpProduct)) {
                                        tempCartItems.append(tmpProduct)
                                    }
                                    
                                }
                                
                                cartItems = tempCartItems
                                self.totalPrice = tempTotPrice*1.23
                                self.isCartDisabled = false
                                
                            case .failure(let error):
                                print(error)
                            }
                        }
                    } else {
                        self.totalPrice = 0
                        self.isCartDisabled = false
                    }
                }
            }
        }
        
        
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}

struct CartProductRow: View {
    let cartClass: ModyfingCart = ModyfingCart()
    var localCartItem: ProductModel
    var cartString : Binding<String>
    @State var pcs : Int
    @State var isMin = false
    @State var isMax = false
    @State var isLoaded = false
    var body: some View {
        HStack {
            if isLoaded == true {
                ZStack {
                    KFImage
                        .url(URL(string: "\(globalURL)/images/products/\(localCartItem.id)/\(localCartItem.defaultImage)/medium_default/?\(apiKey)"))
                        .placeholder({ProgressView()})
                        .loadDiskFileSynchronously()
                        .cacheMemoryOnly()
                        .fade(duration: 0.2)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 110.0)
                        .clipped()
                    
                    if localCartItem.salePrice != Double() {
                        VStack {
                            HStack {
                                if localCartItem.specificPrice.reduction_type == "amount" {
                                    Text("-" + String(format: "%.2f", (localCartItem.specificPrice.reduction * 1.23)) + "zł")
                                        .foregroundColor(Color.white)
                                        .background(Color.orange)
                                } else {
                                    Text("-" + String(format: "%.0f", (localCartItem.specificPrice.reduction*100)) + "%")
                                        .foregroundColor(Color.white)
                                        .background(Color.orange)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
            }
            VStack(alignment: .leading) {
                Text(localCartItem.name)
                    .fontWeight(.semibold)
                    .font(.system(size: 14))
                    
                if localCartItem.salePrice == Double() {
                    Text(String(format: "%.2f", (localCartItem.price * 1.23 * Double(pcs))) + "zł")
                        .padding(.top, 5.0)
                        .font(.system(size: 12))
                } else {
                    HStack {
                        Text(String(format: "%.2f", (localCartItem.salePrice * 1.23 * Double(pcs))) + "zł")
                            .padding(.top, 5.0)
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        
                        Text(String(format: "%.2f", (localCartItem.price * 1.23 * Double(pcs))) + "zł")
                            .strikethrough()
                            .padding(.top, 5.0)
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                    }
                }
                
                HStack {
                    Button(action: {
                        isMax = false
                        pcs-=1
                        self.cartString.wrappedValue = cartClass.modifyProduct(productID: localCartItem.id, quantity: -1, ifDelete: false, pricePerPiece: localCartItem.price, isCartVisible: true)
                        if pcs == 1 {isMin = true}
                    }, label: {
                        Image(systemName: "minus")
                    }).padding(.leading, 9).disabled(isMin)
                    Divider()
                        .clipped()
                    Text("\(pcs)")
                        .padding(.horizontal, 8)
                    Divider()
                        .clipped()
                    Button(action: {
                        isMin = false
                        pcs+=1
                        self.cartString.wrappedValue = cartClass.modifyProduct(productID: localCartItem.id, quantity: 1, ifDelete: false, pricePerPiece: localCartItem.price, isCartVisible: true)
                            if pcs == 999 {isMax = true}
                    }, label: {
                        Image(systemName: "plus")
                    }).padding(.trailing, 9).disabled(isMax)
                }.frame(height: 33).border(Color.gray, width: 0.7).accentColor(.gray).onAppear(perform: {if pcs == 1 {isMin = true} else if pcs >= 999 {isMax = true}})
            }
            Spacer()
        }.onAppear(){
            self.isLoaded = true
        }
    }
}


