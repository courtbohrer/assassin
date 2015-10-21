//
//  LoginViewController.swift
//  Assassin
//
//  Created by Courtney Bohrer on 10/18/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

import ParseFacebookUtilsV4
import UIKit

class LoginViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    let permissions = ["public_profile", "user_friends"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if(PFUser.currentUser() == nil){
            logoutButton.hidden = true;
            loginButton.hidden = false;
        } else {
            loginButton.hidden = true;
            logoutButton.hidden = false;
        }
    }
    
    @IBAction func didTouchLogout(sender: AnyObject) {
        PFUser.logOut()
        logoutButton.hidden = true;
        loginButton.hidden = false;
    }
    
    @IBAction func didTouchLoginButton(sender: AnyObject) {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    self.returnUserData()
                    self.dismiss()
                    //self.performSegueWithIdentifier("toMainPage", sender: nil)
                    print("User signed up and logged in through Facebook!")
                } else {
                    self.dismiss()
                    //self.performSegueWithIdentifier("toMainPage", sender: nil)
                    print("User logged in through Facebook!")
                }
            } else {
                let alert:UIAlertView = UIAlertView()
                alert.title = "Uh Oh!"
                alert.message = "We see that you cancelled your Facebook login, but we need to know who you are in order to play the game. Would you mind trying again?"
                alert.addButtonWithTitle("Okay!")
                alert.show()
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
    }
    
    func returnUserData()
    {
        let currentUser = PFUser.currentUser()
        
        //get basic info and save
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath:  "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                
                print(result.valueForKey("name"))
                print(result.objectForKey("id"))
                if ((currentUser) != nil){
                    currentUser?.setValue(result.valueForKey("name"), forKey: "Name")
                    currentUser?.setValue(result.objectForKey("id"), forKey: "FacebookID")
                    
                    /*
                    // i'm trying to add 'currentGames' array of strings for each user
                    // but this doesn't seem to do anything
                    
                    let currentGames:[String] = []
                    currentUser?.setObject(currentGames, forKey: "currentGames")
                    
                    */

                    //currentUser?.setValue(result.objectForKey("friends"), forKey: "Friends")
                    
                }
                
                currentUser?.saveInBackground()
                
            }
        })
        
        //get friends list and save
        let fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil)
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error == nil {
                
                print("Friends are : \(result)")
                currentUser?.setValue(result["data"] as? [NSDictionary], forKey: "Friends");
                currentUser?.saveInBackground()
                
                
            } else {
                print("Error Getting Friends \(error)");
            }
        }
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
