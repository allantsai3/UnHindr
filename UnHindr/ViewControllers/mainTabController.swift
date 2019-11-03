//
//  mainTabController.swift
//  UnHindr
//
//  Created by Jordan Kam on 11/2/19.
//  Copyright © 2019 Sigma. All rights reserved.
//

import Foundation
import UIKit

class mainTabController : UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        var tabFrame = self.tabBar.frame
        // - 40 is editable , the default value is 49 px, below lowers the tabbar and above increases the tab bar size
        tabFrame.size.height = 150
        tabFrame.origin.y = self.view.frame.size.height - 150
        self.tabBar.frame = tabFrame
    }
    
    
   
    }

