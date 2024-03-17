//
//  ProductsView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 17/03/2021.
//

import SwiftUI
import Alamofire
import SwiftyJSON


struct ProductsView: View {
    var productsID: [Int]
    var catTitle: String
    let sortingDir = ["A-Z":"name_ASC","Z-A":"name_DESC","Cena rosnąco":"price_ASC","Cena malejąco":"price_DESC"]
    let sortingKeys = ["A-Z","Z-A","Cena rosnąco","Cena malejąco"]
    
    @StateObject var globalVars = GlobalVars()
    @AppStorage("totalprice") var totalPrice: Double = 0
    @AppStorage("isPopupPresent") var isPopupPresent = false

    
    @State var isDoneBtnVisible = false
    @State var sorting: String = "A-Z"
    @State var minPrice = String()
    @State var maxPrice = String()
    @State var initMinPrice = String()
    @State var initMaxPrice = String()
    @State var isViewList = true
    @State var displayX = false
    @State var areProductsDownloaded = false
    @State var areProductsBackedUp = false
    @State var isFilterViewPresent = false
    @State var areFiltersOn = false
    @State var areFiltersDownloaded = false
    
    @State var products = [ProductModel]()
    @State var backupProducts = [ProductModel]()
    @State var categoriesNamesDict = [Int : String]()
    @State var categoriesValuesDict = [Int : String]()
    @State var filters2 = [Int : [String : [Int]]]() //NAPRAW!!!!
    @State var categoriesValuesDict2 = [String : [Int]]()
    @State var sales = [Int : SpecificPrice]()
    @State var filters = [Int : [Int]]()
    @State var selectedKeys = [Int]()
    @State var backupSelectedKeys = [Int]()
    @State var backupSorting = String()
    @State var searchKey = ""
    
