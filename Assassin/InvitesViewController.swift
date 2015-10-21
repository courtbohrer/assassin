//
//  InvitesViewController.swift
//  Assassin
//
//  Created by Courtney Bohrer on 10/18/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

import UIKit

class InvitesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
        
        let index:Int = indexPath.row
        let game = self.invitedGames[index]
        let player = PFUser.currentUser()
        let playerID = player!.objectForKey("FacebookID")!
        let playerObject = Player(playerID: playerID as! String, targetID: "")
        var activePlayers:[Player] = game.objectForKey("activePlayers") as! [Player]
        
        activePlayers.append(playerObject)
        game.setObject(activePlayers, forKey: "activePlayers")

        game.objectForKey("invitedPlayers")?.removeObject(playerID)
        
        game.saveInBackground()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButton(sender: AnyObject) {
    }
}
