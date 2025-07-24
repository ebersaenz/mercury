//
//  app.swift
//  mercury
//
//  Created by Eber Saenz on 7/22/25.
//

import SwiftUI

@main
struct app: App {
    var body: some Scene {
        WindowGroup {
            MetalView().ignoresSafeArea()
        }
    }
}
