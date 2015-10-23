//
//  CurrentGameViewController.swift
//  Assassin
//
//  Created by Courtney Bohrer on 10/18/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

import UIKit

class CurrentGameViewController: UIViewController {

    @IBOutlet weak var nameOfGameLabel: UILabel!
    @IBOutlet weak var nameOfTargetLabel: UILabel!
    @IBOutlet weak var killButton: UIButton!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        let playerID:String = (PFUser.currentUser()?.objectForKey("player")?.objectId)!
        
        var query = PFQuery(className:"Player")
        query.getObjectInBackgroundWithId(playerID) {
            (player: PFObject?, error: NSError?) -> Void in
            if error == nil && player != nil {
                let target = player?.objectForKey("targetName")
                if target == nil {
                    self.nameOfTargetLabel.text = "This game has not started yet."
                    self.killButton.enabled = false
                } else {
                    self.nameOfTargetLabel.text = target as? String
                    self.killButton.enabled = true
                }
                
            } else {
                print(error)
            }
        }
        
        let gameID = (PFUser.currentUser()?.objectForKey("currentGame")?.objectId)!
        query = PFQuery(className:"Game")
        query.getObjectInBackgroundWithId(gameID!) {
            (game: PFObject?, error: NSError?) -> Void in
            if error == nil && game != nil {
                let game = game?.objectForKey("Name") as! String
                self.nameOfGameLabel.text =  game
                
            } else {
                print(error)
            }
        }
        
        //print(player)
        // let game = PFUser.currentUser()?.objectForKey("currentGame") as! Game
        // nameOfGameLabel.text = game.objectForKey("Name") as! String
        //if(game.objectForKey("activeGame") as! Bool){
        //let target = player?.objectForKey("targetName")
        //target?.fetchIfNeeded
        //if let target = player?.objectForKey("targetName") {
        // nameOfTargetLabel.text = target as? String
        //}
//        } else {
//            nameOfTargetLabel.text = "This game has not started."
//        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTouchKillButton(sender: AnyObject) {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