    var body: some View {
        VStack {
            if products == [ProductModel]() && areProductsDownloaded == false {
                ProgressView()
            } else if products == [ProductModel]() && areProductsDownloaded == true {
                Spacer()
                Text("Brak produktów do wyświetlenia")
                Spacer()
            } else { //if products != [ProductModel]() && areProductsDownloaded == true {
                ZStack {
                    //MARK: Products View
                    VStack {
                        HStack {
                            TextField("Wyszukaj...", text: $searchKey, onEditingChanged: { (editingChanged) in
                                displayX = editingChanged == true ? true : false
                            })
                                .padding([.top, .leading, .bottom], 10)
                            if searchKey != String() {
                                if displayX == true {
                                    Button(action: { searchKey = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                    }
                                }
                                Button(action: { self.getProducts(searchFilter: searchKey)
                                    displayX = false
                                }) {
                                    Image(systemName: "magnifyingglass").padding(10)
                                }.accentColor(CColor.bright)
                                .background(CColor.dark)
                            }
                            if areProductsBackedUp == true {
                                Button(action: {
                                    areProductsBackedUp = false
                                    searchKey = ""
                                    if backupSorting == sorting {
                                        products = backupProducts
                                    } else {
                                        products = [ProductModel]()
                                        getProducts(searchFilter: searchKey)
                                    }
                                    backupProducts = [ProductModel]()
                                    UIApplication.shared.endEditing()
                                }, label: {
                                    Text("Wyczyść").padding()
                                })
                            }
                        }
                        .background(CColor.bright).frame(height: 38).clipped().accentColor(CColor.dark)
                        if isViewList == true {
                            ScrollView {
                                LazyVStack {
                                    ForEach(products) { product in
                                        ProductRow(product: product)
                                            .border(CColor.bright, width: 0.7)
                                            .padding(.horizontal, 19)
                                            .padding(.vertical, 4)
                                    }
                                }
                            }
                        } else {
                            ProductGridView(products: products)
                        }
                    }
                    
                    //MARK: Filter View
                    if isFilterViewPresent == true {
                        VStack {
                            HStack {
                                Text("Filtry")
                                    .font(.system(size: 40))
                                    .fontWeight(.bold)
                                    .padding()
                                Spacer()
                                Button(action: {self.selectedKeys.removeAll(); self.minPrice = self.initMinPrice; self.maxPrice = self.initMaxPrice}, label: {
                                    Text("Wyczyść")
                                })
                                .foregroundColor(CColor.dark)
                                Button(action: {
                                    withAnimation {
                                        self.isFilterViewPresent = false
                                        self.selectedKeys = self.backupSelectedKeys
                                        self.backupSelectedKeys = [Int]()
                                    }
                                }, label: {
                                    Image(systemName: "xmark").padding()
                                })
                            }
                            FilterView(filters: filters2, categoriesNamesDict: categoriesNamesDict, categoriesValuesDict: categoriesValuesDict, selectedKeys: $selectedKeys, isDoneBtnVisible: $isDoneBtnVisible, minPrice: $minPrice, maxPrice: $maxPrice)
                                .transition(.moveAndFade)
                            HStack {

                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        if selectedKeys.isEmpty && minPrice == initMinPrice && maxPrice == initMaxPrice {
                                            self.products.removeAll()
                                            self.areFiltersOn = false
                                            self.getProducts(searchFilter: self.searchKey)
                                            
                                        } else {
                                            self.areFiltersOn = true
                                            self.getProducts(searchFilter: self.searchKey)
                                        }
                                        self.isFilterViewPresent = false
                                    }
                                }, label: {
                                    Spacer()
                                    Text("Filtruj")
                                        .fontWeight(.bold)
                                    Spacer()
                                })
                                .padding(20.0)
                                .foregroundColor(.white)
                                .background(CColor.purpleGradient)
                                .cornerRadius(15)
                            }
                            .padding(6.0)
                            
                            if isDoneBtnVisible == true {
                                Button(action: hideKeyboard, label: {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                    Text("Gotowe")
                                    Spacer()
                                })
                                .padding(10.0)
                                .foregroundColor(CColor.bright)
                                .background(CColor.dark)
                            }
                        }
                            .background(CColor.bright)
                            .onDisappear(){self.isDoneBtnVisible=false}
                            .onAppear(){self.backupSelectedKeys = self.selectedKeys}
                    }
                    
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {self.isViewList = true}) {
                    Image(systemName: "list.bullet")
                }
                Button(action: {self.isViewList = false}) {
                    Image(systemName: "square.grid.2x2")
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation {
                        self.isFilterViewPresent.toggle()
                    }
                }) {
                    Image(systemName: "slider.horizontal.3")
                }.disabled(!areFiltersDownloaded)
                Menu {
                    ForEach(sortingKeys, id: \.self) { sort in
                        Button(action: {self.sorting = sort}, label: {
                            Text(sort)
                            Spacer()
                            if sorting == sort {
                                Image(systemName: "checkmark")
                            }
                        })
                    }
                } label: {Image(systemName: "arrow.up.arrow.down")}
            }
        }
        .navigationBarTitle(catTitle == "MAIN_CAT" ? "Cały katalog" : catTitle, displayMode: .inline)
        .onAppear(){
            getSales()
        }
        .onChange(of: sorting) { sor in
            self.products = [ProductModel]()
            self.areProductsDownloaded = false
            self.getProducts(searchFilter: searchKey)
        }
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
                    getProducts(searchFilter: "")
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
                    getProducts(searchFilter: "")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getProducts(searchFilter: String) {
        var tmpKeysArr = [Int]()
        var tmpValuesArr = [Int]()
        var tmpMinPrice = 0.0
        var tmpMaxPrice = 0.0
        areProductsDownloaded = false
        if products == [ProductModel]() || searchFilter != "" || areFiltersOn == true {
            var productsLink = "\(globalURL)/products/?\(apiKey)&io_format=JSON&filter[active]=[1]&display=full&sort=[\(sortingDir[sorting]!)]\(catTitle == "MAIN_CAT" ? "" : "&filter[id]=\(productsID)")"
            //var productsLink = "https://presta.dynamitedev.pl/api/products/?ws_key=B2KAHSFPZNQXVLHYC894QTVIWTWBASFV&io_format=JSON&display=full&sort=[name_ASC]"
            if searchFilter != "" {
                if areProductsBackedUp == false {
                    backupProducts = products
                    backupSorting = sorting
                    areProductsBackedUp = true
                }
                products = [ProductModel]()
                productsLink = "\(productsLink)&filter[name]=%[\(searchFilter)]%"
            }
            
            if areFiltersOn == true {
                if areProductsBackedUp == false {
                    backupProducts = products
                    backupSorting = sorting
                    areProductsBackedUp = true
                }
                products = [ProductModel]()
                productsLink += "&filter[price]=[\(Double(minPrice.replacingOccurrences(of: ",", with: "."))!/1.23),\(Double(maxPrice.replacingOccurrences(of: ",", with: "."))! / 1.23)]"
            }
            productsLink = productsLink.replacingOccurrences(of: ", ", with: "|")
            AF.request(productsLink.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
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
                            if !(tmpKeysArr.contains(subSubJson["id"].intValue)) {
                                tmpKeysArr.append(subSubJson["id"].intValue)
                            }
                            
                            if !(tmpValuesArr.contains(subSubJson["id_feature_value"].intValue)) {
                                tmpValuesArr.append(subSubJson["id_feature_value"].intValue)
                            }
                        }
                        
                        if tmpMinPrice == 0 {
                            tmpMinPrice = subJson["price"].doubleValue
                            tmpMaxPrice = subJson["price"].doubleValue
                        }
                        
                        if subJson["price"].doubleValue < tmpMinPrice {
                            tmpMinPrice = subJson["price"].doubleValue
                        }
                        
                        if subJson["price"].doubleValue > tmpMaxPrice {
                            tmpMaxPrice = subJson["price"].doubleValue
                        }
                        
                        for (_,subSubJson):(String, JSON) in subJson["associations"]["accessories"] {
                            accessoriesTab.append(subSubJson["id"].intValue)
                        }
                        
                        // this is just shorthand for array1.contains(where: { array2.contains($0) })
                        if product_featuresDict.values.contains(where: selectedKeys.contains) || self.selectedKeys.isEmpty || areFiltersOn == false {
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
                            
                            if subJson["type"].stringValue == "pack" {
                                for (_,subSubJson):(String, JSON) in subJson["associations"]["product_bundle"] {
                                    tmpProduct.product_bundle[subSubJson["id"].intValue] = subSubJson["quantity"].intValue
                                }
                                print(tmpProduct.product_bundle)
                            }
                            
                            if !(products.contains(tmpProduct)) {
                                self.products.append(tmpProduct)
                            }
                        }
                        
                        

                    }
                    self.minPrice = String(format: "%.2f", tmpMinPrice*1.23).replacingOccurrences(of: ".", with: ",")
                    self.maxPrice = String(format: "%.2f", tmpMaxPrice*1.23).replacingOccurrences(of: ".", with: ",")
                    
                    if areFiltersDownloaded == false {
                        self.initMinPrice = self.minPrice
                        self.initMaxPrice = self.maxPrice
                        getFilters(keysArr: tmpKeysArr, valuesArr: tmpValuesArr)
                    }
                    
                    areProductsDownloaded = true
                    print("tmpMinPrice: \(tmpMinPrice), maxPrice: \(maxPrice)")

                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func getFilters(keysArr : [Int], valuesArr : [Int]) {
        let keysLink = "\(globalURL)/product_features?\(apiKey)&io_format=JSON&display=[id,name]&filter[id]=\(keysArr)"
        let valuesLink = "\(globalURL)/product_feature_values?\(apiKey)&io_format=JSON&display=[id,value,id_feature]&filter[id]=\(valuesArr)"
        let downloadGroup = DispatchGroup()
        
        downloadGroup.enter()
        
        //MARK: pobiera nazwy kategorii
        AF.request(keysLink.replacingOccurrences(of: ", ", with: "|").addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                for (_,subJson):(String, JSON) in json["product_features"] {
                    categoriesNamesDict[subJson["id"].intValue] = subJson["name"].stringValue
                }
                
                downloadGroup.leave()
            case .failure(let error):
                print(error)
            }
        }
        
        //MARK: pobiera wartości
        DispatchQueue.global(qos: .background).async {
            downloadGroup.wait()
            DispatchQueue.main.async {
                AF.request(valuesLink.replacingOccurrences(of: ", ", with: "|").addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, method: .get).validate().responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        
                        for (_,subJson):(String, JSON) in json["product_feature_values"] {
                            categoriesValuesDict[subJson["position"].intValue] = subJson["value"].stringValue
                            filters[subJson["id_feature"].intValue, default: [Int]()].append(subJson["id"].intValue)
                            filters2[subJson["id_feature"].intValue, default: [String : [Int]]()][subJson["value"].stringValue, default: [Int]()].append(subJson["id"].intValue)
                        }
                        
                        areFiltersDownloaded = true
                    case .failure(let error):
                        print("error: \(error)")
                    }
                }
            }
        }
        
    }
    
}

struct ProductsView_Previews: PreviewProvider {
    static var previews: some View {
        ProductsView(productsID: [0], catTitle: "Cat_title")
    }
}
