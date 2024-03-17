//
//  PrestashopApp.swift
//  Prestashop
//
//  Created by Maciej Przybylski on 14/03/2021.
//

import SwiftUI
import FBSDKCoreKit

@main
struct PrestashopApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL(perform: { url in
                    ApplicationDelegate.shared.application(
                            UIApplication.shared,
                            open: url,
                            sourceApplication: nil,
                            annotation: [UIApplication.OpenURLOptionsKey.annotation]
                        )
                })
        }
    }
}
