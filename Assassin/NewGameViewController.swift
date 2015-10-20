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
    
    // private var invitedPlayers:[String] = []
    // private var game:Game = Game(gameName: "", invitedPlayers: [], activePlayers: [PFUser.currentUser()?.objectForKey("id") as! String])
    var game:Game = Game()
    private let friends = PFUser.currentUser()!.objectForKey("Friends") as! NSArray
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        gameNameTextField.delegate = self
        
        self.friendPickerTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
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

    @IBAction func createGameAction(sender: AnyObject) {
        
        self.game.setValue(self.gameNameTextField.text!, forKey: "Name")
        self.game.setObject(self.game.invitedPlayers, forKey: "invitedPlayers")
        self.game.setObject(self.game.activePlayers, forKey: "activePlayers")
        
        self.game.saveInBackground()
        
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