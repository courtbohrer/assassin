//
//  Player.swift
//  Assassin
//
//  Created by Courtney Bohrer on 10/19/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

class Player: PFUser {
    
    var firstName:String
    var lastName:String
    var friends:String
    var invites:[String]
    var currentGames:[String]
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    override init(){
        
        firstName = ""
        lastName = ""
        friends = ""
        invites = []
        currentGames = []
        
        super.init()
        
    }
    
}