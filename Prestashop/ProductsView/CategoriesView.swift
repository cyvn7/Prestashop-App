//
//  CategoriesView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 16/03/2021.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct CategoriesView: View {
    @State var categoryName = ""
    @State var categories = [Category]()
    @State var displayMode = NavigationBarItem.TitleDisplayMode.inline
    @State var isNavigationBarHidden: Bool = false
    var selectedCategory : Category
    
    var body: some View {
        if categories == [Category]() {
            ProgressView()
                .onAppear(perform: downloadCategories)
        } else {
            List {
                NavigationLink(destination: ProductsView(productsID: selectedCategory.productsIds, catTitle: selectedCategory.name)) {
                    Text("Wszystkie produkty")
                }
                
                ForEach(categories) { cat in
                    if cat.subcategories.isEmpty == true {
                        NavigationLink(destination: ProductsView(productsID: cat.productsIds, catTitle: cat.name)) {
                            Text(cat.name)
                        }.isDetailLink(true)
                    } else {
                        NavigationLink(destination: CategoriesView(selectedCategory: cat)) {
                            Text(cat.name)
                        }.isDetailLink(false)
                    }
                }
            }
            .navigationBarTitle(categoryName, displayMode: displayMode)
        }
    }
    
    func downloadCategories() {
        var link = String()

        if selectedCategory.id == 0 {
            link = "\(globalURL)/categories/?\(apiKey)&io_format=JSON&sort=[name_ASC]&filter[level_depth]=[2]&display=full"
            categoryName = "Kategorie"
            displayMode = NavigationBarItem.TitleDisplayMode.large
            
        } else {
            link = "\(globalURL)/categories/?\(apiKey)&io_format=JSON&sort=[name_ASC]&filter[id]=\(selectedCategory.subcategories)&display=full"
            categoryName = selectedCategory.name
            displayMode = NavigationBarItem.TitleDisplayMode.inline
        }
        link = link.replacingOccurrences(of: ", ", with: "|").addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        print(link)
        AF.request(link, method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                categories = [Category]()
                let json = JSON(value)
                for (_,subJson):(String, JSON) in json["categories"] {
                    categories.append(Category(id: subJson["id"].intValue, depth: subJson["level_depth"].intValue, subcategories: subJson["associations"]["categories"].arrayValue.map { $0["id"].intValue}, name: subJson["name"].stringValue, productsIds: subJson["associations"]["products"].arrayValue.map { $0["id"].intValue}))
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
}

//struct CategoriesView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesView()
//    }
//}
