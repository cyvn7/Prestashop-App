//
//  ProductDetailsView.swift
//  dynashop
//
//  Created by Maciej Przybylski on 30/07/2020.
//  Copyright © 2020 Maciej Przybylski. All rights reserved.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import Kingfisher
import WebKit

struct ProductDetailsView: View {

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var product: ProductModel
    let cartClass: ModyfingCart = ModyfingCart()
    let downloadGroup = DispatchGroup()
    let defaults = UserDefaults.standard
    @State private var pcs: Int = 0
    @State var quantity = 1
    @State var text = ""
    @State var isProductLoaded = false
    @State var links = [URL]()
    @State var suggestedProducts = [ProductModel]()
    @State var productDesc = String()
    @State var features = Dictionary<String, String>()
    @Binding var isProductFavourite: Bool

    var body: some View {
            if isProductLoaded == true {
                ScrollView {
                    VStack(alignment: .leading) {
                        NavigationLink(destination: PhotoGallery(links: links, isFullScreen: true)) {
                            PhotoGallery(links: links, isFullScreen: false)
                        }
                        Divider()
                        //MARK: Title box
                        VStack(alignment: .leading) {
                            Text(product.manufacturer_name)
                                .font(.footnote)
                            Text(product.name)
                                .font(.system(size: 30))
                                .fontWeight(.bold)
                            if product.salePrice == Double() {
                                Text(String(format: "%.2f", (product.price * 1.23)) + "zł")
                                    .font(.title2)
                            } else {
                                HStack {
                                    Text(String(format: "%.2f", (product.salePrice * 1.23)) + "zł")
                                        .font(.title2)
                                        .foregroundColor(.orange)

                                    Text(String(format: "%.2f", (product.price * 1.23)) + "zł")
                                        .font(.title2)
                                        .strikethrough()
                                        .padding(.top, 5.0)
                                        .foregroundColor(.gray)
                                }
                                if product.specificPrice.endDate != "0000-00-00 00:00:00" {
                                    Text("Promocja trwa do \(product.specificPrice.endDate)")
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        //MARK: Add to card and favourite buttons box
                        HStack {
                            Button(action: {cartClass.modifyProduct(productID: product.id, quantity: pcs+1, ifDelete: false, pricePerPiece: product.price, isCartVisible: false); mediumHaptic.prepare(); mediumHaptic.impactOccurred()}, label: {
                                ZStack(alignment: .leading){
                                    CColor.purpleGradient
                                    Text("Do koszyka")
                                        .fontWeight(.bold)
                                        .padding()
                                }
                            })
                            .disabled(!(product.isAvailable))
                            .frame(height: 50)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 10)
                            
                            Button(action: {
                                var favArr = (defaults.array(forKey: "favouriteItems") ?? []) as! [Int]
                                if favArr.contains(product.id) {
                                    favArr = favArr.filter { $0 != product.id }
                                } else {
                                    favArr.append(product.id)
                                }
                                isProductFavourite.toggle()
                                defaults.set(favArr, forKey: "favouriteItems")
                                print(favArr)
                            }, label: {
                                Image(systemName: isProductFavourite == true ? "heart.fill" : "heart")
                            })
                            .frame(width: 50, height: 50)
                            .foregroundColor(isProductFavourite == true ? Color.purple : Color.gray)
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1))
                            .padding(.trailing, 10)
                            
                            
                        }
                        .padding(.horizontal, 4)
                        if product.description_short != "" {
                            Text(product.description_short.html2String)
                                .font(.footnote)
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                        }
                        //CStepper(value: $pcs, pricePerPiece: 0)
                        HStack {
                            Menu {
                                Picker("Quantity", selection: $pcs) {
                                    ForEach(1..<10) {
                                        Text("\($0)")
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("Quantity:")
                                        .fontWeight(.semibold)
                                        .padding(.leading)
                                    Picker("Quantity", selection: $pcs) {
                                        ForEach(1..<10) {
                                            Text("\($0)")
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .padding(.trailing)
                                }
                            }
                            .frame(height: 50)
                            .foregroundColor(.gray)
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1))
                            .padding([.top, .leading, .bottom], 10.0)
                            
                            Button(action: {
                                print("BUTTON: Favourite clicked")
                            }, label: {
                                Text("Color")
                                    .fontWeight(.semibold)
                                    .padding()
                                Spacer()
                                Circle()
                                    .fill(.blue)
                                    .frame(width: 30, height: 30)
                                    .padding(10)
                            })
                            .frame(height: 50)
                            .foregroundColor(.gray)
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1))
                            .padding(10)
                        }
                        .padding(.horizontal, 4)
                        VStack(alignment: .leading) {
                            if !(product.product_bundle.isEmpty) {
                                Text("W zestawie:")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                BundlesProductsView(bundleDict: product.product_bundle)
                            }
                            NavigationLink(
                                destination: WebView(text: $productDesc),
                                label: {
                                    VStack {
                                        Text("Opis")
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                            .multilineTextAlignment(.leading)
                                            .padding()
                                        Text(productDesc.html2String)
                                    }
                            })
                            Text("Szczegóły produktu")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                            HStack {
                                Text("Marka: ")
                                    .fontWeight(.bold)
                                Text(product.manufacturer_name)
                            }.padding(1)
                            HStack {
                                Text("Indeks: ")
                                    .fontWeight(.bold)
                                Text(product.reference)
                            }.padding(1)
                            ForEach(features.sorted(by: >), id: \.key) { key, value in
                                HStack {
                                    Text("\(key): ")
                                        .fontWeight(.bold)
                                    Text(value)
                                }.padding(1)
                            }

                            if !(product.accessories.isEmpty) {
                                Text("Proponowane")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.leading)
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(suggestedProducts) { product in
                                            ProductGridSquare(product: product).padding(5)
                                        }
                                    }
                                }
                            }
                        }.padding()
                    }

                }
                    .navigationBarTitle("Produkt", displayMode: .inline)
            } else {
                ProgressView().onAppear(perform: {
                    print("accesories")
                    print(product.accessories)
                    self.productDesc = product.description
                    for number in 1...30 {
                        self.productDesc = productDesc.replacingOccurrences(of: "font-size:\(number)px", with: "font-size:\(number + 38)px").replacingOccurrences(of: "font-size:\(number)pt", with: "font-size:\(number + 38)pt")
                    }
                    print(self.productDesc)
                    self.getAllImages()
                    let favArr = (defaults.array(forKey: "favouriteItems") ?? [Int]()) as [Int]
                    if favArr.contains(product.id) {
                        isProductFavourite = true
                    }
                })
            }
        }

    func getAllImages() {
        links = [URL]()
        let productsLink = "\(globalURL)/products/\(product.id)?\(apiKey)&io_format=JSON"
        AF.request(productsLink, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("alamofire entered")
                for (_,subJson):(String, JSON) in json["product"]["associations"]["images"] {

                    let url = URL(string: "\(globalURL)/images/products/\(self.product.id)/\(subJson["id"])/large_default/?\(apiKey)")!

                    self.links.append(url)
                    print(url)
                }

                if !(product.product_features.isEmpty) {
                    var productFeatures = Dictionary<Int, String>()
                    var productFeaturesvalues = Dictionary<Int, String>()
                    let featuresValuesLink = "\(globalURL)/product_feature_values?\(apiKey)&filter[id]=\(product.product_features.values)&display=full&io_format=JSON"
                    let featuresLink = "\(globalURL)/product_features?\(apiKey)&filter[id]=\(product.product_features.keys)&display=full&io_format=JSON"

                    downloadGroup.enter()
                    downloadGroup.enter()

                    print(featuresLink.replacingOccurrences(of: ", ", with: "|"))
                    AF.request(featuresLink.replacingOccurrences(of: ", ", with: "|").addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
                        switch response.result {
                        case .success(let value):
                            print("process one started")
                            let json = JSON(value)

                            for (_,subJson):(String, JSON) in json["product_features"] {
                                productFeatures[subJson["id"].int!] = subJson["name"].stringValue
                            }

                            print(productFeatures)
                            downloadGroup.leave()

                        case .failure(let error):
                            print(error)
                        }
                    }

                    print(featuresValuesLink.replacingOccurrences(of: ", ", with: "|"))
                    AF.request(featuresValuesLink.replacingOccurrences(of: ", ", with: "|").addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
                        switch response.result {
                        case .success(let value):
                            print("process two started")
                            let json = JSON(value)

                            for (_,subJson):(String, JSON) in json["product_feature_values"] {
                                productFeaturesvalues[subJson["id"].int!] = subJson["value"].stringValue
                            }

                            print(productFeaturesvalues)
                            downloadGroup.leave()
                        case .failure(let error):
                            print(error)
                        }
                    }

                    DispatchQueue.global(qos: .background).async {
                        downloadGroup.wait()
                        DispatchQueue.main.async {
                            print("download completed")
                            for (key,value) in self.product.product_features {
                                features[productFeatures[key]!] = productFeaturesvalues[value]
                            }
                            print(features)
                            getSuggestions()
                        }
                    }

                }
                else {
                    getSuggestions()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func getSuggestions() {
        if product.accessories != [Int]() {
            let suggestionsLink = "\(globalURL)/products?\(apiKey)&io_format=JSON&filter[active]=[1]&display=full&filter[id]=\(product.accessories)"
            AF.request(suggestionsLink.replacingOccurrences(of: ", ", with: "|").addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)

                    for (_,subJson):(String, JSON) in json["products"] {
                        var product_option_valuesArray = [Int]()
                        var product_featuresDict = Dictionary<Int,Int>()
                        var accessoriesTab = [Int]()
                        for (_,subSubJson):(String, JSON) in subJson["associations"]["product_option_values"] {
                            product_option_valuesArray.append(subSubJson["id"].intValue)
                        }


                        for (_,subSubJson):(String, JSON) in subJson["associations"]["accessories"] {
                            accessoriesTab.append(subSubJson["id"].intValue)
                        }

                        // this is just shorthand for array1.contains(where: { array2.contains($0) })
                        let tmpProduct = ProductModel(id: subJson["id"].intValue, name: subJson["name"].stringValue, description: subJson["description"].stringValue, defaultImage: subJson["id_default_image"].intValue, price: subJson["price"].doubleValue, description_short: subJson["description_short"].stringValue, product_option_values: product_option_valuesArray, product_features: product_featuresDict, manufacturer_name: subJson["manufacturer_name"].stringValue, reference: subJson["reference"].stringValue, accessories: accessoriesTab)
                        if !(suggestedProducts.contains(tmpProduct)) {
                            self.suggestedProducts.append(tmpProduct)
                        }
                        isProductLoaded = true

                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        else {
            isProductLoaded = true
        }
    }
}


struct PhotoGallery: View {
    var links : [URL]
    var isFullScreen : Bool
    
    var body: some View {
        
        TabView {
            ForEach(links, id: \.self) { link in
                ZStack {
                    KFImage.url(link)
                        .loadDiskFileSynchronously()
                        .cacheMemoryOnly()
                        .fade(duration: 0.2)
                        .placeholder({ProgressView()})
                        .resizable()
                        .scaledToFit()
                        .clipped()
                        .frame(height: screenWidth, alignment: .center)
                    if links.count > 1 {
                        VStack {
                            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.4), Color.black.opacity(0), Color.black.opacity(0), Color.black.opacity(0)]), startPoint: .bottom, endPoint: .center)
                                .scaledToFill()
                        }
                    }
                }
            }
        }
        .onAppear(){
            UIPageControl.appearance().currentPageIndicatorTintColor = .blue;
            UITabBar.appearance().tintColor = .red;
            UITabBar.appearance().backgroundColor = UIColor.red
            UITabBar.appearance().barTintColor = .red;
        }
        .tabViewStyle(PageTabViewStyle()).frame(height: screenWidth, alignment: .center)
    }
}

