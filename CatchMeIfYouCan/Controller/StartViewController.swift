//
//  StartViewController.swift
//  Get An Apple
//
//  Created by user226097 on 9/11/22.
//

import UIKit

class StartViewController: UIViewController {
    
 

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "goPlay", sender: self)
    }
}
