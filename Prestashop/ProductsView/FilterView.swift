//
//  FilterView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 04/04/2021.
//

import SwiftUI

struct FilterView: View {
    
    var filters : [Int : [String : [Int]]]
    var categoriesNamesDict : [Int : String]
    var categoriesValuesDict : [Int : String]
    var selectedKeys : Binding<[Int]>
    var isDoneBtnVisible: Binding<Bool>
    var minPrice : Binding<String>
    var maxPrice : Binding<String>
    var body: some View {
        List {
            Text("Cena")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            HStack {
                VStack(alignment: .leading) {
                    Text("od")
                        .font(.system(size: 14))
                    TextField("minimum", text: minPrice, onEditingChanged: { (editingChanged) in
                        if editingChanged {
                            self.isDoneBtnVisible.wrappedValue = true
                        } else {
                            self.isDoneBtnVisible.wrappedValue = false
                        }
                    })
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                VStack(alignment: .leading) {
                    Text("do:")
                        .font(.system(size: 14))
                    TextField("maximum", text: maxPrice, onEditingChanged: { (editingChanged) in
                        if editingChanged {
                            self.isDoneBtnVisible.wrappedValue = true
                        } else {
                            self.isDoneBtnVisible.wrappedValue = false
                        }
                    })
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            ForEach(categoriesNamesDict.sorted(by: <), id: \.key) { key, value in
                DisclosureGroup {
                    VStack(alignment: .leading) {
                        ForEach(filters[key]!.keys.sorted(), id: \.self) { name in
                            HStack {
                                Text(name)
                                        .padding(8)
                                        .accentColor(CColor.dark)
                                Spacer()
                                if selectedKeys.wrappedValue.contains(where: filters[key]![name]!.contains) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(CColor.fPurple)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                    if selectedKeys.wrappedValue.contains(where: filters[key]![name]!.contains) {
                                        selectedKeys.wrappedValue = Array(Set(selectedKeys.wrappedValue).subtracting(filters[key]![name]!))
                                    } else {
                                        selectedKeys.wrappedValue.append(contentsOf: filters[key]![name]!)
                                    }
                                    lightHaptic.prepare()
                                    lightHaptic.impactOccurred()
                                    print("selectedKeys: \(selectedKeys.wrappedValue)")
                        }
                            
                        }.padding(2)
                    }
                } label: {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                }
            }
        }
        .listStyle(.inset)
        
    }
    
}

//struct FilterView_Previews: PreviewProvider {
//    static var previews: some View {
//        FilterView()
//            .preferredColorScheme(.light)
//    }
//}
