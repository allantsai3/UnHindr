//
//  menu.swift
//  UnHindr
//
//  Created by jjpuffer on 10/31/19.
//  Copyright © 2019 Sigma. All rights reserved.
//

import Foundation
import UIKit

class HomeMenu : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func goToMed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MedicationHome") as UIViewController
        present(vc, animated: true, completion: nil)
    }
    
}
