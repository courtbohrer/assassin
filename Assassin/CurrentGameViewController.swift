//
//  CurrentGameViewController.swift
//  Assassin
//
//  Created by Courtney Bohrer on 10/18/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

import UIKit
import MobileCoreServices
import ParseFacebookUtilsV4

class CurrentGameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ConfirmKillViewControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var nameOfGameLabel: UILabel!
    @IBOutlet weak var nameOfTargetLabel: UILabel!
    @IBOutlet weak var lblKillMethod: UILabel!
    @IBOutlet weak var killButton: UIButton!
    @IBOutlet weak var playerTable: UITableView!
    
    var currentPlayer:PFObject?
    var playerID:String?
    var currentGame:PFObject?
    var currentGameKillMethod:String?
    var newMedia:Bool?
    var justKilled: Bool?
    var killPhoto: UIImage?
    var justWon: Bool?
    var activePlayerObjects = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        self.playerTable.backgroundColor = UIColor(red:1.00, green:0.19, blue:0.19, alpha: 1.0)

        nameOfGameLabel.text = ""
        nameOfTargetLabel.text = ""
        lblKillMethod.text = ""
        justKilled = false
        justWon = false
        newMedia = false
        self.playerTable.delegate = self
        self.playerTable.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        if justKilled == true {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("ConfirmKillViewController") as! ConfirmKillViewController
            vc.killPhoto = killPhoto
            vc.currentPlayer = currentPlayer
            vc.currentGame = currentGame
            vc.delegate = self
            vc.modalPresentationStyle = UIModalPresentationStyle.Popover
            presentViewController(vc, animated: true, completion:nil)
            justKilled = false
        }
        if justWon == true {
            let alert:UIAlertView = UIAlertView()
            alert.title = "YOU WON!!!"
            alert.message = "Congratulations! You are the best!"
            alert.addButtonWithTitle("Sweet thanks.")
            alert.show()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if justWon == true {
            performSegueWithIdentifier("backToDashboard", sender: nil)
        } else {
            // Set game info
            let gameID = (PFUser.currentUser()!.objectForKey("currentGame")?.objectId)! as String
            var query = PFQuery(className:"Game")
            query.getObjectInBackgroundWithId(gameID) {
                (game: PFObject?, error: NSError?) -> Void in
                if error == nil && game != nil {
                    self.currentGame = game
                    let activePlayers = game!.objectForKey("activePlayers") as! [PFObject]
                    self.activePlayerObjects = []
                    for player in activePlayers {
                        let playerObjectID = player.valueForKey("objectId") as! String
                        let query = PFQuery(className:"Player")
                        query.getObjectInBackgroundWithId(playerObjectID) {
                            (player: PFObject?, error: NSError?) -> Void in
                            if error == nil && player != nil {
                                self.activePlayerObjects.append(player!)
                            } else {
                                print("Error: \(error!) \(error!.userInfo)")
                            }
                            self.playerTable.reloadData()
                        }
                    }
                    let currentGameName = self.currentGame!.objectForKey("Name") as? String
                    self.nameOfGameLabel.text = currentGameName
                    self.currentGameKillMethod = game?.objectForKey("killMethod") as? String
                    self.lblKillMethod.text = self.currentGameKillMethod!
                    if self.currentGame?.objectForKey("invitedPlayers")?.count == 0 && self.currentGame!.objectForKey("activePlayers")?.count == 1 {
                        PFUser.currentUser()!.removeObjectForKey("player")
                        PFUser.currentUser()!.removeObjectForKey("currentGame")
                        PFUser.currentUser()!.saveInBackgroundWithBlock {
                            (success, error) -> Void in
                            if (success) {
                                self.performSegueWithIdentifier("backToDashboard", sender: nil)
                                let alertView = UIAlertController(title: "No opponents", message: "Every one else declined their invites. Try starting a new game!", preferredStyle: .Alert)
                                alertView.addAction(UIAlertAction(title: "Okay!", style: .Default, handler: nil))
                                self.presentViewController(alertView, animated: true, completion: nil)
                            } else {
                                print(error)
                            }
                        }
                    }
                } else {
                    print("Game not found: \(error)")
                }
            }
            // Set player info
            self.playerID = (PFUser.currentUser()!.objectForKey("player")?.objectId)!
            query = PFQuery(className:"Player")
            query.getObjectInBackgroundWithId(self.playerID!) {
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
                        self.killButton.enabled = true
                    }
                } else {
                    print("Player not found: \(error)")
                }
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        justWon = false;
        justKilled = false;
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
                justKilled = true
                killPhoto = image
            }
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
    
    //to conform to ConfirmKillViewControllerDelegate protocol
    func setJustWon(){
        justWon = true
    }
    
    //table methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activePlayerObjects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PlayerTableViewCell", forIndexPath: indexPath) as! PlayerTableViewCell
        let player = activePlayerObjects[indexPath.row]
        
        //set name
        cell.nameLabel!.text = player.objectForKey("Name")! as? String
        cell.textLabel!.font = UIFont(name: "AvenirNext-Bold", size: 16)
        //set status
        if player.valueForKey("isKilled") as? Bool == true {
            cell.statusLabel.text = "Terminated"
            let killPhoto = player.objectForKey("killPhoto")
            killPhoto!.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if let data = data where error == nil{
                    cell.playerImage.image = UIImage(data: data)
                }
            })
        } else if player.objectForKey("target") == nil {
            cell.statusLabel.text = "Pending"
            //set picture
            if let file:PFFile = player.objectForKey("profPicData") as! PFFile{
                file.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                    
                    if let imageData = imageData where error == nil{
                        cell.playerImage.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            cell.statusLabel.text = "Active"
            //set picture
            if let file:PFFile = player.objectForKey("profPicData") as! PFFile{
                file.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                    
                    if let imageData = imageData where error == nil{
                        cell.playerImage.image = UIImage(data: imageData)
                    }
                }
            }
        }
        
        return cell
    }

    
    
}