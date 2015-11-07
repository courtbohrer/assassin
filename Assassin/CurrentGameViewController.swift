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
    var currentPlayer:PFObject?
    var playerID:String?
    var currentGame:PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        //set playerID
        playerID = (PFUser.currentUser()?.objectForKey("player")?.objectId)!
        
        //get currentPlayer
        var query = PFQuery(className:"Player")
        query.getObjectInBackgroundWithId(playerID!) {
            (player: PFObject?, error: NSError?) -> Void in
            if error == nil && player != nil {
                self.currentPlayer = player
                let target = player?.objectForKey("targetName")
                let dead = player?.objectForKey("isKilled") as! Bool
                if target == nil {
                    self.nameOfTargetLabel.text = "This game has not started yet."
                    self.killButton.enabled = false
                } else if dead {
                    self.youDied()
                }else {
                    self.nameOfTargetLabel.text = target as? String
                    self.killButton.enabled = true
                }
                
            } else {
                print("player not found")
            }
        }
        
        //get the name of the game
        let gameID = (PFUser.currentUser()?.objectForKey("currentGame")?.objectId)!
        query = PFQuery(className:"Game")
        query.getObjectInBackgroundWithId(gameID!) {
            (game: PFObject?, error: NSError?) -> Void in
            if error == nil && game != nil {
                self.currentGame = game
            } else {
                print(error)
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTouchKillButton(sender: AnyObject) {
        //get new target
        let targetID = currentPlayer?.objectForKey("target") as! String
        let query = PFQuery(className:"Player")
        query.getObjectInBackgroundWithId(targetID) {
            (target: PFObject?, error: NSError?) -> Void in
            if error == nil && target != nil {
                
                //tell the target that they have been killed
                target?.setValue(true, forKey: "isKilled")
                target?.saveInBackground()
                
                //get new target
                let newTargetID = target?.objectForKey("target") as! String
                //check if loop has circled back to self
                if newTargetID == self.currentPlayer?.objectId {
                    //if so, you won
                    
                    //tell them they won
                    let alert:UIAlertView = UIAlertView()
                    alert.title = "YOU WON!!!"
                    alert.message = "Congratulations! You are the best!"
                    alert.addButtonWithTitle(":)")
                    alert.show()
                    
                    //delete player
                    self.currentPlayer?.deleteInBackground()
                    self.removePlayer()
                    
                    //remove pointers to the game and add win
                    PFUser.currentUser()?.removeObjectForKey("player")
                    PFUser.currentUser()?.removeObjectForKey("currentGame")
                    PFUser.currentUser()?.incrementKey("numWins")
                    PFUser.currentUser()?.incrementKey("numKills")
                    PFUser.currentUser()?.saveInBackground()
                    
                    self.currentGame?.incrementKey("numPlayers", byAmount: -1)
                    
                    //go back to dashboard
                    self.performSegueWithIdentifier("backToDashboard", sender: nil)
                } else {
                    //if the new target is not yourself
                    let newTargetName = target?.objectForKey("targetName")
                    self.currentPlayer?.setValue(newTargetID, forKey: "target")
                    self.currentPlayer?.setObject(newTargetName!, forKey: "targetName")
                    self.nameOfTargetLabel.text = newTargetName as! String
                    self.currentPlayer?.saveInBackgroundWithBlock{
                        (success, error) -> Void in
                        if (success) {
                            
                        } else{
                            print (error)
                        }
                        
                    }
                }
            } else {
                print(error)
            }
        }
    }
    
    func youDied(){
        //tell them they died
        let alert:UIAlertView = UIAlertView()
        alert.title = "You're dead."
        alert.message = "Sorry 'bout it. Better luck next time."
        alert.addButtonWithTitle(":(")
        alert.show()
        
        //remove game pointers
        PFUser.currentUser()?.removeObjectForKey("player")
        PFUser.currentUser()?.removeObjectForKey("currentGame")
        PFUser.currentUser()?.saveInBackground()
        
        //delete player object 
        currentPlayer?.deleteInBackground()
        
        //go back to dashboard
        performSegueWithIdentifier("backToDashboard", sender: nil)
        
        //check if the game is over and needs to be deleted
        let numPlayers = currentGame?.valueForKey("numPlayers") as! NSNumber
        var numPlayersInt = numPlayers.integerValue
        numPlayersInt--
        if numPlayersInt == 0 {
            self.currentGame?.deleteInBackground()
        } else {
            self.currentGame?.setValue(numPlayersInt, forKey: "numPlayers")
            self.currentGame?.saveInBackground()
        }
        
//        currentGame?.incrementKey("numPlayers", byAmount: -1)
//        if (currentGame?.valueForKey("numPlayers")?.isEqual(0) == true){
//            
//        }
        currentGame?.saveInBackground()
        //removePlayer()
    }
    
    func removePlayer(){
//        //get game to delete from active players
//        let gameID = (PFUser.currentUser()?.objectForKey("currentGame")?.objectId)!
//        let query = PFQuery(className:"Game")
//        query.getObjectInBackgroundWithId(gameID!) {
//            (game: PFObject?, error: NSError?) -> Void in
//            if error == nil && game != nil {
//        var activePlayers = currentGame?.objectForKey("activePlayers") as! [PFObject]
//        activePlayers.removeFirst()
//        if activePlayers.count == 0 {
//            //they were the last player in the game
//            currentGame?.deleteInBackground()
//        } else {
//            currentGame?.saveInBackground()
//        }
//                for p in activePlayers {
//                    if(p.objectId == self.playerID){
//                        activePlayers.removeFirst()
//                        if activePlayers.count == 0 {
//                            //they were the last player in the game
//                            currentGame?.deleteInBackground();
//                        }
//                    }
//                }
        
//            } else {
//                print(error)
//            }
//        }

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
