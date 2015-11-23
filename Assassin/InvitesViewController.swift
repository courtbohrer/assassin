//
//  InvitesViewController.swift
//  Assassin
//
//  Created by Courtney Bohrer on 10/18/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

import UIKit

class InvitesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var invitesTableView: UITableView!
    var invitedGames:[PFObject] = []
    var reuseIdentifier = "invitesCell"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.invitesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.invitesTableView.delegate = self
        self.invitesTableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let myFBID = PFUser.currentUser()?.objectForKey("FacebookID") as! String
        let query = PFQuery(className:"Game")
        
        query.whereKey("invitedPlayers", containsAllObjectsInArray:[myFBID])
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil && objects != nil {
                self.invitedGames = objects!
                self.invitesTableView.reloadData()
            } else {
                print("Query error: \(error)")
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.invitedGames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        let game = self.invitedGames[indexPath.row]
        
        cell.textLabel!.text = game.objectForKey("Name")! as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // New code
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("InvitedGameDetailViewController") as! InvitedGameDetailViewController
        
        let index:Int = indexPath.row
        let game = self.invitedGames[index]
        let gameID = game.objectId
        
        viewController.gameID = gameID!
        
        viewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        presentViewController(viewController, animated: true, completion:nil)

        // End new code
        
//        // get player
//        let player = PFUser.currentUser()
//        let playersCurrentGame = player?.objectForKey("currentGame")
//        
//        // check if player is currently in a game
//        // if not, enter them into the new game
//        if playersCurrentGame == nil {
//            
//            //get game
//            let index:Int = indexPath.row
//            let game = self.invitedGames[index]
//            
//            // create new player object
//            let playerID = player!.objectForKey("FacebookID")!
//            let playerObject = Player(playerID: playerID as! String, targetID: "")
//            
//            // set values
//            playerObject.setValue(playerID, forKey: "FacebookID")
//            playerObject.setValue(player?.objectForKey("Name"), forKey: "Name")
//            playerObject.setValue(false, forKey: "isKilled");
//            playerObject.saveInBackground()
//            
//            // add player object
//            game.objectForKey("activePlayers")?.addObject(playerObject)
//            game.incrementKey("numPlayers")
//            
//            // add invited players
//            game.objectForKey("invitedPlayers")?.removeObject(playerID)
//            
//            // save game
//            game.saveInBackgroundWithBlock {
//                (success, error) -> Void in
//                if (success) {
//                    PFUser.currentUser()?.setObject(game, forKey: "currentGame")
//                    PFUser.currentUser()?.setObject(playerObject, forKey: "player")
//                    PFUser.currentUser()?.saveInBackground()
//                    
//                    // if this is the last player to RSVP, start the game
//                    if game.objectForKey("invitedPlayers")?.count == 0 {
//                        self.assignTargets(game)
//                        game.setValue(true, forKey: "activeGame")
//                        game.saveInBackgroundWithBlock {
//                            (success, error) -> Void in
//                            if (success) {
//                                self.performSegueWithIdentifier("showNewGame", sender: nil)
//                            }
//                            else {
//                                print("error saving target")
//                            }
//                        }
//                    }
//                } else {
//                    print("error saving game")
//                }
//            }
//            
//            // Notify player that game was created
//            let alertView = UIAlertController(title: "You have been added to the game!", message: "", preferredStyle: .Alert)
//            alertView.addAction(UIAlertAction(title: "Okay!", style: .Default, handler: nil))
//            self.presentViewController(alertView, animated: true, completion: nil)
//           
//        // Else notify the player she/he can only be in one game!
//        } else {
//            let alertView = UIAlertController(title: "You're currently already in a game! Finish that one first!", message: "", preferredStyle: .Alert)
//            alertView.addAction(UIAlertAction(title: "Okay!", style: .Default, handler: nil))
//            self.presentViewController(alertView, animated: true, completion: nil)
//        }
    }
    
    func assignTargets(game:PFObject) {
        var newActive:[PFObject] = []
        var oldActive:[PFObject] = game.objectForKey("activePlayers") as! [PFObject]
        var size = oldActive.count
        while size > 0 {
            let rand:Int = Int(arc4random_uniform(UInt32(size - 1)))
            newActive.append(oldActive[rand])
            oldActive.removeAtIndex(rand)
            size--
        }
        size = newActive.count
        for i in 0...size - 2 {
            let target = newActive[i+1];
            newActive[i].setValue(target.objectId, forKey: "target")
            newActive[i].saveInBackground()
            let query = PFQuery(className:"Player")
            query.getObjectInBackgroundWithId(target.objectId!) {
                (player: PFObject?, error: NSError?) -> Void in
                if error == nil && player != nil {
                    newActive[i].setValue(player?.objectForKey("Name"), forKey: "targetName")
                    newActive[i].saveInBackground()
                } else {
                    print(error)
                }
            }
        }
        newActive[size - 1].setValue(newActive[0].objectId, forKey: "target")
        newActive[size - 1].saveInBackground()
        let query = PFQuery(className:"Player")
        query.getObjectInBackgroundWithId(newActive[0].objectId!) {
            (player: PFObject?, error: NSError?) -> Void in
            if error == nil && player != nil {
                newActive[size - 1].setValue(player?.objectForKey("Name"), forKey: "targetName")
                newActive[size - 1].saveInBackground()
            } else {
                print(error)
            }
        }
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}