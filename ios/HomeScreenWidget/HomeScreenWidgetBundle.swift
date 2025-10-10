//
//  HomeScreenWidgetBundle.swift
//  HomeScreenWidget
//
//  Created by bilal çavuş on 10.10.2025.
//

import WidgetKit
import SwiftUI

@main
struct HomeScreenWidgetBundle: WidgetBundle {
    var body: some Widget {
        HomeScreenWidget()
        if #available(iOS 16.1, *) {
            HomeScreenWidgetLiveActivity()
        }
    }
}
