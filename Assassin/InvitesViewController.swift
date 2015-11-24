//
//  InvitesViewController.swift
//  Assassin
//
//  Created by Courtney Bohrer on 10/18/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

import UIKit

class InvitesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, InviteDetailDelegate {
    
    @IBOutlet weak var invitesTableView: UITableView!
    var invitedGames:[PFObject] = []
    var reuseIdentifier = "invitesCell"
    var justAcceptedInvite:Bool?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.invitesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.invitesTableView.delegate = self
        self.invitesTableView.dataSource = self
        justAcceptedInvite = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        if justAcceptedInvite == true {
            self.performSegueWithIdentifier("showNewGame", sender: nil)
        } else {
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
        viewController.delegate = self
        viewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        presentViewController(viewController, animated: true, completion:nil)


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
    
    func goToNewGame() {
        let alertView = UIAlertController(title: "You have been added to the game!", message: "", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Okay!", style: .Default, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
        justAcceptedInvite = true;
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}