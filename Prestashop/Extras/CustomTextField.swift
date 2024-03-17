//
//  CustomTextField.swift
//  dynashop
//
//  Created by Maciej Przybylski on 22/07/2020.
//  Copyright © 2020 Maciej Przybylski. All rights reserved.
//

import SwiftUI

struct CustomTextField: View {
    var name : String
    var text : Binding<String>
    var isPassword = false
    var body: some View {
        if isPassword {
            SecureField("Password", text: text)
                .padding()
                .background(CColor.lightGray)
                .cornerRadius(15)
        } else {
            TextField(name, text: text)
                .padding()
                .background(CColor.lightGray)
                .cornerRadius(15)
        }
        
        
    }
}
