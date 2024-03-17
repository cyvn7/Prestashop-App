//
//  ProductStructs.swift
//  dynashop
//
//  Created by Maciej Przybylski on 28/07/2020.
//  Copyright © 2020 Maciej Przybylski. All rights reserved.
//


struct ProductModel: Identifiable, Equatable {
    var id: Int
    var name: String
    var description: String
    var defaultImage: Int
    var price: Double
    var description_short: String
    var product_option_values: [Int]
    var product_features: Dictionary<Int, Int>
    var manufacturer_name: String
    var reference: String
    var accessories: [Int]
    var isAvailable = true
    var salePrice = Double()
    var specificPrice = SpecificPrice(id: Int(), reduction_type: String(), reduction: Double(), endDate: String())
    var product_bundle = [Int : Int]()
}

struct CartItem: Equatable, Identifiable {
    var id: Int
    var quantity: Int
    var price: Double
    var name: String
    var defaultImage: Int
}

struct Category: Identifiable, Equatable {
    var id: Int
    var depth: Int
    var subcategories: [Int]
    var name: String
    var productsIds: [Int]
}

struct SpecificPrice: Identifiable, Equatable {
    var id: Int
    var reduction_type: String
    var reduction: Double
    var endDate: String
}
let testData: [ProductModel] = [ProductModel(id: 0, name: "Samsung Galaxy Alpha Omega S24+ Plus Lite M Pro Double", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce pulvinar ex ut ex mollis, ut lacinia leo posuere. Ut non ex tincidunt, mollis mi consectetur, dictum enim. Fusce et arcu ut leo tempor bibendum. Sed molestie sed sapien non aliquet. Sed semper interdum efficitur. Nam lacinia sit amet arcu a viverra. Proin eu orci eu felis porta gravida. Sed a justo id velit iaculis pretium eu vel felis. Fusce auctor semper augue. Sed imperdiet ac nisi in tincidunt. Nullam at nisi felis. Etiam semper ac dui vel vehicula. Donec vel auctor magna. Nunc euismod odio non nunc accumsan, vel vehicula quam tincidunt. Duis ultrices nisl eros, vitae faucibus nunc vehicula eget. Quisque ultrices, lorem quis hendrerit vehicula, leo eros porttitor nisi, sit amet malesuada mauris leo non dolor. Nam mattis, sem sed mattis vulputate, arcu arcu elementum mi, at commodo lacus orci sed nibh. Aenean vel felis leo. Cras viverra blandit commodo. Morbi sapien justo, imperdiet quis risus et, dictum dictum urna. Vestibulum scelerisque semper neque quis fermentum. Maecenas tempus ex eu neque vulputate, nec ornare ante ullamcorper. Morbi tempus enim a aliquam rhoncus. Mauris tempus commodo turpis vitae iaculis. Aliquam et eros vel justo sollicitudin interdum ac eu lectus. Fusce in orci a libero congue interdum sit amet at massa. Aenean pulvinar dictum feugiat. Nunc commodo lorem id ante sodales, ac varius massa laoreet. Proin magna eros, tempor ac pellentesque sed, tincidunt id turpis. Donec ut nisl ultricies, porttitor ligula non, sagittis diam. Donec porttitor, massa id dapibus varius, velit nisi mattis ante, non rutrum orci elit vitae metus. Integer scelerisque id odio et condimentum.", defaultImage: 2, price: 6999.99, description_short: "super jest", product_option_values: [1,2,3], product_features: [1:2], manufacturer_name: "Samsung", reference: "placeholder", accessories: [0,1,2]), ProductModel(id: 1, name: "Airpods Pro", description: "Meh", defaultImage: 5, price: 999.99, description_short: "Pro słuchawki, pro cena", product_option_values: [4,5,6], product_features: [3:4], manufacturer_name: "Beats", reference: "placeholder", accessories: [0,1,2]), ProductModel(id: 2, name: "Beats", description: "Meh v2", defaultImage: 3, price: 9999.99, description_short: "Czujesz ten beat?", product_option_values: [7,8,9], product_features: [5:6], manufacturer_name: "Apple", reference: "placeholder", accessories: [0,1,2])]


