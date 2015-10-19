//
//  NewGameViewController.swift
//  Assassin
//
//  Created by Courtney Bohrer on 10/18/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

import UIKit

class NewGameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var gameNameTextField: UITextField!
    var invitedPlayers:[PFUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameNameTextField.delegate = self
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

    @IBAction func createGameAction(sender: AnyObject) {
        
        let game:Game = Game(gameName: gameNameTextField.text!, invitedPlayers: [], activePlayers: [])
     
        game.activePlayers.append(PFUser.currentUser()!)
        game.setObject(invitedPlayers, forKey: "invitedPlayers")
        game.setObject(game.activePlayers, forKey: "activePlayers")
        game.setValue(gameNameTextField.text!, forKey: "Name")
        
        game.saveInBackground()
        
    }
    
}