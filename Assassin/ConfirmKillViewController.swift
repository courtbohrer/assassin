//
//  ConfirmKillViewController.swift
//  Assassin
//
//  Created by Courtney Bohrer on 11/19/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

import UIKit

protocol ConfirmKillViewControllerDelegate{
    func setJustWon()
}

class ConfirmKillViewController: UIViewController {
    

    @IBOutlet weak var killImageView: UIImageView!
    var killPhoto: UIImage?
    var currentPlayer:PFObject?
    var currentGame:PFObject?
    var delegate: ConfirmKillViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        killImageView.image = killPhoto
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTouchConfirmKill(sender: AnyObject) {
        //convert image to PFFile
        let imageData = UIImageJPEGRepresentation(killPhoto!, 0.5)
        let imageFile = PFFile(name:"image.jpeg", data:imageData!)

        //pass to perform kill
        performKill(imageFile!)
        print("awepfiojwaefj")
    }

    
    @IBAction func didTouchDenyKill(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func performKill(imageFile: PFFile){
        //get target
        let targetID = currentPlayer?.objectForKey("target") as! String
        let query = PFQuery(className:"Player")
        query.getObjectInBackgroundWithId(targetID) {
            (target: PFObject?, error: NSError?) -> Void in
            if error == nil && target != nil {
                
                //tell the target that they have been killed
                target?.setValue(true, forKey: "isKilled")
                target?.setObject(imageFile, forKey: "killPhoto")
                target?.saveInBackground()
                
                //get new target
                let newTargetID = target?.objectForKey("target") as! String
                //check if loop has circled back to self
                if newTargetID == self.currentPlayer?.objectId {
                    //if so, you won
                    
                    //remove pointers to the game and add win
                    PFUser.currentUser()?.removeObjectForKey("player")
                    PFUser.currentUser()?.removeObjectForKey("currentGame")
                    PFUser.currentUser()?.incrementKey("numWins")
                    PFUser.currentUser()?.incrementKey("numKills")
                    PFUser.currentUser()?.saveInBackground()
                    
                    self.currentGame?.incrementKey("numPlayers", byAmount: -1)
                    self.currentGame?.saveInBackground()
                    
                    self.delegate?.setJustWon()
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    
                    //if the new target is not yourself
                    let newTargetName = target?.objectForKey("targetName")
                    self.currentPlayer?.setValue(newTargetID, forKey: "target")
                    self.currentPlayer?.setObject(newTargetName!, forKey: "targetName")
                    self.currentPlayer?.saveInBackgroundWithBlock{
                        (success, error) -> Void in
                        if (success) {
                            self.dismissViewControllerAnimated(true, completion: nil)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
