//
//  NewGameViewController.swift
//  Assassin
//
//  Created by Courtney Bohrer on 10/18/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

class NewGameViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var gameNameTextField: UITextField!
    @IBOutlet weak var friendPickerTableView: UITableView!
    
    private let game:Game = Game()
    private let friends:NSArray = PFUser.currentUser()!.objectForKey("Friends") as! NSArray
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        gameNameTextField.delegate = self
        
        self.friendPickerTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // populate friend picker table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let friend = self.friends[indexPath.row]
        
        cell.textLabel!.text = friend.objectForKey("name")! as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let index:Int = indexPath.row
        let friendId:String = self.friends[index].objectForKey("id") as! String
        
        if !self.game.invitedPlayers.contains(friendId) {
            self.game.invitedPlayers.append(friendId)
        }
    }
    
    // create game
    @IBAction func createGameAction(sender: AnyObject) {
        
        // create the game
        self.game.setValue(self.gameNameTextField.text!, forKey: "Name")
        self.game.setObject(self.game.invitedPlayers, forKey: "invitedPlayers")
        
        //create player object of self and add to game
        let player = PFUser.currentUser()
        let playerID = player!.objectForKey("FacebookID")!
        let playerObject = Player(playerID: playerID as! String, targetID: "")
        playerObject.setValue(playerID, forKey: "FacebookID")
        playerObject.saveInBackground()
        let activePlayers = [playerObject]
        self.game.setObject(activePlayers, forKey: "activePlayers")

        //save game
        self.game.saveInBackground()
        
        
        
        /*
        
        // update current user's current games and save
        // but crashes
        
        let currentUser:PFUser = PFUser.currentUser()!
        var currentGames:[String] = currentUser.objectForKey("currentGames") as! [String]
        
        currentGames.append(self.game.objectForKey("objectId") as! String)
        
        currentUser.saveInBackground()
        
        */
        
        // we need to notify all invitees they've been invited
        // we need to update all invitees' invitedGames list to this game id
        // i tried grabbing the game object id above, not able to know if that works
        // we need to have the current game controller be some kind of waiting for room till game starts/drops
        // game needs to start when invite list is empty
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}