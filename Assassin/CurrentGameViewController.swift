//
//  CurrentGameViewController.swift
//  Assassin
//
//  Created by Courtney Bohrer on 10/18/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

import UIKit
import MobileCoreServices

class CurrentGameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameOfGameLabel: UILabel!
    @IBOutlet weak var nameOfTargetLabel: UILabel!
    @IBOutlet weak var lblKillMethod: UILabel!
    @IBOutlet weak var killButton: UIButton!
    
    var currentPlayer:PFObject?
    var playerID:String?
    var currentGame:PFObject?
    var currentGameKillMethod:String?
    var newMedia:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPlayer = PFUser.currentUser()
        nameOfGameLabel.text = ""
        nameOfTargetLabel.text = ""
        lblKillMethod.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Set game info
        let gameID = (currentPlayer?.objectForKey("currentGame")?.objectId)! as String
        var query = PFQuery(className:"Game")
        query.getObjectInBackgroundWithId(gameID) {
            (game: PFObject?, error: NSError?) -> Void in
            if error == nil && game != nil {
                self.currentGame = game
                let currentGameName = self.currentGame!.objectForKey("Name") as? String
                self.nameOfGameLabel.text = currentGameName
                self.currentGameKillMethod = game?.objectForKey("killMethod") as? String
            } else {
                print("Game not found: \(error)")
            }
        }
        // Set player info
        playerID = (currentPlayer?.objectForKey("player")?.objectId)!
        query = PFQuery(className:"Player")
        query.getObjectInBackgroundWithId(playerID!) {
            (player: PFObject?, error: NSError?) -> Void in
            if error == nil && player != nil {
                self.currentPlayer = player
                let target = player?.objectForKey("targetName")
                let dead = player?.objectForKey("isKilled") as! Bool
                if target == nil {
                    self.nameOfTargetLabel.text = "This game has not started yet."
                    self.lblKillMethod.text = "<Randomizing kill methods...>"
                    self.killButton.enabled = false
                } else if dead {
                    self.youDied()
                } else {
                    self.nameOfTargetLabel.text = target as? String
                    self.lblKillMethod.text = "Kill Method: " + self.currentGameKillMethod!
                    self.killButton.enabled = true
                }
            } else {
                print("Player not found: \(error)")
            }
        }
    }
    
    @IBAction func didTouchKillButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.mediaTypes = [kUTTypeImage as NSString as String]
            imagePicker.allowsEditing = false
            imagePicker.showsCameraControls = true
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
            newMedia = true
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType == kUTTypeImage as String {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            // Save the image we just created.
            if (newMedia == true) {
                // The third argument is the 'completion method selector' - a function that is called when the save
                // operation is done. The method name has an objective-c signature.
                UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
                
                //let imageData = UIImagePNGRepresentation(image)
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                let imageFile = PFFile(name:"image.jpeg", data:imageData!)
                performKill(imageFile!)
            }
        }
        
    }
    
    func performKill(imageFile: PFFile) {
        // Get target
        let targetID = currentPlayer?.objectForKey("target") as! String
        let query = PFQuery(className:"Player")
        query.getObjectInBackgroundWithId(targetID) {
            (target: PFObject?, error: NSError?) -> Void in
            if error == nil && target != nil {
                
                // Tell the target that they have been killed
                target?.setValue(true, forKey: "isKilled")
                target?.setObject(imageFile, forKey: "killPhoto")
                target?.saveInBackground()
                
                // Get new target
                let newTargetID = target?.objectForKey("target") as! String
                
                // Check if loop has circled back to self
                if newTargetID == self.currentPlayer?.objectId {
                    
                    // If so, you won
                    let alertView = UIAlertController(title: "YOU WON!!!", message: "Congratulations! You are the best!", preferredStyle: .Alert)
                    alertView.addAction(UIAlertAction(title: ":)", style: .Default, handler: nil))
                    self.presentViewController(alertView, animated: true, completion: nil)
                    
                    //delete player
                    //self.currentPlayer?.deleteInBackground()
                    
                    // Remove pointers to the game and add win
                    PFUser.currentUser()?.removeObjectForKey("player")
                    PFUser.currentUser()?.removeObjectForKey("currentGame")
                    PFUser.currentUser()?.incrementKey("numWins")
                    PFUser.currentUser()?.incrementKey("numKills")
                    PFUser.currentUser()?.saveInBackground()
                    
                    self.currentGame?.incrementKey("numPlayers", byAmount: -1)
                    self.currentGame?.saveInBackground()
                    
                    // Go back to dashboard
                    self.performSegueWithIdentifier("backToDashboard", sender: nil)
                    
                } else {
                    // If the new target is not yourself
                    let newTargetName = target?.objectForKey("targetName")
                    self.currentPlayer?.setValue(newTargetID, forKey: "target")
                    self.currentPlayer?.setObject(newTargetName!, forKey: "targetName")
                    self.nameOfTargetLabel.text = newTargetName as? String
                    self.currentPlayer?.saveInBackgroundWithBlock{
                        (success, error) -> Void in
                        if (success) {
                        } else {
                            print (error)
                        }
                    }
                }
            } else {
                print(error)
            }
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        if error != nil {
            let alert = UIAlertController(title: "Save Failed", message: "Failed to save image", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Image Saved", message: "Image Saved", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func youDied() {
        
        //tell them they died
        let alertView = UIAlertController(title: "You're dead.", message: "Sorry 'bout it. Better luck next time.", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: ":(", style: .Default, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
        
        //remove game pointers
        PFUser.currentUser()?.removeObjectForKey("player")
        PFUser.currentUser()?.removeObjectForKey("currentGame")
        PFUser.currentUser()?.saveInBackground()
        
        //**CHANGE** No longer deleting here. Waiting to delete player objects until end of game now.
        //delete player object
        //currentPlayer?.deleteInBackground()
        
        //check if the game is over and needs to be deleted
        self.currentGame?.incrementKey("numPlayers", byAmount: -1)
        self.currentGame?.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if (success) {
                let numPlayers = self.currentGame?.valueForKey("numPlayers") as! NSNumber
                if numPlayers.integerValue == 0 {
                    //game is over, delete objects
                    
                    //delete all player objects
                    let players = self.currentGame!.objectForKey("activePlayers") as! [PFObject]
                    for player in players {
                        player.deleteInBackground()
                    }
                    
                    //delete game
                    self.currentGame?.deleteInBackground()
                }
            } else {
                print(error)
            }
        }
        
        //go back to dashboard
        performSegueWithIdentifier("backToDashboard", sender: nil)
    }
}