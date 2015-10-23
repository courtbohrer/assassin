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
        
        
        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        
        //check if the user is logged in
        if(PFUser.currentUser() == nil){
            //if they are not, bring up the login screen
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            vc.modalPresentationStyle = UIModalPresentationStyle.Popover
            presentViewController(vc, animated: true, completion:nil)
        } else {
            let myFBID:String =  PFUser.currentUser()?.objectForKey("FacebookID") as! String
            let query = PFQuery(className:"Game")
            query.whereKey("invitedPlayers", containsAllObjectsInArray:[myFBID])
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) scores.")
                    // Do something with the found objects
                    if objects?.isEmpty == false{
                        self.invitesButton.backgroundColor = UIColor.redColor()
                        print("has invites")
                    } else {
                       self.invitesButton.backgroundColor = UIColor.whiteColor()
                    }
                } else {
                    // Log details of the failure
                    //print("Error: \(error!) \(error!.userInfo!)")
                    print("query error")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTouchLogoutButton(sender: AnyObject) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        presentViewController(vc, animated: true, completion:nil)
        
        
    }

    @IBAction func didTouchInvitesButton(sender: AnyObject) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("InvitesViewController") as! InvitesViewController
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        presentViewController(vc, animated: true, completion:nil)
        
    }
    
    @IBAction func didTouchCurrentGameButton(sender: AnyObject) {
        if(PFUser.currentUser()?.objectForKey("currentGame") == nil){
            let alert:UIAlertView = UIAlertView()
            alert.title = "No Current Games"
            alert.message = "It looks like you don't have any games yet. Feel free to start one by clicking New Game."
            alert.addButtonWithTitle("Okay!")
            alert.show()

        } else {
            performSegueWithIdentifier("goToCurrentGame", sender: nil)
        }
    }
    @IBAction func didTouchNewGameButton(sender: AnyObject) {
        if(PFUser.currentUser()?.objectForKey("currentGame") != nil){
            let alert:UIAlertView = UIAlertView()
            alert.title = "Existing Game"
            alert.message = "It looks like you are already in a game. In our current version you can only be in one game at a time."
            alert.addButtonWithTitle("Okay!")
            alert.show()
        } else {
            performSegueWithIdentifier("goToNewGame", sender: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
