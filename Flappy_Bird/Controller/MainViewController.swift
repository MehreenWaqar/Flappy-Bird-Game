//
//  MainViewController.swift
//  Flappy_Bird
//
//  Created by SAM on 10/05/2019.
//  Copyright © 2019 SAM. All rights reserved.
//

import UIKit
import SpriteKit

class MainViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
   
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "easy" {
            let controller = segue.destination as! GameViewController
            controller.level = "easy"
    }
        if segue.identifier == "medium" {
            let controller = segue.destination as! GameViewController
            controller.level = "medium"
        }
        if segue.identifier == "hard" {
            let controller = segue.destination as! GameViewController
            controller.level = "hard"
        }
    }

}
