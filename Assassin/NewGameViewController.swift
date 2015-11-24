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
    
    let friends = PFUser.currentUser()!.objectForKey("Friends") as! NSArray
    var invitedPlayers = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        gameNameTextField.delegate = self
        self.friendPickerTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let friend = friends[index]
        
        cell.textLabel!.text = friend.objectForKey("name")! as? String
        cell.textLabel!.font = UIFont(name: "AvenirNext-Bold", size: 16)
        cell.backgroundColor = UIColor(red:1.00, green:0.19, blue:0.19, alpha: 1.0)
        cell.accessoryType = .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let index = indexPath.row
        let friendId = friends[index].objectForKey("id") as! String
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .Checkmark {
                let indexOfSelectedFriend = invitedPlayers.indexOf(friendId)
                invitedPlayers.removeAtIndex(indexOfSelectedFriend!)
                cell.accessoryType = .None
            } else {
                invitedPlayers.append(friendId)
                cell.accessoryType = .Checkmark
            }
        }
    }
    
    @IBAction func createGameAction(sender: AnyObject) {
        
        // Game creator must give the game a name
        if gameNameTextField.text == "" {
            let alertView = UIAlertController(title: "No Game Name", message: "Let's give this game a name first!", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "Okay!", style: .Default, handler: nil))
            presentViewController(alertView, animated: true, completion: nil)
            return
        }
        
        // Game creator must invite at least one player
        if invitedPlayers.count == 0 {
            let alertView = UIAlertController(title: "Not Enough Players", message: "You should probably invite at least one opponent!", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "Okay!", style: .Default, handler: nil))
            presentViewController(alertView, animated: true, completion: nil)
            return
        }
        
        let game = Game()
        
        // Set up
        game.setValue(gameNameTextField.text!, forKey: "Name")
        game.setObject(invitedPlayers, forKey: "invitedPlayers")
        game.setObject(game.killMethod, forKey: "killMethod")
        
        // Create player object for game creator
        let currentUser = PFUser.currentUser()
        let playerID = currentUser!.objectForKey("FacebookID")!
        let playerObject = Player(playerID: playerID as! String, targetID: "")
        playerObject.setValue(currentUser?.objectForKey("Name"), forKey: "Name")
        playerObject.setValue(playerID, forKey: "FacebookID")
        playerObject.setValue(false, forKey: "isKilled");
        playerObject.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if (success) {
                // Set game creator as host and add to game
                let hostName = currentUser?.objectForKey("Name")
                game.setObject(hostName!, forKey: "Host")
                
                let activePlayers = [playerObject]
                game.setObject(activePlayers, forKey: "activePlayers")
                game.setValue(1, forKey: "numPlayers")
                
                // Save game
                game.saveInBackgroundWithBlock {
                    (success, error) -> Void in
                    if (success) {
                        
                        // Set game and player pointers for game creator
                        currentUser!.setObject(game, forKey: "currentGame")
                        currentUser!.setObject(playerObject, forKey: "player")
                        currentUser!.saveInBackground()
                    } else {
                        print("Error saving game: \(error)")
                    }
                }
            } else {
                print("Error saving player object: \(error)")
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
}