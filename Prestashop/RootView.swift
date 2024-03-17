//
//  RootView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 14/03/2021.
//

import SwiftUI

struct RootView: View {
    @AppStorage("itemsBadge") var itemsBadge : Int = 0
    @StateObject var globalVars = GlobalVars()
    @State private var flag = true
    private let badgePosition: CGFloat = 3
    private let tabsCount: CGFloat = 4
    
    var body: some View {
        if flag == true || flag == false {
            GeometryReader { geometry in
                ZStack(alignment: .bottomLeading) {
                    TabView {
                        ProfileView()
                            .tabItem {
                                Image(systemName: "person.crop.circle")
                                Text("Profil")
                            }
                        NavigationView {
                            CategoriesView(selectedCategory: Category(id: 0, depth: 0, subcategories: [0], name: "MAIN_CAT", productsIds: [0])).navigationViewStyle(StackNavigationViewStyle())
                        }
                            .tabItem {
                                Image(systemName: "list.bullet")
                                Text("Produkty")
                            }
                        CartView().environmentObject(globalVars)
                            .tabItem {
                                Label("Koszyk", systemImage: "cart.fill")
                            }
                        FavouriteView()
                            .tabItem {
                                Label("Ulubione", systemImage: "heart.fill")
                            }
                    }.accentColor(CColor.fPurple)
                    
                    if itemsBadge > 0 {
                        ZStack {
                          Circle()
                                .foregroundColor(CColor.fYellow)

                          Text("\(self.itemsBadge)")
                            .foregroundColor(.white)
                            .font(Font.system(size: 10))
                        }
                        .frame(width: 16, height: 16)
                        .offset(x: ((2 * self.badgePosition) - 1 ) * (geometry.size.width/(2*self.tabsCount)), y: -30)
                    }
                }
                .ignoresSafeArea(.keyboard)
            }.onChange(of: itemsBadge, perform: {value in self.flag.toggle()})
        }

    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
