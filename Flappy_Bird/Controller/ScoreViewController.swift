//
//  ScoreViewController.swift
//  Flappy_Bird
//
//  Created by SAM on 09/05/2019.
//  Copyright © 2019 SAM. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {

    @IBOutlet var score: UILabel!
    @IBOutlet var highscore: UILabel!
    var high_score: Int = 0
    var your_score: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        print(high_score)
        print(your_score)
        highscore.text = String(high_score)
        score.text = String(your_score)


        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
