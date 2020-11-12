//
//  Game.swift
//  AmongUs
//
//  Created by James Nagler on 11/2/20.
//

import Foundation
enum distances{
    case short, medium, long
}
struct game{
    var playerCount: Int
    var players: [player]
    var begun: Bool
    var meetings: Int
    var cooldownMeetings: Int
    var discussion: Int
    var voting: Int
    var playerSpeed: Double
    var crewmateVision: Double
    var imposterVision: Double
    var killDistance: distances
    var commonTasks: Int
    var shortTasks: Int
    var longTasks: Int
    var imposters: Int
    var tasksDone: Int
}
enum tasks{
    case alignEngine, calibrateDist, chart, cleanO2F, asteroids, divertPower, emptyChute, emptyGarbage, fuelEngine, sample, shields, steering, reactor, scan, card, mainfolds, upload, wiringA, wiringC, wiringE, wiringN, wiringSE, wirintST
}
enum commonTasks{
    case wiring
}
class Game{
    public var theGame: game
    private var shortTasks = [tasks.alignEngine, tasks.calibrateDist, tasks.chart, tasks.cleanO2F, tasks.divertPower, tasks.shields, tasks.steering, tasks.mainfolds, tasks.upload]
    private var longTasks = [tasks.asteroids, tasks.emptyChute, tasks.emptyGarbage, tasks.fuelEngine, tasks.sample, tasks.reactor, tasks.scan, tasks.card]
    private var wiring = [tasks.wiringA, tasks.wiringC, tasks.wiringE, tasks.wiringN, tasks.wiringSE, tasks.wirintST]
    init(playerCount: Int, players: [player], begun: Bool, meetings: Int, cooldownMeetings: Int, discussion: Int, voting: Int, playerSpeed: Double, crewmateVision: Double, imposterVision: Double, killDistance: distances, commonTasks: Int, shortTasks: Int, longTasks: Int, imposters: Int){
        theGame = game(playerCount: playerCount, players: players, begun: begun, meetings: meetings, cooldownMeetings: cooldownMeetings, discussion: discussion, voting: voting, playerSpeed: playerSpeed, crewmateVision: crewmateVision, imposterVision: imposterVision, killDistance: killDistance, commonTasks: commonTasks, shortTasks: shortTasks, longTasks: longTasks, imposters: imposters, tasksDone: 0)
    }
    func initalizePlayers(){
        let randomIdA = Int.random(in: 1...theGame.players.count)
        var randomIdB = Int.random(in: 1...theGame.players.count)
        while randomIdB == randomIdA{
            randomIdB = Int.random(in: 1...theGame.players.count)
        }
        for player in theGame.players{
            if player.thePlayer.tableId == randomIdA || player.thePlayer.tableId == randomIdB{
                player.thePlayer.type = types.imposter
                player.vision = theGame.imposterVision
                player.killDistance = theGame.killDistance
            }else{
                player.vision = theGame.crewmateVision
            }
            assignTasks(player: player)
        }
        
    }
    private func assignTasks(player: player){
        for _ in 0..<theGame.shortTasks{
            let position = Int.random(in: 0..<shortTasks.count)
            player.thePlayer.tasks.append(shortTasks[position])
            shortTasks.remove(at: position)
            if shortTasks.count == 0{
                shortTasks = [tasks.alignEngine, tasks.calibrateDist, tasks.chart, tasks.cleanO2F, tasks.divertPower, tasks.shields, tasks.steering, tasks.mainfolds, tasks.upload]
            }
        }
        for _ in 0..<theGame.longTasks{
            let position = Int.random(in: 0..<longTasks.count)
            player.thePlayer.tasks.append(longTasks[position])
            longTasks.remove(at: position)
            if longTasks.count == 0{
                longTasks = [tasks.asteroids, tasks.emptyChute, tasks.emptyGarbage, tasks.fuelEngine, tasks.sample, tasks.reactor, tasks.scan, tasks.card]
            }
        }
        if theGame.commonTasks == 1{
            let index = Int.random(in: 0..<2)
            if index == 1{
                player.thePlayer.commonTasks.append(tasks.card)
            }else{
                let index2 = Int.random(in: 0..<wiring.count)
                player.thePlayer.commonTasks.append(wiring[index2])
                var newIndex = Int.random(in: 0..<wiring.count)
                while index2 == newIndex{
                    newIndex = Int.random(in: 0..<wiring.count)
                }
                player.thePlayer.commonTasks.append(wiring[newIndex])
                var index3 = Int.random(in: 0..<wiring.count)
                while index3 == newIndex{
                    index3 = Int.random(in: 0..<wiring.count)
                }
                player.thePlayer.commonTasks.append(wiring[index3])
            }
        }else if theGame.commonTasks == 2{
            player.thePlayer.commonTasks.append(tasks.card)
            let index2 = Int.random(in: 0..<wiring.count)
            player.thePlayer.commonTasks.append(wiring[index2])
            var newIndex = Int.random(in: 0..<wiring.count)
            while index2 == newIndex{
                newIndex = Int.random(in: 0..<wiring.count)
            }
            player.thePlayer.commonTasks.append(wiring[newIndex])
            var index3 = Int.random(in: 0..<wiring.count)
            while index3 == newIndex{
                index3 = Int.random(in: 0..<wiring.count)
            }
            player.thePlayer.commonTasks.append(wiring[index3])
        }
        //Task class:
        //public variable type, with enum of types
        //isCompleted() function that returns a number
        //Distance to the player
        
    }
}
