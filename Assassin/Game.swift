//
//  Game.swift
//  Assassin
//
//  Created by Quan Vo on 10/18/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

class Game: PFObject, PFSubclassing {
    
    private var _gameName:String = ""
    var invitedPlayers:[String] = []
    var activePlayers:[String] = []
    
    var gameName:String {
        get {
            return _gameName
        }
        set (new) {
            _gameName = new
        }
    }
    
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
    
    init(gameName:String, invitedPlayers:[String], activePlayers:[String]) {
        super.init()
        self.gameName = gameName
        self.invitedPlayers = invitedPlayers
        self.activePlayers = activePlayers
    }
    
    convenience override init() {
        self.init(gameName:"<noGameName>", invitedPlayers:[], activePlayers:[])
    }
    
}