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
    
    let game = Game()
    let friends = PFUser.currentUser()!.objectForKey("Friends") as! NSArray
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameNameTextField.delegate = self
        self.friendPickerTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let friend = friends[index]
        
        cell.textLabel!.text = friend.objectForKey("name")! as? String
        cell.accessoryType = .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let index = indexPath.row
        let friendId = friends[index].objectForKey("id") as! String
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .Checkmark {
                let indexOfSelectedFriend = game.invitedPlayers.indexOf(friendId)
                game.invitedPlayers.removeAtIndex(indexOfSelectedFriend!)
                cell.accessoryType = .None
            } else {
                game.invitedPlayers.append(friendId)
                cell.accessoryType = .Checkmark
            }
        }
    }
    
    @IBAction func createGameAction(sender: AnyObject) {
        
        // Game creator must give the game a name
        if gameNameTextField.text == "" {
            let alertView = UIAlertController(title: "No Game Name", message: "Let's give this game a name!", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "Okay!", style: .Default, handler: nil))
            presentViewController(alertView, animated: true, completion: nil)
            return
        }
        
        // Game creator must invite at least one player
        if game.invitedPlayers.count == 0 {
            let alertView = UIAlertController(title: "Not Enough Players", message: "You should probably invite at least one opponent!", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "Okay!", style: .Default, handler: nil))
            presentViewController(alertView, animated: true, completion: nil)
            return
        }
        
        // Set up
        game.setValue(gameNameTextField.text!, forKey: "Name")
        game.setObject(game.invitedPlayers, forKey: "invitedPlayers")
        
        // Create player object for game creator
        let currentUser = PFUser.currentUser()
        let playerID = currentUser!.objectForKey("FacebookID")!
        let playerObject = Player(playerID: playerID as! String, targetID: "")
        playerObject.setValue(currentUser?.objectForKey("Name"), forKey: "Name")
        playerObject.setValue(playerID, forKey: "FacebookID")
        playerObject.setValue(false, forKey: "isKilled");
        playerObject.saveInBackground()
        
        // Add game creator to game
        let activePlayers = [playerObject]
        game.setObject(activePlayers, forKey: "activePlayers")
        game.setValue(1, forKey: "numPlayers")
        
        // Save game
        game.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if (success) {
                // Set game and player pointers for game creator
                currentUser!.setObject(self.game, forKey: "currentGame")
                currentUser!.setObject(playerObject, forKey: "player")
                currentUser!.saveInBackground()
            } else {
                print("Error saving game: \(error)")
            }
        }
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