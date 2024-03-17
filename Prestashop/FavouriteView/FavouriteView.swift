//
//  FavouriteView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 26/03/2021.
//

import SwiftUI
import Kingfisher
import SwiftyJSON
import Alamofire

struct FavouriteView: View {
    let cartClass: ModyfingCart = ModyfingCart()
    @State var products = [ProductModel]()
    @State var selectedProduct = ProductModel(id: Int(), name: String(), description: String(), defaultImage: Int(), price: Double(), description_short: String(), product_option_values: [Int](), product_features: [Int : Int](), manufacturer_name: String(), reference: String(), accessories: [Int]())
    @State var productIDs = [Int]()
    @State var isEveryProductFav = true
    @State var isLoaded = false
    @State var selectedTag : Int?
    @State var sales = [Int : SpecificPrice]()
    @AppStorage("isPopupPresent") var isPopupPresent = false
    
    var body: some View {
        NavigationView {
            if isLoaded == false {
                ProgressView()
            } else if products == [ProductModel]() {
                VStack {
                    Text("Nie masz żadnych polubionych przedmiotów!")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(2)
                    Text("Kliknij ♥ aby dodać przedmiot do ulubionych")
                        .font(.title3)
                        .fontWeight(.light)
                    .multilineTextAlignment(.center)
                }.padding()
            } else {
                ScrollView {
                    Spacer()
                        .frame(height: 5)
                    ForEach(products) { product in
                        let finalPrice = String(format: "%.2f", product.price * 1.23)+"zł"
                        //TODO: if else in Vstack - declutteriing needed
                        NavigationLink(destination: ProductDetailsView(product: product, isProductFavourite: $isEveryProductFav).popup(isPresented: isPopupPresent, alignment: .bottom, direction: .bottom, content: Snackbar.init), tag: product.id, selection: $selectedTag) {
                            HStack {
                                KFImage.url(URL(string: "\(globalURL)/images/products/\(product.id)/\(product.defaultImage)/large_default/?\(apiKey)")).placeholder({ProgressView()}).cacheMemoryOnly().fade(duration: 0.2)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120.0, height: 140.0)
                                    .clipped()

                                VStack(alignment: .leading) {
                                    Spacer()
                                    Text(product.name)
                                        .fontWeight(.semibold)
                                        .font(.system(size: 18))
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(CColor.dark)


                                if product.salePrice == Double() {
                                    Text(finalPrice)
                                        .padding(.top, 5.0)
                                        .font(.system(size: 14))
                                        .foregroundColor(CColor.dark)
                                } else {
                                    HStack {
                                        Text(String(format: "%.2f", finalPrice + "zł"))
                                            .padding(.top, 5.0)
                                            .font(.system(size: 14))
                                            .foregroundColor(CColor.fPurple)

                                        Text(String(format: "%.2f", finalPrice + "zł"))
                                            .strikethrough()
                                            .padding(.top, 5.0)
                                            .font(.system(size: 8))
                                            .foregroundColor(.gray)
                                    }
                                }

                                Button(action: {cartClass.modifyProduct(productID: product.id, quantity: 1, ifDelete: false, pricePerPiece: product.price, isCartVisible: false); mediumHaptic.prepare(); mediumHaptic.impactOccurred()}, label: {
                                    Text("Dodaj do koszyka")
                                        .font(.system(size: 14))
                                        .padding(5)
                                })
                                .foregroundColor(CColor.fPurple)
                                .overlay(
                                            Capsule(style: .continuous)
                                                .stroke(Color.purple, style: StrokeStyle(lineWidth: 2))
                                        )
                                Spacer()
                                }
                                Spacer()
                                Button(action: {
                                    deleteItem(product: product)
                                }, label: {
                                    Image(systemName: "xmark").font(.system(size: 20)).padding()
                                })

                            }
                            .buttonStyle(PlainButtonStyle())
                            .border(CColor.bright, width: 0.7)
                            .padding(.horizontal, 19)
                            .padding(.vertical, 4)
                        }
                        .transition(.moveAndFade)
                        .background(CColor.bright)
                        .cornerRadius(15)
                        .padding(.horizontal,8)
                    }
                    .onAppear(){
                        print("isLoaded: \(isLoaded), selectedProduct: \(selectedProduct)")
                        if isEveryProductFav == false && !(products.filter {$0.id == selectedTag}.isEmpty) {
                            print("selectedValue: \(products.filter {$0.id == selectedTag})")
                            print("selectedValue: \(products.filter {$0.id == selectedTag}[0])")
                            deleteItem(product: products.filter {$0.id == selectedTag}[0])
                        }
                    }
                }.navigationBarTitle("Ulubione")
                    .background(CColor.lightGray)
            }
        }
        .onAppear(perform: getSales)
    }
    
    func getSales() {
        let formatter = DateFormatter()
        let today = Date()
        formatter.dateFormat = "yyyy-MM-dd"
        let salesLink = "\(globalURL)/specific_prices?\(apiKey)&io_format=JSON&display=full&filter[to]=>[\(formatter.string(from: today))]&filter[from]=<[\(formatter.string(from: today))]"
        let salesLink2 = "\(globalURL)/specific_prices?\(apiKey)&io_format=JSON&display=full&filter[to]=[0000-00-00]"
        var funcDone = 0
        
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
                    getProducts()
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
                    getProducts()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getProducts() {
        print("i'm working!!")
        isLoaded = false
        products = [ProductModel]()
        productIDs = (UserDefaults.standard.array(forKey: "favouriteItems") ?? []) as! [Int]
        let link = "\(globalURL)/products/?\(apiKey)&io_format=JSON&filter[id]=\(productIDs)&display=full"
        AF.request(link.replacingOccurrences(of: ", ", with: "|").addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
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
                    }
                    if !(products.contains(tmpProduct)) {
                        self.products.append(tmpProduct)
                    }
                }
                self.isLoaded = true
                
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func deleteItem(product: ProductModel) {
        withAnimation {
            products = products.filter {$0 != product}
            productIDs = productIDs.filter {$0 != product.id}
        }
        UserDefaults.standard.set(productIDs, forKey: "favouriteItems")
        isEveryProductFav = true
        lightHaptic.prepare()
        lightHaptic.impactOccurred()
    }
}

struct FavouriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteView()
    }
}
