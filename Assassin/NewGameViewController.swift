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
        
        // create the game and save
        // crashes when i try to append current user to activePlayers
        self.game.setValue(self.gameNameTextField.text!, forKey: "Name")
        self.game.setObject(self.game.invitedPlayers, forKey: "invitedPlayers")
        self.game.setObject(self.game.activePlayers, forKey: "activePlayers")
        
        self.game.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                let gameId:String = self.game.objectId!
                for player in self.game.invitedPlayers{
                    let query:PFQuery = PFUser.query()!
                    query.whereKey("FacebookID", equalTo: player)
                    query.getFirstObjectInBackgroundWithBlock {
                        (object: PFObject?, error: NSError?) -> Void in
                        if error != nil || object == nil {
                            print("The getFirstObject request failed.")
                        } else {
                            // The find succeeded.
                            print("Successfully retrieved the object.")
                            
                            // var invitedGames:[String] = object!.objectForKey("invitedGames") as! [String]
                            // invitedGames.append("dummy arrray")
                            // object!.setObject(invitedGames, forKey: "invitedGames")
                            // object["invitedGames"] = invitedGames
                            // object!.setValue("new courtney", forKey: "Name")
                            // object!.addUniqueObjectsFromArray(["hi"], forKey: "invitedGames")
                            // object!.saveInBackground()
                            
                            object!.saveInBackgroundWithBlock {
                                (success: Bool, error: NSError?) -> Void in
                                if (success) {
                                    // The object has been saved.
                                    print("Object saved")
                                } else {
                                    // There was a problem, check error.description
                                    print("Object not saved")
                                }
                            }
                        }
                    }
                }
            } else {
                // There was a problem, check error.description
            }
        }
        
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