////
////  PaymentSelectionView.swift
////  Prestashop
////
////  Created by Maciej Przybylski on 14/03/2021.
////
//
//import SwiftUI
//import SwiftyJSON
//import Alamofire
//
//struct PaymentSelectionView: View {
//    var choosenAddress : AddressModel
//    var carrierID : Int
//    typealias Carrier = (id: Int, name: String, delay: String)
//    @State public var btnSelected = String()
//    @State var psMethod = ""
//    @State var carriers = [Carrier]()
//    
//    var body: some View {
//        VStack {
//            Text("Wybierz płatność")
//                .font(.title)
//                .fontWeight(.semibold)
//                .padding()
//            HStack {
//                Button(action: {
//                    self.btnSelected = "Przelew"
//                    self.psMethod = "ps_wirepayment"
//                }, label: {
//                    ChooseBlock(isSelected: btnSelected, name: "Przelew", symbolName: "arrowshape.zigzag.forward")
//                })
//                
//                Button(action: {
//                    self.btnSelected = "Czek"
//                    self.psMethod = "ps_checkpayment"
//                }, label: {
//                    ChooseBlock(isSelected: btnSelected, name: "Czek", symbolName: "signature")
//                })
//            }
//            Spacer()
//            if btnSelected != String() {
//                HStack {
//                    NavigationLink(destination: ConfirmationView(finalAddress: choosenAddress, psMethod: psMethod, idCarrier: carrierID), label: {
//                        Spacer()
//                        Text("Dalej")
//                        Image(systemName: "arrowtriangle.right.circle.fill")
//                        Spacer()
//                    }).padding().accentColor(CColor.bright).background(CColor.dark)
//                }
//            }
//        }
//    }
//    
//    func getOptions() {
//        let link = "\(globalURL)/carriers?\(apiKey)&io_format=JSON&display=full&filter[deleted]=[0]&filter[active]=[1]"
//        
//        AF.request(link, method: .get).validate().responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                
//                for (_,subJson):(String,JSON) in json["carriers"] {
//                    self.carriers.append((id: subJson["id"].intValue, name: subJson["name"].stringValue, delay: subJson["delay"].stringValue))
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
//}
//
////struct PaymentSelectionView_Previews: PreviewProvider {
////    static var previews: some View {
////        PaymentSelectionView()
////    }
////}
