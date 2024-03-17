//
//  CustomStepper.swift
//  dynashop
//
//  Created by Maciej Przybylski on 11/02/2021.
//  Copyright © 2021 Maciej Przybylski. All rights reserved.
//

import SwiftUI

struct CStepper: View {
    var productID = 0
    var value : Binding<Int>
    var pricePerPiece : Double
    let cartClass: ModyfingCart = ModyfingCart()
    //@AppStorage("isTotalPriceUpdated") var isTotalPriceUpdated: Bool = false
    //@State var value = 1
    @State var isMin = false
    @State var isMax = false
    var body: some View {
        HStack {
            Button(action: {
                isMax = false
                value.wrappedValue-=1
                if value.wrappedValue == 1 {isMin = true}
            }, label: {
                Image(systemName: "minus.circle")
            }).padding(.leading, 9).disabled(isMin)
            Text("\(value.wrappedValue)")
                .padding(.horizontal, 8)
                .clipped()
            Button(action: {
                    isMin = false
                    value.wrappedValue+=1
                    if value.wrappedValue == 990 {isMax = true}}, label: {
                        Image(systemName: "plus.circle.fill").foregroundColor(.purple)
            }).padding(.trailing, 9).disabled(isMax)
        }.frame(height: 33).accentColor(.purple).onAppear(perform: {if value.wrappedValue == 1 {isMin = true} else if value.wrappedValue >= 999 {isMax = true}})
    }
}


struct CStepperCont: View {
    
    @State var test = 1
    
    var body: some View {
        CStepper(productID: 9, value: $test, pricePerPiece: 4, isMin: (2 != 0), isMax: (6 != 0))
    }
}


#if DEBUG
struct BindingViewExample_2_Previews : PreviewProvider {
    static var previews: some View {
        CStepperCont()
    }
}
#endif
