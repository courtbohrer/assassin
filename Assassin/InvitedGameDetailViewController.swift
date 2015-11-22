//
//  InvitedGameDetailViewController.swift
//  Assassin
//
//  Created by Quan Vo on 11/21/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

class InvitedGameDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var gameID = ""
    var game:PFObject?
    var invitedPlayers = [String]()
    let reuseIdentifier = "OtherInvitedPlayersCell"
    
    @IBOutlet weak var labelInvitedGameName: UILabel!
    @IBOutlet weak var labelWhoInvitedYou: UILabel!
    @IBOutlet weak var tableViewTheOtherInvitedPlayers: UITableView!
    @IBOutlet weak var buttonAccept: UIButton!
    @IBOutlet weak var buttonDecline: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        tableViewTheOtherInvitedPlayers.registerClass(UITableViewCell.self, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        //        tableViewTheOtherInvitedPlayers.delegate = self
        //        tableViewTheOtherInvitedPlayers.dataSource = self
        
        var query = PFQuery(className:"Game")
        query.getObjectInBackgroundWithId(gameID) {
            (game: PFObject?, error: NSError?) -> Void in
            if error == nil && game != nil {
                self.game = game!
                
                let gameName = self.game!.objectForKey("Name") as! String
                let gameHost = self.game!.objectForKey("Host") as! String
                self.labelInvitedGameName.text = gameName
                self.labelWhoInvitedYou.text = gameHost + " invited you!"
                
                // why doesn't this fucking work
                let activePlayers = game?.objectForKey("activePlayers") as! [PFObject]
                for player in activePlayers {
                    let playerName = player.objectForKey("Name") as! String
                    print(playerName + "hi bitch")
                    self.invitedPlayers.append(playerName)
                }
                
                let invitedPlayers = game?.objectForKey("invitedPlayers") as! [String]
                for player in invitedPlayers {
                    query = PFQuery(className:"Player")
                    query.getObjectInBackgroundWithId(player) {
                        (player: PFObject?, error: NSError?) -> Void in
                        if error == nil && player != nil {
                            let playerName = player!.objectForKey("Name") as! String
                            self.invitedPlayers.append(playerName)
                        } else {
                            print("Player not found: \(error)")
                        }
                    }
                }
            } else {
                print("Game not found: \(error)")
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
}