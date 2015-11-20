//
//  Game.swift
//  Assassin
//
//  Created by Quan Vo on 10/18/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

class Game: PFObject, PFSubclassing {
    
    var gameName = ""
    var invitedPlayers:[String] = []
    var activePlayers:[PFObject] = []
    var killMethod = ""
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "Game"
    }
    
    func getRandomKillMethod() -> String {
        let killMethods = KillMethods()
        let random = Int(arc4random_uniform(UInt32(killMethods.killMethods.count - 1)))
        return killMethods.killMethods[random]
    }
    
    init(gameName:String, invitedPlayers:[String], activePlayers:[PFObject]) {
        super.init()
        self.gameName = gameName
        self.invitedPlayers = invitedPlayers
        self.activePlayers = activePlayers
        self.killMethod = getRandomKillMethod()
    }
    
    override init() {
        super.init()
        self.gameName = ""
        self.invitedPlayers = []
        self.activePlayers = []
        self.killMethod = getRandomKillMethod()
    }
}