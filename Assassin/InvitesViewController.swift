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
    private var reuseIdentifier = "invitesCell"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.invitesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.invitesTableView.delegate = self
        self.invitesTableView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let myFBID:String = PFUser.currentUser()?.objectForKey("FacebookID") as! String
        let query = PFQuery(className:"Game")
        
        query.whereKey("invitedPlayers", containsAllObjectsInArray:[myFBID])
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                // The find succeeded.
                self.invitedGames = objects!
                self.invitesTableView.reloadData()
                
            } else {
                print("query error")
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
        //get game
        let index:Int = indexPath.row
        let game = self.invitedGames[index]
       
        //create player object
        let player = PFUser.currentUser()
        let playerID = player!.objectForKey("FacebookID")!
        let playerObject = Player(playerID: playerID as! String, targetID: "")
        playerObject.setValue(playerID, forKey: "FacebookID")
        playerObject.setValue(player?.objectForKey("Name"), forKey: "Name")
        playerObject.setValue(false, forKey: "isKilled");
        playerObject.saveInBackground() // should probably do this in block
        
        //add player object
        game.objectForKey("activePlayers")?.addObject(playerObject)
        game.incrementKey("numPlayers")
        
        //add invited players
        game.objectForKey("invitedPlayers")?.removeObject(playerID)
        
        //save game
        game.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if (success) {
                PFUser.currentUser()?.setObject(game, forKey: "currentGame")
                PFUser.currentUser()?.setObject(playerObject, forKey: "player")
                PFUser.currentUser()?.saveInBackground()
                //if this is the last player to RSVP, start the game
                if game.objectForKey("invitedPlayers")?.count == 0 {
                    self.assignTargets(game)
                    game.setValue(true, forKey: "activeGame")
                    
                    game.saveInBackgroundWithBlock {
                        (success, error) -> Void in
                        if (success) {
                            self.performSegueWithIdentifier("showNewGame", sender: nil)
                        }
                        else {
                            print("error saving target")
                        }
                    }
                }
            } else {
                print("error saving game")
            }
        }
        
        //notify player that game was created
        let alert:UIAlertView = UIAlertView()
        alert.title = "You have been added to the game!"
        alert.addButtonWithTitle("Okay!")
        alert.show()
    }
    
    func assignTargets(game:PFObject){
        // need to finish implementing
        var newActive:[PFObject] = []
        var oldActive:[PFObject] = game.objectForKey("activePlayers") as! [PFObject]
        var size = oldActive.count
        while (size > 0){
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
        
        print("Assigning targets")
        
//        var active:[Player] = game.objectForKey("activePlayers") as! [Player]
//
//        var lastPlayer:Player = active[0]
//        active.removeAtIndex(0);
//        var nextPlayer: Player;
//        
//        while active.isEmpty == false {
//            let rand:Int = Int(arc4random_uniform(UInt32(active.count - 1)))
//            nextPlayer = active[rand]
//            nextPlayer.targetID = lastPlayer.playerID
//            nextPlayer.saveInBackground()
//            active.removeAtIndex(rand)
//            lastPlayer = nextPlayer
//        }
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
