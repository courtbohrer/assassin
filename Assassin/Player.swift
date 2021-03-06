//
//  Player.swift
//  Assassin
//
//  Created by Courtney Bohrer on 10/19/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

class Player: PFObject, PFSubclassing {
    
    var playerID = ""
    var targetID = ""
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "Player"
    }
    
    init(playerID:String, targetID:String) {
        super.init()
        self.playerID = playerID
        self.targetID = targetID
    }

    override init() {
        super.init()
        playerID = ""
        targetID = ""
    }
}