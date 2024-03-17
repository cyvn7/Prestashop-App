//
//  BundlesProductsView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 25/05/2021.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import Kingfisher

struct BundlesProductsView: View {
    var bundleDict : [Int : Int]
    @State var products = [ProductModel]()
    @State var areProductsDownloaded = false
    var body: some View {
        if areProductsDownloaded == false {
            ProgressView().onAppear(perform: getProducts)
        } else {
            ForEach(products) { product in
                HStack {
                    KFImage
                        .url(URL(string: "\(globalURL)/images/products/\(product.id)/\(product.defaultImage)/medium_default/?\(apiKey)"))
                        .placeholder({ProgressView()})
                        .loadDiskFileSynchronously()
                        .cacheMemoryOnly()
                        .fade(duration: 0.2)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 78, height: 78)
                        .clipped()
                    Text(product.name)
                        .padding(.vertical, 8)
                    Spacer()
                    Text("x\(bundleDict[product.id]!)").padding(9)
                        .foregroundColor(.purple)
                }
                .border(CColor.bright, width: 0.7)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
        }
    }
    
    func getProducts() {
        let link = ("\(globalURL)/products?\(apiKey)&filter[id]=\(bundleDict.keys)&display=full&io_format=JSON").replacingOccurrences(of: ", ", with: "|").addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        
        AF.request(link, method: .get).validate().responseJSON { response in
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
                    
                    for (_,subSubJson):(String, JSON) in subJson["associations"]["product_features"] {
                        product_featuresDict[subSubJson["id"].intValue] = subSubJson["id_feature_value"].intValue
                    }
                    
                    for (_,subSubJson):(String, JSON) in subJson["associations"]["accessories"] {
                        accessoriesTab.append(subSubJson["id"].intValue)
                    }
                    
                    var tmpProduct = ProductModel(id: subJson["id"].intValue, name: subJson["name"].stringValue, description: subJson["description"].stringValue, defaultImage: subJson["id_default_image"].intValue, price: subJson["price"].doubleValue, description_short: subJson["description_short"].stringValue, product_option_values: product_option_valuesArray, product_features: product_featuresDict, manufacturer_name: subJson["manufacturer_name"].stringValue, reference: subJson["reference"].stringValue, accessories: accessoriesTab)
                    
                    if subJson["type"].stringValue == "pack" {
                        for (_,subSubJson):(String, JSON) in subJson["associations"]["product_bundle"] {
                            tmpProduct.product_bundle[subSubJson["id"].intValue] = subSubJson["quantity"].intValue
                        }
                    }
                    
                    if !(products.contains(tmpProduct)) {
                        self.products.append(tmpProduct)
                        print("in BundleView: \(tmpProduct)")
                    }

                }
                
                areProductsDownloaded = true

            case .failure(let error):
                print(error)
            }
        }
    }
}

struct BundlesProductsView_Previews: PreviewProvider {
    static var previews: some View {
        BundlesProductsView(bundleDict: [0 : 0])
    }
}
