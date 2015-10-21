//
//  Player.swift
//  Assassin
//
//  Created by Courtney Bohrer on 10/19/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

class Player: NSObject {
    
    var playerID:String
    var targetID:String
    
    init(playerID:String, targetID:String) {
        self.playerID = playerID
        self.targetID = targetID
        super.init()
    }
    
    override init(){
        playerID = ""
        targetID = ""
        super.init()
    }
}