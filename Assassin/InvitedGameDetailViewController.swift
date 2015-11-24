//
//  InvitedGameDetailViewController.swift
//  Assassin
//
//  Created by Quan Vo on 11/21/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

protocol InviteDetailDelegate {
    func goToNewGame()
}


class InvitedGameDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var gameID = ""
    var game:PFObject?
    var invitedPlayers = [String]()
    let reuseIdentifier = "OtherInvitedPlayersCell"
    var delegate:InviteDetailDelegate?
    
    @IBOutlet weak var labelInvitedGameName: UILabel!
    @IBOutlet weak var labelWhoInvitedYou: UILabel!
    @IBOutlet weak var tableViewTheOtherInvitedPlayers: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewTheOtherInvitedPlayers.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableViewTheOtherInvitedPlayers.delegate = self
        tableViewTheOtherInvitedPlayers.dataSource = self
        
        let query = PFQuery(className:"Game")
        query.getObjectInBackgroundWithId(gameID) {
            (game: PFObject?, error: NSError?) -> Void in
            if error == nil && game != nil {
                self.game = game!
                
                let gameName = self.game!.objectForKey("Name") as! String
                let gameHost = self.game!.objectForKey("Host") as! String
                self.labelInvitedGameName.text = gameName
                self.labelWhoInvitedYou.text = gameHost + " invited you!"
                
                let activePlayers = game!.objectForKey("activePlayers") as! [PFObject]
                for player in activePlayers {
                    let playerObjectID = player.valueForKey("objectId") as! String
                    
                    let query = PFQuery(className:"Player")
                    query.getObjectInBackgroundWithId(playerObjectID) {
                        (player: PFObject?, error: NSError?) -> Void in
                        if error == nil && player != nil {
                            let invitedPlayerName = player!.valueForKey("Name") as! String
                            self.invitedPlayers.append(invitedPlayerName)
                        } else {
                            print("Error: \(error!) \(error!.userInfo)")
                        }
                        self.tableViewTheOtherInvitedPlayers.reloadData()
                    }
                }
                
                let invitedPlayersIDs = game?.objectForKey("invitedPlayers") as! [String]
                for invitedPlayerID in invitedPlayersIDs {
                    let query = PFUser.query()
                    query!.whereKey("FacebookID", equalTo:invitedPlayerID)
                    query!.findObjectsInBackgroundWithBlock {
                        (objects: [PFObject]?, error: NSError?) -> Void in
                        if error == nil && objects != nil {
                            for object in objects! {
                                let invitedPlayerName = object.valueForKey("Name") as! String
                                self.invitedPlayers.append(invitedPlayerName)
                            }
                        } else {
                            print("Error: \(error!) \(error!.userInfo)")
                        }
                        self.tableViewTheOtherInvitedPlayers.reloadData()
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitedPlayers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        let index = indexPath.row
        
        cell.textLabel?.text = invitedPlayers[index]
        
        return cell
    }
    
    @IBAction func touchAcceptButton(sender: AnyObject) {
        // Get player
        let player = PFUser.currentUser()
        let playersCurrentGame = player?.objectForKey("currentGame")
        
        // Check if player is currently in a game
        if playersCurrentGame != nil {
            let alertView = UIAlertController(title: "You're currently already in a game! Finish that one first!", message: "", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "Okay!", style: .Default, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        } else {
            // Create new player object
            let playerID = player!.objectForKey("FacebookID")!
            let playerObject = Player(playerID: playerID as! String, targetID: "")
            
            // Set values
            playerObject.setValue(playerID, forKey: "FacebookID")
            playerObject.setValue(player?.objectForKey("Name"), forKey: "Name")
            playerObject.setValue(false, forKey: "isKilled");
            playerObject.saveInBackground()
            
            // Add player object
            game!.objectForKey("activePlayers")?.addObject(playerObject)
            game!.incrementKey("numPlayers")
            
            // Remove player from the game's invitedPlayers list
            game!.objectForKey("invitedPlayers")?.removeObject(playerID)
            
            // Save game
            game!.saveInBackgroundWithBlock {
                (success, error) -> Void in
                if (success) {
                    // Set player and game pointers for user
                    player!.setObject(self.game!, forKey: "currentGame")
                    player!.setObject(playerObject, forKey: "player")
                    player!.saveInBackground()
                    
                    // If this is the last player to RSVP, start the game
                    if self.game!.objectForKey("invitedPlayers")?.count == 0 {
                        self.assignTargets(self.game!)
                        self.game!.setValue(true, forKey: "activeGame")
                        self.game!.saveInBackgroundWithBlock {
                            (success, error) -> Void in
                            if (success) {
                                self.delegate?.goToNewGame()
                                self.dismissViewControllerAnimated(true, completion: nil)
                            } else {
                                print("Error saving game: \(error)")
                            }
                        }
                    }
                } else {
                    print("Error saving game: \(error)")
                }
            }
        }
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
    
    @IBAction func touchDeclineButton(sender: AnyObject) {
        let player = PFUser.currentUser()
        let playerID = player!.objectForKey("FacebookID")!
        game!.objectForKey("invitedPlayers")?.removeObject(playerID)
        game!.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if (success) {
                if self.game!.objectForKey("invitedPlayers")?.count == 0 && self.game!.objectForKey("activePlayers")?.count > 1 {
                        self.assignTargets(self.game!)
                        self.game!.setValue(true, forKey: "activeGame")
                        self.game!.saveInBackground()
                }
            } else {
                print("Error saving game: \(error)")
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        let alertView = UIAlertController(title: "You've declined the game", message: "", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    @IBAction func touchCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}