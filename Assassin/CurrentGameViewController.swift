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
                self.youDied()
                print("You're dead")
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
        let playerID:String = (PFUser.currentUser()?.objectForKey("player")?.objectId)!
        let query = PFQuery(className:"Player")
        query.getObjectInBackgroundWithId(playerID) {
            (player: PFObject?, error: NSError?) -> Void in
            if error == nil && player != nil {
                let targetID = player?.objectForKey("target") as! String
                
                let query2 = PFQuery(className:"Player")
                query2.getObjectInBackgroundWithId(targetID) {
                    (target: PFObject?, error: NSError?) -> Void in
                    if error == nil && target != nil {
                        let newTargetID = target?.objectForKey("target") as! String
                        if newTargetID == player?.objectId {
                            //YOU WON
                            
                            //tell them they won
                            let alert:UIAlertView = UIAlertView()
                            alert.title = "YOU WON!!!"
                            alert.message = "Congratulations! You are the best!"
                            alert.addButtonWithTitle(":)")
                            alert.show()

                            //delete everything
                            player?.deleteInBackground()
                            
                            //get the game to delete it 
                            let gameID = (PFUser.currentUser()?.objectForKey("currentGame")?.objectId)!
                            let query3 = PFQuery(className:"Game")
                            query3.getObjectInBackgroundWithId(gameID!) {
                                (game: PFObject?, error: NSError?) -> Void in
                                if error == nil && game != nil {
                                    game?.deleteInBackground()
                                    
                                } else {
                                    print(error)
                                }
                            }
                            
                            //remove pointers to the game
                            PFUser.currentUser()?.removeObjectForKey("player")
                            PFUser.currentUser()?.removeObjectForKey("currentGame")
                            PFUser.currentUser()?.saveInBackground()
                            
                            //go back to dashboard
                            self.performSegueWithIdentifier("backToDashboard", sender: nil)
                        }
                        let newTargetName = target?.objectForKey("targetName")
                        player?.setValue(newTargetID, forKey: "target")
                        player?.setObject(newTargetName!, forKey: "targetName")
                        self.nameOfTargetLabel.text = newTargetName as! String
                        player?.saveInBackgroundWithBlock{
                            (success, error) -> Void in
                            if (success) {
                                target?.deleteInBackground()
                            } else{
                                print (error)
                            }
                            
                        }

                        
                    } else {
                        print(error)
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
        alert.message = "Sorry bout it. Better luck next time."
        alert.addButtonWithTitle(":(")
        alert.show()
        
        //remove game pointers
        PFUser.currentUser()?.removeObjectForKey("player")
        PFUser.currentUser()?.removeObjectForKey("currentGame")
        PFUser.currentUser()?.saveInBackground()
        
        //go back to dashboard
        performSegueWithIdentifier("backToDashboard", sender: nil)
        
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
