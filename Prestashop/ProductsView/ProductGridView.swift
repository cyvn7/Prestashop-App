//
//  ProductGridView.swift
//  dynashop
//
//  Created by Maciej Przybylski on 23/07/2020.
//  Copyright © 2020 Maciej Przybylski. All rights reserved.
//

import SwiftUI
import Kingfisher

struct ProductGridView: View {
    var products: [ProductModel]
    func getNumber(number: Int) -> Bool {
        var isEven = false
        if number % 2 == 0 {
            isEven = true
        }
        return isEven
    }
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<products.count) { tmp in
                    if self.getNumber(number: tmp) == true {
                        HStack {
                            Spacer()
                            ProductGridSquare(product: self.products[tmp])
                            Spacer()
                            if tmp < (self.products.count - 1) {
                                ProductGridSquare(product: self.products[tmp + 1])
                            } else {
                                Spacer().frame(width: UIScreen.main.bounds.width/2.3)
                            }
                            Spacer()
                        }.padding(7.0)
                    }
                }
            }
        }
    }
}

struct ProductGridSquare: View {
    let defaults = UserDefaults.standard
    @State var isProductFavourite = false
    @AppStorage("isPopupPresent") var isPopupPresent = false
    @State var isLoaded = false
    var product : ProductModel
    var body: some View {
        NavigationLink(destination: ProductDetailsView(product: product, isProductFavourite: $isProductFavourite).popup(isPresented: isPopupPresent, alignment: .bottom, direction: .bottom, content: Snackbar.init)) {
                VStack(alignment: .leading) {
                    if isLoaded == true {
                        ZStack {
                            KFImage
                                .url(URL(string: "\(globalURL)/images/products/\(product.id)/\(product.defaultImage)/large_default/?\(apiKey)"))
                                .placeholder({ProgressView()})
                                .cacheMemoryOnly()
                                .fade(duration: 0.2)
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width/2.3, height: UIScreen.main.bounds.width/2.3, alignment: .center)
                                .clipped()
                                .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.gray, lineWidth: 0.7)
                                        )
                            
                            
                            HStack(alignment: .top) {
                                    VStack(alignment: .leading) {
                                        if !(product.product_bundle.isEmpty) {
                                            Text("Pakiet")
                                                .foregroundColor(.white)
                                                .background(Color.purple)
                                        }
                                        if product.salePrice != Double() {
                                            if product.specificPrice.reduction_type == "amount" {
                                                Text("-" + String(format: "%.2f", (product.specificPrice.reduction * 1.23)) + "zł")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Color.white)
                                                    .background(Color.orange)
                                            } else {
                                                Text("-" + String(format: "%.0f", (product.specificPrice.reduction*100)) + "%")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Color.white)
                                                    .background(Color.orange)
                                            }
                                        }
                                        Spacer()
                                    }
                                    Spacer()
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
                                            Image(systemName: isProductFavourite == true ? "heart.circle.fill" : "heart.circle").font(.system(size: 20)).foregroundColor(isProductFavourite == true ? Color.red : Color.gray).padding(8)
                                    })
                                }
                                Spacer()
                            
                        }
                        .frame(width: UIScreen.main.bounds.width/2.3, height: UIScreen.main.bounds.width/2.3, alignment: .center)
                    }
                    VStack(alignment: .leading) {
                        Text(product.name)
                            .font(.system(size: 12))
                        if product.salePrice == Double() {
                            Text(String(format: "%.2f", (product.price * 1.23)) + "zł")
                                .font(.system(size: 12))
                                .foregroundColor(Color.gray)
                        } else {
                            HStack {
                                Text(String(format: "%.2f", (product.salePrice * 1.23)) + "zł")
                                    .font(.system(size: 12))
                                    .foregroundColor(.orange)
                                
                                Text(String(format: "%.2f", (product.price * 1.23)) + "zł")
                                    .strikethrough()
                                    .font(.system(size: 8))
                                    .foregroundColor(.gray)
                            }
                        }
                    }.padding(5)
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width/2.3, height: (UIScreen.main.bounds.width/2.1)*1.25)
                .clipped()
            }.onAppear(perform: checkIfFav)
        //.buttonStyle(PlainButtonStyle())
    }
    
    func checkIfFav() {
        let favArr = (defaults.array(forKey: "favouriteItems") ?? [Int]()) as! [Int]
        if favArr.contains(product.id) {
            isProductFavourite = true
        } else {
            isProductFavourite = false
        }
        isLoaded = true
    }
}



//
//struct ProductGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProductGridView(products: testData)
//    }
//}
