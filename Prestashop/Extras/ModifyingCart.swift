//
//  ModyfingCart.swift
//  dynashop
//
//  Created by Maciej Przybylski on 11/02/2021.
//  Copyright © 2021 Maciej Przybylski. All rights reserved.
//

import SwiftUI
import Alamofire
import Foundation
import SwiftyJSON

//read.me -- adresy i userid są zakodowane domyślnie, jeśli zmieniasz konto musisz popraciwać nad nimi


class ModyfingCart {
    let defaults = UserDefaults.standard
    @AppStorage("itemsBadge") var itemsBadge: Int = 0
    @AppStorage("isPopupPresent") var isPopupPresent = false
    @StateObject var globalVars = GlobalVars()
    let cartClass: CartView = CartView()
    var localProductID = Int()
    var localQuantity = Int()
    var localPrice = Double()
    var localCartVisible = Bool()
    var stringToSend = ""
    var userID = Int()
    
    func modifyProduct(productID: Int, quantity: Int, ifDelete: Bool, pricePerPiece: Double, isCartVisible: Bool) -> String {
        localProductID = productID
        localQuantity = quantity
        localPrice = pricePerPiece
        localCartVisible = isCartVisible
        userID = defaults.integer(forKey: "userID")
        let cartID = defaults.integer(forKey: "cartID")
        globalVars.isTotalPriceUpdated = false
//        if self.localCartVisible == true {
//            isTotalPriceUpdated = false
//        }
        
        if ifDelete == true {
            let dict = defaults.dictionary(forKey: "cartDict")!
            localQuantity = Int(String(describing: dict["\(localProductID)"]!))!
            deleteItem(cartID: cartID)
        } else if cartID == 0 {
            createCart()
        } else {
            updateCart(cartID : cartID)
        }
        return stringToSend
    }
    
    
    func createCart() {
        self.itemsBadge+=localQuantity
        let dictionary = ["\(localProductID)" : "\(localQuantity)"]
        let str = "<prestashop xmlns:xlink='http://www.w3.org/1999/xlink'><cart><id_guest>0</id_guest><id_shop_group>1</id_shop_group><id_customer>\(userID)</id_customer><id_currency>1</id_currency><id_address_delivery>0</id_address_delivery><id_address_invoice>0</id_address_invoice><id_lang>1</id_lang><associations><cart_rows virtualEntity='true' nodeType='cart_row'><cart_row><id_product>\(localProductID)</id_product><id_product_attribute>0</id_product_attribute><quantity>\(localQuantity)</quantity></cart_row></cart_rows></associations></cart></prestashop>"
        
        print(str)

        let url = URL(string: "\(globalURL)/carts?\(apiKey)&display=full&io_format=JSON&ps_method=POST")
        var xmlRequest = URLRequest(url: url!)
        xmlRequest.httpBody = str.data(using: String.Encoding.utf8, allowLossyConversion: true)
        xmlRequest.httpMethod = "POST"
        xmlRequest.addValue("application/xml", forHTTPHeaderField: "Content-Type")


        AF.request(xmlRequest).responseJSON() { (response) in
            let responseJSON = JSON(response.data!)
            self.defaults.set(responseJSON["carts"][0]["id"].intValue, forKey: "cartID")
            self.defaults.set(dictionary, forKey: "cartDict")
            print(dictionary)
            print("cardID")
            print(responseJSON)
        }
        
    }
    

    func updateCart(cartID:Int) {
        self.itemsBadge+=localQuantity
        var dict = defaults.dictionary(forKey: "cartDict")!
        if let existingQuantity = (dict["\(localProductID)"] as? NSString)?.intValue {
            dict["\(localProductID)"] = "\(Int(existingQuantity) + localQuantity)"
        } else {
            dict["\(localProductID)"] = "\(localQuantity)"
        }
        createCartStructure(dict: dict, cartID: cartID)
    }
    
    func deleteItem(cartID:Int) {
        self.itemsBadge-=localQuantity
        var dict = defaults.dictionary(forKey: "cartDict")!
        dict.removeValue(forKey: "\(localProductID)")
        createCartStructure(dict: dict, cartID: cartID)
    }
    
    func createCartStructure(dict: Dictionary<String, Any>, cartID:Int) {
        var str = "<prestashop xmlns:xlink='http://www.w3.org/1999/xlink'><cart><id>\(cartID)</id><id_guest>0</id_guest><id_shop_group>1</id_shop_group><id_customer>\(userID)</id_customer><id_currency>1</id_currency><id_address_delivery>0</id_address_delivery><id_address_invoice>0</id_address_invoice><id_lang>1</id_lang><associations><cart_rows virtualEntity='true' nodeType='cart_row'>"
        defaults.set(dict, forKey: "cartDict")
        for (key, value) in dict {
            print(key, value)
            str = "\(str)<cart_row><id_product>\(key)</id_product><id_product_attribute>0</id_product_attribute><quantity>\(value)</quantity></cart_row>"
        }
        str = "\(str)</cart_rows></associations></cart></prestashop>"
        //print(str)
        stringToSend = str
        let url = URL(string: "\(globalURL)/carts/\(cartID)?\(apiKey)&display=full&io_format=JSON&ps_method=PUT")
        var xmlRequest = URLRequest(url: url!)
        xmlRequest.httpBody = str.data(using: String.Encoding.utf8, allowLossyConversion: true)
        xmlRequest.httpMethod = "PUT"
        xmlRequest.addValue("application/xml", forHTTPHeaderField: "Content-Type")
        print(str)
        if localCartVisible == false {
            AF.request(xmlRequest).responseJSON() { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    var tmpBadge = 0
                    for (_,subJson):(String, JSON) in json["carts"][0]["associations"]["cart_rows"] {
                        tmpBadge+=subJson["quantity"].intValue
                    }
                    print(tmpBadge)
                    self.isPopupPresent = true
                    _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
                        self.isPopupPresent = false
                        print(self.isPopupPresent)
                    }
                    self.itemsBadge = tmpBadge
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

