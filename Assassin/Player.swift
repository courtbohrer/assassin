//
//  Player.swift
//  Assassin
//
//  Created by Courtney Bohrer on 10/19/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

class Player: PFUser {
    
    var name:String
    var friends:[String]
    var invitedGames:[String]
    var currentGames:[String]
    var target:String
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    override init(){
        
        name = ""
        friends = []
        invitedGames = []
        currentGames = []
        target = ""
        
        super.init()
        
    }
    
}