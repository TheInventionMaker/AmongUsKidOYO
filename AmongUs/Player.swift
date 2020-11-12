//
//  Player.swift
//  AmongUs
//
//  Created by James Nagler on 10/29/20.
//

import Foundation
import SpriteKit
enum colors{
    case cyan, lime, green, blue, orange, red, yellow, pink, purple, black, brown, white
}
enum states{
    case dead, alive
}
enum types{
    case crewmate, imposter
}
enum directions{
    case none, right, left, vent
}

struct person{
    var color: colors
    var state: states
    var type: types
    var direction: directions
    var texture: [Any]
    var speed: Double
    var player: SKSpriteNode
    var name: SKLabelNode
    var pastDirection: directions
    var tableId: Int
    var pastPosition: CGPoint
    var tasks: [tasks]
    var commonTasks: [tasks]
    var tasksDone: [tasks]
}

enum categories:UInt32{
    case player = 1
    case wall = 2
}
class Task{
    
}
/*
 *  Class PLAYER:
 *      First call init
 *      Every () frames call updateMovement()
 *      If kill, call kill
 */
class player{
    public var thePlayer: person
    public var vision = 0.0
    public var killDistance = distances.short
    private var animationRate = 0.05
    private var counter = 0
    public var finishedTasks1 = [tasks]()
    public var finishedTasks2 = [tasks]()
    public var finishedTasks3 = [tasks]()
    init(color: colors, state: states, type: types, direction: directions, speed: Double, name: String, id: Int){
        thePlayer = person(color: color, state: state, type: type, direction: direction, texture: textureDictionary[color]![directions.none]! , speed: speed, player: SKSpriteNode(imageNamed: "bob"), name: SKLabelNode(text: name), pastDirection: directions.none, tableId: id, pastPosition: CGPoint(x: 0, y: 0), tasks: [], commonTasks: [],tasksDone: [])
        generateSprite()
    }
    func generateSprite(){
        let player = SKSpriteNode(texture: SKTexture(imageNamed: (textureDictionary[thePlayer.color]![directions.none]!)[thePlayer.tableId > 5 ? 0 : 1] ))
        player.setScale(0.8)
        player.position = CGPoint(x: 0,y: 0)
        player.name = thePlayer.name.text
        player.zPosition = 3
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: player.size.width, height: 5))
        player.anchorPoint = CGPoint(x: 0.5, y: 0)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = categories.player.rawValue
        player.physicsBody?.collisionBitMask = categories.wall.rawValue
        let label = SKLabelNode(text: thePlayer.name.text)
        label.position = thePlayer.player.position
        label.position.y += 60
        label.fontColor = thePlayer.type == types.imposter ? UIColor.red : UIColor.white
        label.name = thePlayer.name.text
        label.fontSize = 20
        label.zPosition = 20
        label.fontName = "Arial"
        thePlayer.player = player
        thePlayer.name = label
    }
    var counterA = 0
    func updateMovement(num: Int){
        if thePlayer.direction == directions.right{
            thePlayer.texture = textureDictionary[thePlayer.color]![directions.right]!
        }else if thePlayer.direction == directions.left{
            thePlayer.texture = textureDictionary[thePlayer.color]![directions.left]!
        }else if thePlayer.direction == directions.none{
            thePlayer.player.texture = SKTexture(imageNamed: textureDictionary[thePlayer.color]![directions.none]![thePlayer.pastDirection == directions.right ? 0 : 1])
        }else{
            thePlayer.texture = textureDictionary[thePlayer.color]![directions.vent]!
        }
        if thePlayer.state != states.dead && thePlayer.direction != directions.none{
                animatePlayer(num: num % 25)
        }
        if thePlayer.direction != directions.none{
            thePlayer.pastDirection = thePlayer.direction
        }
    }
    
    func animatePlayer(num: Int){
        if num == 0{
            for (index, name) in thePlayer.texture.enumerated(){
                DispatchQueue.main.asyncAfter(deadline: .now() + (Double(index) * animationRate)){
                    self.thePlayer.player.texture = SKTexture(imageNamed: name as! String)
                }
            }
        }
    }
    private func vent(){
        
    }
    func kill(target: person){
        
    }
    
}
