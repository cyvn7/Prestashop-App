//
//  ProductList.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 18/03/2021.
//

import SwiftUI
import Kingfisher

struct ProductList: View {
    var products: [ProductModel]
    
    var body: some View {
        ScrollView {
            ForEach(products) { product in
                ProductRow(product: product)
                    .border(CColor.bright, width: 0.7)
                    .padding(.horizontal, 19)
                    .padding(.vertical, 4)
            }
        }
    }
}

struct ProductRow: View {
    @StateObject var globalVars = GlobalVars()
    //@AppStorage("changeActivator") var changeActivator = false
    @State var isProductFavourite = Bool()
    @State var isLoaded = false
    let defaults = UserDefaults.standard
    var product: ProductModel
    let cartClass: ModyfingCart = ModyfingCart()
    
    var body: some View {
        NavigationLink(destination: ProductDetailsView(product: product, isProductFavourite: $isProductFavourite).popup(isPresented: globalVars.isPopupVisible, alignment: .bottom, direction: .bottom, content: Snackbar.init)) {
            HStack {
                if isLoaded == true {
                    ZStack(alignment: .leading) {
                        KFImage
                            .url(URL(string: "\(globalURL)/images/products/\(product.id)/\(product.defaultImage)/medium_default/?\(apiKey)"))
                            .placeholder({ProgressView()})
                            .loadDiskFileSynchronously()
                            .cacheMemoryOnly()
                            .fade(duration: 0.2)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 110, height: 110.0)
                            .clipped()
                        
                            VStack(alignment: .leading) {
                                if !(product.product_bundle.isEmpty) {
                                    Text("Pakiet")
                                        .foregroundColor(.white)
                                        .background(
                                            Capsule()
                                                .fill(CColor.fYellow)
                                        )
                                        .padding(0.3)
                                }
                                if product.specificPrice.reduction_type == "amount" {
                                    Text("-" + String(format: "%.2f", (product.specificPrice.reduction * 1.23)) + "zł")
                                        .foregroundColor(.white)
                                        .background(
                                            Capsule()
                                                .fill(CColor.fPurple)
                                        )
                                        .padding(0.3)
                                } else if product.specificPrice.reduction_type == "percentage" {
                                    Text("-" + String(format: "%.0f", (product.specificPrice.reduction * 100)) + "%")
                                        .foregroundColor(.white)
                                        .background(
                                            Capsule()
                                                .fill(CColor.fPurple)
                                        )
                                        .padding(0.3)
                                }
                                Spacer()
                            }
                        
                    }
                }
                VStack(alignment: .leading) {
                    Spacer()
                    Text(product.name)
                        .fontWeight(.semibold)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.leading)
                    if product.salePrice == Double() {
                        Text(String(format: "%.2f", (product.price * 1.23)) + "zł")
                            .padding(.top, 5.0)
                            .font(.system(size: 12))
                    } else {
                        HStack {
                            Text(String(format: "%.2f", (product.salePrice * 1.23)) + "zł")
                                .padding(.top, 5.0)
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            
                            Text(String(format: "%.2f", (product.price * 1.23)) + "zł")
                                .strikethrough()
                                .padding(.top, 5.0)
                                .font(.system(size: 8))
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }
                Spacer()
                //if changeActivator == true || changeActivator == false {
                    Button(action: {
                        var favArr = (UserDefaults.standard.array(forKey: "favouriteItems") ?? []) as! [Int]
                        if favArr.contains(product.id) {
                            favArr = favArr.filter { $0 != product.id }
                        } else {
                            favArr.append(product.id)
                        }
                        isProductFavourite.toggle()
                        defaults.set(favArr, forKey: "favouriteItems")
                        print(favArr)
                        lightHaptic.prepare()
                        lightHaptic.impactOccurred()
                        }, label: {
                            Image(systemName: isProductFavourite ? "heart.fill" : "heart").font(.system(size: 20)).padding()
                    })
                //}
                
            }.buttonStyle(PlainButtonStyle())
            .onAppear(){
                let favArr = (defaults.array(forKey: "favouriteItems") ?? [Int]()) as! [Int]
                if favArr.contains(product.id) {
                    isProductFavourite = true
                } else {
                    isProductFavourite = false
                }
                self.isLoaded = true
            }
        }
    }
    
    func checkIfFav() {
        let favArr = (defaults.array(forKey: "favouriteItems") ?? [Int]()) as! [Int]
        if favArr.contains(product.id) {
            isProductFavourite = true
        } else {
            isProductFavourite = false
        }
    }
}
