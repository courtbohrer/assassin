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
        playerObject.saveInBackground()
        
        //add player object
        game.objectForKey("activePlayers")?.addObject(playerObject)
        
        //add invited players
        game.objectForKey("invitedPlayers")?.removeObject(playerID)
        if game.objectForKey("invitedPlayers")?.count == 0 {
            assignTargets(game)
        }
        
        //save game
        game.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if (success) {
                self.assignTargets(game)
            } else {
                print("error saving game")
            }
        }
        
        //notify player that game was created
        let alert:UIAlertView = UIAlertView()
        alert.title = "You have been added to the game!"
        alert.addButtonWithTitle("Okay!")
        alert.show()
        
        //got to game screen
        self.performSegueWithIdentifier("showNewGame", sender: nil)
        
    }
    
    func assignTargets(game:PFObject){
        // need to finish implementing
        var newActive:[Player] = []
        var oldActive:[Player] = game.objectForKey("activePlayers") as! [Player]
        var size = oldActive.count
        while (size > 0){
            let rand:Int = Int(arc4random_uniform(UInt32(size - 1)))
            //newActive.append(oldActive[rand])
            //oldActive.removeAtIndex(rand)
            //size--
        }
        
        size = newActive.count
        for i in 0...size - 2 {
            //let target = newActive[i+1];
            //newActive[i].setValue(target.playerID, forKey: "target")
            //newActive[i].saveInBackground()
        }
        //newActive[size - 1].setValue(newActive[0].playerID, forKey: "target")
        //newActive[size - 1].saveInBackground()
        
        print("Assigning targets")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
