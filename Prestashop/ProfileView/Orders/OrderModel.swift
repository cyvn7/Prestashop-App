//
//  OrderModel.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 14/03/2021.
//

struct OrderModel: Identifiable {
    var id: Int
    var id_carrier: Int
    var reference: String
    var date_add: String
    var id_address_delivery: Int
    var products: [ProductInOrderModel]
    var current_state: Int
    var total_paid: Double
}

struct OrderStatusModel: Identifiable {
    var id: Int
    var name: String
    var hex: String
}

struct ProductInOrderModel: Identifiable {
    var id: Int
    var product_name: String
    var quantity: Int
    var price: Double
}

