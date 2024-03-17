//
//  SearchView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 26/05/2022.
//

import SwiftUI
import Kingfisher
import SwiftyJSON
import Alamofire

struct SearchView: View {
    @State var searchKey = String()
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField("Search...", text: $searchKey)
                if searchKey != "" {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.medium)
                        .foregroundColor(.secondary)
                        .padding(3)
                        .onTapGesture {
                            withAnimation {
                                self.searchKey = ""
                            }
                        }
                    
                }
            }
            .padding(10)
            .background(CColor.lightGray)
            .cornerRadius(12)
            .padding(.vertical, 10)
            .padding(8)
            Text("Często szukane")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            Spacer()
        }
    }
    
    func getSuggested() {
        
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
        
    }
}
