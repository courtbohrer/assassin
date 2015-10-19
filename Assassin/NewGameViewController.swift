//
//  NewGameViewController.swift
//  Assassin
//
//  Created by Courtney Bohrer on 10/18/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

class NewGameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var gameNameTextField: UITextField!
    @IBOutlet weak var inviteFriendsTableView: UITableView!
    
    var invitedPlayers:[PFUser] = []
    var inviteFriendsTableViewData:[NSDictionary] = []
    
    var friendNames:[NSString] = []
    var friendIDs:[NSString] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        gameNameTextField.delegate = self
        
        // pull current user's friends to populate invite friends table view
        let fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil)
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error == nil {
                
                print("Friends are : \(result)")
                
                if let friendObjects = result["data"] as? [NSDictionary] {
                    
                    self.inviteFriendsTableViewData = friendObjects
                    
                    for friendObject in friendObjects {
                        
                        // self.inviteFriendsTableViewData.append(friendObject["id"] as! String)
                        
                        /*
                        print(friendObject["id"] as! NSString)
                        print(friendObject["name"]as! NSString)
                        */

                        self.friendNames.append(friendObject["name"] as! NSString)
                        self.friendIDs.append(friendObject["id"] as! NSString)
                    }
                }
            } else {
                print("Error Getting Friends \(error)");
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    // populate invite friends table view
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.friendNames.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let cell:UITableViewCell = UITableViewCell(style:UITableViewCellStyle.Default, reuseIdentifier:"cell")
        
        print(friendNames[0])
        
        cell.textLabel?.text = friendNames[indexPath.row] as String
        
        return cell
    }
    
    // create game
    
    @IBAction func createGameAction(sender: AnyObject) {
        
        let game:Game = Game(gameName: gameNameTextField.text!, invitedPlayers: [], activePlayers: [PFUser.currentUser()!])
        
        game.setValue(gameNameTextField.text!, forKey: "Name")
        game.setObject(invitedPlayers, forKey: "invitedPlayers")
        game.setObject(game.activePlayers, forKey: "activePlayers")
        
        game.saveInBackground()
    }
}