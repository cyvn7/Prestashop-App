//
//  ProductPageView.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 22/05/2022.
//

import SwiftUI

struct ProductPageView: View {
    @State var pcs = 1
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                    //MARK: Title box
                    VStack(alignment: .leading) {
                        Text("Adidas Running")
                            .font(.footnote)
                        Text("Adidas Running Black"
                        ).font(.system(size: 30))
                            .fontWeight(.bold)
                        Text("64zł")
                            .font(.title2)
                    }
                    .padding(.horizontal, 10)
                    //MARK: Add to card and favourite buttons box
                    HStack {
                        Button(action: {
                            print("BUTTON: Add to card clicked")
                        }, label: {
                            ZStack(alignment: .leading){
                                CColor.purpleGradient
                                Text("Do koszyka")
                                    .fontWeight(.bold)
                                    .padding()
                            }
                        })
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 10)
                        Button(action: {
                            print("BUTTON: Favourite clicked")
                        }, label: {
                            Image(systemName: "heart")
                        })
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1))
                        .padding(.trailing, 10)
                        
                        
                    }
                    .padding(.horizontal, 10)
                    //MARK: Quick description
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.")
                        .font(.footnote)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    //MARK: Quantity and color buttons box
                    HStack {
                        VStack {
                                    Picker("Select a paint color", selection: $pcs) {
                                        ForEach(1...10, id: \.self) { index in
                                            Text("\(index)")
                                        }
                                    }
                                    .pickerStyle(.menu)

                                    Text("Selected color: \(pcs)")
                                }
                        Menu {
                            ForEach([1,2,3,4,5,6,7,8,9,10], id: \.self) { quantity in
                                Button(action: {
                                    pcs = quantity
                                    print(quantity)
                                    
                                }, label: {
                                    Text("\(quantity)")
                                    Spacer()
                                    if pcs == quantity {
                                        Image(systemName: "checkmark")
                                    }
                                })
                            }
                        } label: {
                            HStack {
                                Text("Quantity: \(pcs)")
                                    .fontWeight(.semibold)
                                    .padding()
                                Image(systemName: "chevron.down")
                                Spacer()
                            }
                        }
                        .frame(height: 50)
                        .foregroundColor(.gray)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1))
                        .padding([.top, .leading, .bottom], 10.0)
                        
                        Button(action: {
                            print("BUTTON: Favourite clicked")
                        }, label: {
                            Text("Color")
                                .fontWeight(.semibold)
                                .padding()
                            Spacer()
                            Circle()
                                .fill(.blue)
                                .frame(width: 30, height: 30)
                                .padding(10)
                        })
                        .frame(height: 50)
                        .foregroundColor(.gray)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1))
                        .padding(10)
                    }
                    .padding(.horizontal, 4)
                    //MARK: More desc
                    Text("Morbi eget lacus vestibulum, ullamcorper eros sagittis, elementum est. Nam tristique nec nunc eu congue. Donec pharetra orci quis tortor semper, vitae venenatis nulla rutrum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla luctus lorem vitae lacus convallis vehicula. In ac velit vehicula, iaculis urna vel, sodales urna. Cras accumsan eu magna ac sodales. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Integer auctor cursus nunc eget laoreet. Aenean mattis fermentum rutrum. Donec at commodo felis. Nunc id libero a elit tristique rhoncus eu ut quam. Pellentesque gravida cursus massa, quis cursus ex varius quis. Praesent velit mi, hendrerit in urna a, imperdiet viverra ipsum. Cras lacinia molestie ex, eget malesuada libero laoreet a. Nam fermentum, ligula vitae maximus porttitor, sem erat pretium dui, sit amet pulvinar neque nulla vitae erat. Donec posuere efficitur nunc at laoreet. Pellentesque vel volutpat orci. Nullam quis risus justo. Nullam consectetur nulla non scelerisque imperdiet. Nulla dui velit, ornare sed nunc tincidunt, laoreet ultrices nulla. Maecenas ut feugiat magna. Nunc mauris nulla, ullamcorper vitae ante nec, blandit varius nunc.  Nunc rutrum lacus dolor, vitae mollis augue convallis iaculis. Pellentesque in luctus nibh, sit amet mollis ipsum. Fusce sit amet metus malesuada urna ultricies gravida et sed arcu. Vestibulum sed mauris quis sapien facilisis lobortis facilisis sit amet augue. Nunc feugiat a lacus laoreet faucibus. Duis tincidunt diam justo, sit amet dapibus nunc feugiat sed. Aenean ultrices magna congue nisl facilisis, quis suscipit metus dignissim. Proin quis nibh eget erat vestibulum facilisis non quis diam. Pellentesque libero lorem, pellentesque sit amet lorem eget, tempor finibus justo.")
                        .padding()
                    
                    
                
            }
        }
    }
}

struct ProductPageView_Previews: PreviewProvider {
    static var previews: some View {
        ProductPageView()
    }
}

