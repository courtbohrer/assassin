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
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {

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
                    self.getFBFriends()
                } else {
                    self.dismiss()
                    self.getFBFriends()
                }
            } else {
                let alertView = UIAlertController(title: "Oops!", message: "We see that you cancelled your Facebook login, but we need to know who you are in order to play the game. Would you mind trying again?", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "Okay!", style: .Default, handler: nil))
                self.presentViewController(alertView, animated: true, completion: nil)
            }
        }
    }
    
    func returnUserData() {
        let currentUser = PFUser.currentUser()
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath:"me", parameters:["fields": "id, picture, name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil) {
                print("Error requesting Facebook data: \(error)")
            }
            else {
                if ((currentUser) != nil) {
                    currentUser?.setValue(result.valueForKey("name"), forKey: "Name")
                    currentUser?.setValue(result.objectForKey("id"), forKey: "FacebookID")
                    let urlStr = result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String
                    let url = NSURL(string: urlStr)
                    let request = NSURLRequest(URL: url!)
                    var response:NSURLResponse?
                    do {
                        let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
                        let file:PFFile = PFFile(data: data as! NSData)!
                        PFUser.currentUser()?.setObject(file, forKey: "profPicData")
                        PFUser.currentUser()?.saveInBackground()
                        
                    }
                    catch(let e){
                        print(e)
                    }
                    
                    
                    //currentUser?.setValue(url, forKey: "profPicURL")
                    currentUser?.saveInBackground()
                    
//                    let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                    
//                    let userID = result.valueForKey("id") as! NSString
//                    let facebookProfileUrl = "http://graph.facebook.com/\(userID)/picture?type=large"
//                    let data = NSData(contentsOfURL: facebookProfileUrl)
//                    currentUser?.setObject(data, forKey: "profPicData")
//                    let pic = result.objectForKey("picture")
//                    let profPic = PFFile(name:"image.jpeg", data: pic as! NSData)
//                    currentUser?.setObject(profPic!, forKey: "profPic")
                }
                
            }
        })
    }
    
    func getFBFriends() {
        let currentUser = PFUser.currentUser()
        let fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil)
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            if error == nil {
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
}