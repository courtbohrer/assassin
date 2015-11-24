//
//  DashboardViewController.swift
//  Assassin
//
//  Created by Courtney Bohrer on 10/18/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UIPopoverControllerDelegate {

    @IBOutlet weak var invitesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        if(PFUser.currentUser() == nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            vc.modalPresentationStyle = UIModalPresentationStyle.Popover
            presentViewController(vc, animated: true, completion:nil)
        } else {
            let myFBID = PFUser.currentUser()?.objectForKey("FacebookID") as! String
            let query = PFQuery(className:"Game")
            query.whereKey("invitedPlayers", containsAllObjectsInArray:[myFBID])
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    if objects?.isEmpty == false {
                        self.invitesButton.setImage(UIImage(named: "alertTrue"), forState: UIControlState.Normal)
                    } else {
                       self.invitesButton.setImage(UIImage(named: "alertFalse"), forState: UIControlState.Normal)
                    }
                } else {
                    print("Error querying game's invited players: \(error)")
                }
            }
        }
    }
    
    @IBAction func didTouchLogoutButton(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        PFUser.logOut()
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        presentViewController(vc, animated: true, completion:nil)
    }

    @IBAction func didTouchInvitesButton(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("InvitesViewController") as! InvitesViewController
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        presentViewController(vc, animated: true, completion:nil)
    }
    
    @IBAction func didTouchCurrentGameButton(sender: AnyObject) {
        if(PFUser.currentUser()?.objectForKey("currentGame") == nil) {
            let alertView = UIAlertController(title: "No Current Games", message: "It looks like you don't have any games yet. Feel free to start one by clicking New Game.", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "Okay!", style: .Default, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        } else {
            performSegueWithIdentifier("goToCurrentGame", sender: nil)
        }
    }
    
    @IBAction func didTouchNewGameButton(sender: AnyObject) {
        if(PFUser.currentUser()?.objectForKey("currentGame") != nil) {
            let alertView = UIAlertController(title: "Existing Game", message: "It looks like you are already in a game. In our current version you can only be in one game at a time.", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "Okay!", style: .Default, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        } else {
            performSegueWithIdentifier("goToNewGame", sender: nil)
        }
    }
}
