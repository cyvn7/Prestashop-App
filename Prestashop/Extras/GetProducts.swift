////
////  GetProducts.swift
////  Prestashop
////
////  Created by Maciej Przybylski on 26/05/2022.
////
//import SwiftUI
//import Alamofire
//import SwiftyJSON
//
//class GettingProducts {
//    var sales = [Int : SpecificPrice]()
//    
//    func getSales() {
//        let formatter = DateFormatter()
//        let today = Date()
//        formatter.dateFormat = "yyyy-MM-dd"
//        let salesLink = "\(globalURL)/specific_prices?\(apiKey)&io_format=JSON&display=full&filter[to]=>[\(formatter.string(from: today))]&filter[from]=<[\(formatter.string(from: today))]"
//        let salesLink2 = "\(globalURL)/specific_prices?\(apiKey)&io_format=JSON&display=full&filter[to]=[0000-00-00]"
//        var funcDone = 0
//        
//        AF.request(salesLink.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { [self] response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                for (_,subJson):(String, JSON) in json["specific_prices"] {
//                    let dateFormatterGet = DateFormatter()
//                    dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
//
//                    let dateFormatterPrint = DateFormatter()
//                    dateFormatterPrint.dateFormat = "dd.MM.yyyy"
//                    
//                    let date = dateFormatterGet.date(from: subJson["to"].stringValue)
//                    
//                    sales[subJson["id_product"].intValue] = SpecificPrice(id: subJson["id"].intValue, reduction_type: subJson["reduction_type"].stringValue, reduction: subJson["reduction"].doubleValue, endDate: dateFormatterPrint.string(from: date!))
//                }
//                funcDone+=1
//                if funcDone == 2 {
//                    self.getProducts(searchFilter: "")
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//        AF.request(salesLink2.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                for (_,subJson):(String, JSON) in json["specific_prices"] {
//                    sales[subJson["id_product"].intValue] = SpecificPrice(id: subJson["id"].intValue, reduction_type: subJson["reduction_type"].stringValue, reduction: subJson["reduction"].doubleValue, endDate: subJson["to"].stringValue)
//                }
//                funcDone+=1
//                if funcDone == 2 {
//                    getProducts(searchFilter: "")
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
//    
//    func getProducts(searchFilter: String) {
//        var tmpKeysArr = [Int]()
//        var tmpValuesArr = [Int]()
//        var tmpMinPrice = 0.0
//        var tmpMaxPrice = 0.0
//        areProductsDownloaded = false
//        if products == [ProductModel]() || searchFilter != "" || areFiltersOn == true {
//            var productsLink = "\(globalURL)/products/?\(apiKey)&io_format=JSON&filter[active]=[1]&display=full&sort=[\(sortingDir[sorting]!)]\(catTitle == "MAIN_CAT" ? "" : "&filter[id]=\(productsID)")"
//            //var productsLink = "https://presta.dynamitedev.pl/api/products/?ws_key=B2KAHSFPZNQXVLHYC894QTVIWTWBASFV&io_format=JSON&display=full&sort=[name_ASC]"
//            if searchFilter != "" {
//                if areProductsBackedUp == false {
//                    backupProducts = products
//                    backupSorting = sorting
//                    areProductsBackedUp = true
//                }
//                products = [ProductModel]()
//                productsLink = "\(productsLink)&filter[name]=%[\(searchFilter)]%"
//            }
//            
//            if areFiltersOn == true {
//                if areProductsBackedUp == false {
//                    backupProducts = products
//                    backupSorting = sorting
//                    areProductsBackedUp = true
//                }
//                products = [ProductModel]()
//                productsLink += "&filter[price]=[\(Double(minPrice.replacingOccurrences(of: ",", with: "."))!/1.23),\(Double(maxPrice.replacingOccurrences(of: ",", with: "."))! / 1.23)]"
//            }
//            productsLink = productsLink.replacingOccurrences(of: ", ", with: "|")
//            AF.request(productsLink.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
//                switch response.result {
//                case .success(let value):
//                    let json = JSON(value)
//                    
//                    for (_,subJson):(String, JSON) in json["products"] {
//                        var product_option_valuesArray = [Int]()
//                        var product_featuresDict = Dictionary<Int,Int>()
//                        var accessoriesTab = [Int]()
//                        for (_,subSubJson):(String, JSON) in subJson["associations"]["product_option_values"] {
//                            product_option_valuesArray.append(subSubJson["id"].intValue)
//                        }
//                        
//                        for (_,subSubJson):(String, JSON) in subJson["associations"]["product_features"] {
//                            product_featuresDict[subSubJson["id"].intValue] = subSubJson["id_feature_value"].intValue
//                            if !(tmpKeysArr.contains(subSubJson["id"].intValue)) {
//                                tmpKeysArr.append(subSubJson["id"].intValue)
//                            }
//                            
//                            if !(tmpValuesArr.contains(subSubJson["id_feature_value"].intValue)) {
//                                tmpValuesArr.append(subSubJson["id_feature_value"].intValue)
//                            }
//                        }
//                        
//                        if tmpMinPrice == 0 {
//                            tmpMinPrice = subJson["price"].doubleValue
//                            tmpMaxPrice = subJson["price"].doubleValue
//                        }
//                        
//                        if subJson["price"].doubleValue < tmpMinPrice {
//                            tmpMinPrice = subJson["price"].doubleValue
//                        }
//                        
//                        if subJson["price"].doubleValue > tmpMaxPrice {
//                            tmpMaxPrice = subJson["price"].doubleValue
//                        }
//                        
//                        for (_,subSubJson):(String, JSON) in subJson["associations"]["accessories"] {
//                            accessoriesTab.append(subSubJson["id"].intValue)
//                        }
//                        
//                        // this is just shorthand for array1.contains(where: { array2.contains($0) })
//                        if product_featuresDict.values.contains(where: selectedKeys.contains) || self.selectedKeys.isEmpty || areFiltersOn == false {
//                            var tmpProduct = ProductModel(id: subJson["id"].intValue, name: subJson["name"].stringValue, description: subJson["description"].stringValue, defaultImage: subJson["id_default_image"].intValue, price: subJson["price"].doubleValue, description_short: subJson["description_short"].stringValue, product_option_values: product_option_valuesArray, product_features: product_featuresDict, manufacturer_name: subJson["manufacturer_name"].stringValue, reference: subJson["reference"].stringValue, accessories: accessoriesTab)
//                            if let productSale = self.sales[tmpProduct.id] {
//                                tmpProduct.specificPrice = productSale
//                                if productSale.reduction_type == "amount" {
//                                    tmpProduct.salePrice = tmpProduct.price - (productSale.reduction/1.23)
//                                } else {
//                                    tmpProduct.salePrice = tmpProduct.price * (1 - productSale.reduction)
//                                }
//                                //tmpProduct.sale = productSale
//                                print("\(tmpProduct.name) ~ \(tmpProduct.salePrice)")
//                            }
//                            
//                            if subJson["type"].stringValue == "pack" {
//                                for (_,subSubJson):(String, JSON) in subJson["associations"]["product_bundle"] {
//                                    tmpProduct.product_bundle[subSubJson["id"].intValue] = subSubJson["quantity"].intValue
//                                }
//                                print(tmpProduct.product_bundle)
//                            }
//                            
//                            if !(products.contains(tmpProduct)) {
//                                self.products.append(tmpProduct)
//                            }
//                        }
//                        
//                        
//
//                    }
//                    self.minPrice = String(format: "%.2f", tmpMinPrice*1.23).replacingOccurrences(of: ".", with: ",")
//                    self.maxPrice = String(format: "%.2f", tmpMaxPrice*1.23).replacingOccurrences(of: ".", with: ",")
//                    
//                    if areFiltersDownloaded == false {
//                        self.initMinPrice = self.minPrice
//                        self.initMaxPrice = self.maxPrice
//                        getFilters(keysArr: tmpKeysArr, valuesArr: tmpValuesArr)
//                    }
//                    
//                    areProductsDownloaded = true
//                    print("tmpMinPrice: \(tmpMinPrice), maxPrice: \(maxPrice)")
//
//                case .failure(let error):
//                    print(error)
//                }
//            }
//        }
//    }
//    
//    
//}
