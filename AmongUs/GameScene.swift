//
//  GameScene.swift
//  AmongUs
//
//  Created by James Nagler on 10/4/20.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene,SKPhysicsContactDelegate,UIGestureRecognizerDelegate {
    
    var personal = player(color: colors.orange, state: states.alive, type: types.crewmate, direction: directions.none, speed: 1.5, name: "James", id: 4)
    var otherPlayers = [player(color: colors.lime, state: states.alive, type: types.crewmate, direction: directions.none, speed: 1.5, name: "James1", id: 3),
                        player(color: colors.orange, state: states.alive, type: types.crewmate, direction: directions.none, speed: 1.5, name: "James2", id: 2),
                        player(color: colors.orange, state: states.alive, type: types.crewmate, direction: directions.none, speed: 1.5, name: "James3", id: 1),
                        player(color: colors.lime, state: states.alive, type: types.crewmate, direction: directions.none, speed: 1.5, name: "James4", id: 6),
                        player(color: colors.lime, state: states.alive, type: types.crewmate, direction: directions.none, speed: 1.5, name: "James5", id: 5),]
    var cam = SKCameraNode()
    let joystick = TLAnalogJoystick(withDiameter: 200)
    var game: Game?
    var wireArray = [tasks.wiringA,tasks.wiringC]
    var garbage = 0
    var engineIndex = 0
    var engineTasks = ["Storage","Lower Engine", "Storage", "Upper Engine"]
    
    var chute = 0
    var powerDiverted = false
    var powerDivertedArray = ["Upper Engine", "Lower Engine", "Weapons", "Shields", "Navigation", "Communication", "O2", "Security"]
    var powerDivertedArrayIndex = 0
    var powerDivertedDone = false
    var alignedEngine = false
    var alignDone = false
    var didDownload = false
    var downloads = ["Cafeteria", "Communications", "Electrical", "Navigation", "Weapons"]
    var downloadIndex = 0
    var uploadDone = false
    var multipleTasks = [tasks.wiringC,tasks.wiringA,tasks.wiringN,tasks.wiringE,tasks.wirintST,tasks.wiringSE,tasks.emptyGarbage,tasks.emptyChute,tasks.fuelEngine,tasks.divertPower,tasks.alignEngine,tasks.upload]
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        //personal.thePlayer.tasks.append(tasks.fuelEngine)
        powerDivertedArrayIndex = Int.random(in: 0..<powerDivertedArray.count)
        downloadIndex = Int.random(in: 0..<downloads.count)
        var allPlayers = otherPlayers
        allPlayers.append(personal)
        game = Game(playerCount: otherPlayers.count + 1, players: allPlayers, begun: false, meetings: 2, cooldownMeetings: 60, discussion: 60, voting: 60, playerSpeed: 1.25, crewmateVision: 5.0, imposterVision: 10.0, killDistance: distances.short, commonTasks: 2, shortTasks: 4, longTasks: 4, imposters: 2)
        addChild(personal.thePlayer.player)
        addChild(personal.thePlayer.name)
        for player in otherPlayers{
            addChild(player.thePlayer.player)
            addChild(player.thePlayer.name)
            player.thePlayer.player.position = self.childNode(withName: "\(player.thePlayer.tableId)")!.position
        }
        personal.thePlayer.player.position = self.childNode(withName: "\(personal.thePlayer.tableId)")!.position
        for child in self.children{
            if child.name == nil{
                child.physicsBody?.categoryBitMask = categories.wall.rawValue
                child.physicsBody?.collisionBitMask = categories.player.rawValue
            }
        }
        //self.joystick.position.x = personal.thePlayer.player.position.x - view.frame.width/2
        //self.joystick.position.y = personal.thePlayer.player.position.y - view.frame.height/2 + 500
        self.joystick.position = CGPoint(x: -self.size.width / 2 + 50, y:  self.size.height / 2 - 50)
        self.joystick.baseColor = UIColor.lightGray
        self.joystick.handleColor = UIColor.gray
        self.joystick.alpha = 0.5
        joystick.on(.move) { [unowned self] joystick in
            let pVelocity = joystick.velocity;
            let speed = CGFloat(0.24)
            personal.thePlayer.player.position = CGPoint(x: personal.thePlayer.player.position.x + (pVelocity.x * speed), y: personal.thePlayer.player.position.y + (pVelocity.y * speed))
            // self.joystick.position = CGPoint(x: self.joystick.position.x + (pVelocity.x * speed), y: self.joystick.position.y + (pVelocity.y * speed))
            
        }
        
        self.camera = cam
        self.addChild(cam)
        self.camera!.addChild(joystick)
        game!.initalizePlayers()
        createTasks()
        updateTasks()
        game!.theGame.tasksDone += personal.thePlayer.tasksDone.count
        for player in allPlayers{
            game!.theGame.tasksDone += player.thePlayer.tasksDone.count
        }
        
        let background = SKShapeNode(rect: CGRect(x: -self.size.width / 2 + 30, y:  self.size.height/4 - CGFloat(game!.theGame.commonTasks + game!.theGame.longTasks + game!.theGame.shortTasks) * 25 + 40 , width: 400, height: CGFloat((game!.theGame.commonTasks + personal.thePlayer.tasks.count) * 25) + 10))
        
        background.fillColor = UIColor.gray
        background.strokeColor = UIColor.gray
        background.alpha = 0.6
        background.name = "taskBarBackground"
        let taskText = SKLabelNode(text: "Tasks")
        // if !dismissed{self.size.height/4 - CGFloat(game!.theGame.commonTasks + game!.theGame.longTasks + game!.theGame.shortTasks) * 25 + 40
        taskText.position = CGPoint(x: -self.size.width / 2 + 410, y:  self.size.height/4 - CGFloat((game!.theGame.commonTasks + game!.theGame.longTasks + game!.theGame.shortTasks ) / 2) * 25 + 40)
        
        taskText.fontName = "Arial"
        taskText.fontSize = 20
        taskText.name = "taskBarBackground2"
        taskText.zPosition = 40
        taskText.zRotation = 1.5708
        self.camera!.addChild(taskText)
        self.camera!.addChild(background)
        createTaskBar()
        createCrewmateButtons()
        
        //showTask(task: "AcceptDivertedPower")
    }
    var previousAmount = 0
    func updateTaskBar(){
        for child in self.camera!.children{
            if child.name != nil && child.name! == "taskBar"{
                child.removeFromParent()
            }
        }
        var total = 0
        for person in otherPlayers{
            total += person.thePlayer.tasksDone.count
        }
        total += personal.thePlayer.tasksDone.count
        print(game!.theGame.commonTasks + game!.theGame.longTasks * 2 + game!.theGame.shortTasks)
        let unitRate = (500.0 / Double(otherPlayers.count + 1)) / Double(game!.theGame.commonTasks + game!.theGame.longTasks * 2 + game!.theGame.shortTasks)
        let taskBar = SKShapeNode(rect: CGRect(x: Double(-self.size.width / 2 + 35), y: Double(self.size.height / 4 + 65), width: Double(Double(total - 1) * unitRate), height: 30.0))
        taskBar.fillColor = UIColor.green
        taskBar.strokeColor = UIColor.green
        taskBar.lineWidth = 0
        taskBar.zPosition = 51
        taskBar.name = "taskBar"
        self.camera!.addChild(taskBar)
        let movingBar = SKShapeNode(rect: CGRect(x: Double(-self.size.width / 2 + 35 + taskBar.frame.size.width) - unitRate, y: Double(self.size.height / 4 + 65), width: Double(unitRate), height: 30.0))
        movingBar.fillColor = UIColor.green
        movingBar.strokeColor = UIColor.green
        movingBar.lineWidth = 0
        movingBar.zPosition = 51
        movingBar.name = "taskBar"
        
        movingBar.run(SKAction.moveBy(x: CGFloat(unitRate), y: 0.0, duration: 0.5))
        self.camera!.addChild(movingBar)
        
    }
    func scaleRoundedRect(to size: CGSize, sprite: SKShapeNode) {
        sprite.xScale = sprite.xScale * frame.width * size.width
        sprite.yScale = sprite.yScale * frame.height * size.height
    }
    func createTasks(){
        print(wireArray.count)
        taskDict[tasks.wiringA] = "Admin: Wires (\(3 - wireArray.count + 1)/3)"
        taskDict[tasks.wiringC] = "Cafeteria: Wires (\(3 - wireArray.count + 1)/3)"
        taskDict[tasks.wiringN] = "Navigation: Wires (\(3 - wireArray.count + 1)/3)"
        taskDict[tasks.wiringE] = "Electrical: Wires (\(3 - wireArray.count + 1)/3)"
        taskDict[tasks.wirintST] = "Storage: Wires (\(3 - wireArray.count + 1)/3)"
        taskDict[tasks.wiringSE] = "Security: Wires (\(3 - wireArray.count + 1)/3)"
        taskDict[tasks.emptyGarbage] = "\(garbage == 0 ? "Cafeteria" : "Storage"): Empty Garbage (\(garbage + 1)/2)"
        taskDict[tasks.emptyChute] = "\(chute == 0 ? "O2" : "Storage"): Empty Garbage (\(chute + 1)/2)"
        taskDict[tasks.fuelEngine] = "\(engineTasks[engineIndex]): Fuel Engines (\(engineIndex + 1)/4)"
        taskDict[tasks.divertPower] = "\(powerDiverted ? powerDivertedArray[powerDivertedArrayIndex] : "Electrical"): \(powerDiverted ? "Accpet Diverted Power (2" : "Divert Power (1")/2)"
        taskDict[tasks.alignEngine] = "\(alignedEngine ? "Lower Engine" : "Upper Engine"): Align Engine (\(alignedEngine ? "2" : "1")/2)"
        taskDict[tasks.upload] = "\(!didDownload ? downloads[downloadIndex] : "Admin"): \(didDownload ? "Upload (2" : "Download (1")/2)"
        for child in self.camera!.children{
            if child.name == "label"{
                child.removeFromParent()
            }
        }
        var count = 0
        var finishedWires = false
        for task in personal.thePlayer.tasks{
            let label = SKLabelNode(text: taskDict[task])
            label.position = CGPoint(x: 0, y: count * 30 - 50)
            label.position = CGPoint(x: -self.size.width / 2 + 40 + (dismissed ? -300 : 0), y:  10 + self.size.height/4 - CGFloat(count) * 25 + 15)
            label.fontSize = 20
            label.zPosition = 20
            label.fontName = "Arial"
            label.horizontalAlignmentMode = .left
            label.name = "label"
            var dict = NSMutableDictionary()
            dict = ["task": task,"matters": multipleTasks.contains(task)]
            label.userData = dict
            count += 1
            print("Hello")
            self.camera!.addChild(label)
        }
        for task in personal.thePlayer.commonTasks{
            if task == tasks.card{
                let label = SKLabelNode(text: taskDict[task])
                label.position = CGPoint(x: 0, y: count * 30 - 50)
                label.position = CGPoint(x: -self.size.width / 2 + 40 + (dismissed ? -300 : 0), y:  10 + self.size.height/4 - CGFloat(count) * 25 + 15)
                label.fontSize = 20
                label.zPosition = 20
                label.fontName = "Arial"
                label.horizontalAlignmentMode = .left
                label.name = "label"
                var dict = NSMutableDictionary()
                dict = ["task": task,"matters": multipleTasks.contains(task)]
                label.userData = dict
                count += 1
                print("Hello")
                self.camera!.addChild(label)
            }else{
                
                if !finishedWires{
                    wireArray.removeAll()
                    
                    finishedWires = true
                    let label = SKLabelNode(text: taskDict[task])
                    label.position = CGPoint(x: 0, y: count * 30 - 50)
                    label.position = CGPoint(x: -self.size.width / 2 + 40 + (dismissed ? -300 : 0), y:  self.size.height/4 - CGFloat(count) * 25 + 25)
                    label.fontSize = 20
                    label.zPosition = 20
                    label.fontName = "Arial"
                    label.horizontalAlignmentMode = .left
                    label.name = "label"
                    var dict = NSMutableDictionary()
                    dict = ["task": task,"matters": multipleTasks.contains(task)]
                    label.userData = dict
                    count += 1
                    print("Hello")
                    self.camera!.addChild(label)
                }
                wireArray.append(task)
            }
        }
    }
    var fueldEngines = false
    func updateTasks(){
        createTasks()
        for child in self.camera!.children{
            if child.name == "label"{
                if child.userData!["matters"] as! Bool{
                    let task = child.userData!["task"] as! tasks
                    let child2 = (child as! SKLabelNode)
                    if wireArray.contains(task){
                        if  3 - wireArray.count + 1 == 4{
                            child2.fontColor = UIColor.green
                        }else if 3 - wireArray.count + 1 != 1{
                            child2.fontColor = UIColor.yellow
                        }
                    }
                    if task == tasks.emptyGarbage{
                        if garbage == 2{
                            child2.fontColor = UIColor.green
                        }else if garbage != 0{
                            child2.fontColor = UIColor.yellow
                        }
                    }
                    if task == tasks.emptyChute{
                        if chute == 2{
                            child2.fontColor = UIColor.green
                        }else if chute != 0{
                            child2.fontColor = UIColor.yellow
                        }
                    }
                    if task == tasks.fuelEngine{
                        if fueldEngines{
                            child2.fontColor = UIColor.green
                        }else if engineIndex != 0{
                            child2.fontColor = UIColor.yellow
                        }
                    }
                    if task == tasks.divertPower{
                        if powerDivertedDone{
                            child2.fontColor = UIColor.green
                        }else if powerDiverted{
                            child2.fontColor = UIColor.yellow
                        }
                    }
                    if task == tasks.alignEngine{
                        if alignDone{
                            child2.fontColor = UIColor.green
                        }else if alignedEngine{
                            child2.fontColor = UIColor.yellow
                        }
                    }
                    if task == tasks.upload{
                        if uploadDone{
                            child2.fontColor = UIColor.green
                        }else if didDownload{
                            child2.fontColor = UIColor.yellow
                        }
                    }
                }
            }
        }
    }
    var taskDict = [
        tasks.alignEngine: "Engine: Align Engine", //Here
        tasks.calibrateDist: "Eletrical: Calibrate Distributor",
        tasks.chart: "Navigation: Chart Course",
        tasks.cleanO2F: "O2: Clean Filter",
        tasks.asteroids: "Navigation: Asteroids",
        tasks.divertPower: "Eletrical: Divert Power", //Here
        tasks.emptyChute: "O2: Empty Chute", //Here
        tasks.emptyGarbage: "Cafeteria: Empty Garbage", //here
        tasks.fuelEngine: "Storage: Fuel Engines", //Here
        tasks.sample: "Medbay: Inspect Sample",
        tasks.shields: "Shields: Prime Shields",
        tasks.steering: "Navigation: Correct Steering",
        tasks.reactor: "Reactor: Start Reactor",
        tasks.scan: "Medbay: Submit Scan",
        tasks.card: "Admin: Swipe Card",
        tasks.mainfolds: "Reactor: Unlock Mainfolds",
        tasks.upload: "Admin: Upload", //Here
        tasks.wiringA: "",
        tasks.wiringC: "",
        tasks.wiringE: "",
        tasks.wiringN: "",
        tasks.wiringSE: "",
        tasks.wirintST: ""
    ]
    func createTaskBar(){
        let wid = -self.size.width / 2
        let border = SKShapeNode(rect: CGRect(x: wid  + 30, y: self.size.height / 4 + 60, width: 510, height: 40))
        border.fillColor = UIColor.lightGray
        border.strokeColor = UIColor.black
        border.lineWidth = 2
        border.zPosition = 50
        border.name = "allTaskBar1"
        self.camera!.addChild(border)
        let border2 = SKShapeNode(rect: CGRect(x: wid  + 35, y: self.size.height / 4 + 65, width: 500, height: 30))
        border2.fillColor = UIColor(named: "darkGreen")!
        border2.strokeColor = UIColor.black
        border2.lineWidth = 2
        border2.zPosition = 50
        border2.name = "allTaskBar2"
        self.camera!.addChild(border2)
        let separator = 500.0 / Double(otherPlayers.count + 1)
        for n in 1...otherPlayers.count{
            var compilerBreak = Double(Double(wid) + 35.0 + Double(separator) * Double(n))
            let bar = SKShapeNode(rect: CGRect(x: compilerBreak, y: Double(self.size.height / 4 + 65), width: 5.0, height: 30.0))
            bar.fillColor = UIColor.black
            bar.strokeColor = UIColor.black
            bar.lineWidth = 0
            bar.zPosition = 52
            bar.name = "bar"
            self.camera!.addChild(bar)
        }
        let text = SKLabelNode(text: "Total Tasks")
        text.zPosition = 53
        text.fontName = "Arial"
        text.fontSize = 20
        text.color = UIColor.white
        text.position = CGPoint(x: Double(Double(wid) + 85), y: Double(self.size.height / 4 + 73))
        self.camera!.addChild(text)
    }
    var i = 0
    var dismissed = false
    var highlightDistance = 400
    //MARK: - Highlight Close Tasks
    var closestTasks = [Double]()
    var closestTask = ""
    func highlightCloseTasks(){
        closestTasks = []
        for child in self.children{
            if child.name != nil && child.name!.contains("task") && isTaskInTaskBar(task: child.userData!["task"] as! String){
                if distance(personal.thePlayer.player.position, child.position) < CGFloat(highlightDistance){
                    let task = child as! SKSpriteNode
                    task.alpha = 1
                    if distance(personal.thePlayer.player.position, child.position) < 200{
                        closestTasks.append(Double(distance(personal.thePlayer.player.position, child.position)))
                        closestTasks.sort()
                        if closestTasks[0] == Double(distance(personal.thePlayer.player.position, child.position)){
                            closestTask = task.userData!["task"] as! String
                        }
                        canUse = true
                    }else{
                        canUse = false
                    }
                }else{
                    //canUse = false
                    let task = child as! SKSpriteNode
                    task.alpha = 0
                }
            }else if child.name != nil && child.name!.contains("task"){
                let task = child as! SKSpriteNode
                task.alpha = 0
            }
        }
    }
    var canUse = false
    func createCrewmateButtons(){
        let useButton = SKSpriteNode(imageNamed: "useButton")
        useButton.position = CGPoint(x: self.size.width / 2 - 150,y: -self.size.height / 2 + 150)
        useButton.zPosition = 60
        useButton.name = "useButton"
        useButton.alpha = canUse ? 1 : 0.5
        useButton.setScale(2.0)
        self.camera!.addChild(useButton)
    }
    func createImposterButtons(){
        
    }
    func isTaskInTaskBar(task: String) -> Bool{
        /*
         taskDict[tasks.wiringA] = "Admin: Wires (\(3 - wireArray.count + 1)/3)"
         taskDict[tasks.wiringC] = "Cafeteria: Wires (\(3 - wireArray.count + 1)/3)"
         taskDict[tasks.wiringN] = "Navigation: Wires (\(3 - wireArray.count + 1)/3)"
         taskDict[tasks.wiringE] = "Electrical: Wires (\(3 - wireArray.count + 1)/3)"
         taskDict[tasks.wirintST] = "Storage: Wires (\(3 - wireArray.count + 1)/3)"
         taskDict[tasks.wiringSE] = "Security: Wires (\(3 - wireArray.count + 1)/3)"
         taskDict[tasks.emptyGarbage] = "\(garbage == 0 ? "Cafeteria" : "Storage"): Empty Garbage (\(garbage + 1)/2)"
         taskDict[tasks.emptyChute] = "\(chute == 0 ? "O2" : "Storage"): Empty Garbage (\(chute + 1)/2)"
         taskDict[tasks.fuelEngine] = "\(engineTasks[engineIndex]): Fuel Engines (\(engineIndex + 1)/4)"
         taskDict[tasks.divertPower] = "\(powerDiverted ? powerDivertedArray[powerDivertedArrayIndex] : "Electrical"): \(powerDiverted ? "Divert Power (2" : "Accept Diverted Power (1")/2)"
         taskDict[tasks.alignEngine] = "\(alignedEngine ? "Lower Engine" : "Upper Engine"): Align Engine (\(alignedEngine ? "2" : "1")/2)"
         taskDict[tasks.upload] = "\(!didDownload ? downloads[downloadIndex] : "Admin"): \(didDownload ? "Upload (2" : "Download (1")/2)"
         var powerDivertedArray = ["Upper Engine", "Lower Engine", "Weapons", "Shields", "Navigation", "Communication", "O2", "Security"]
         */
        if task == "upperEngineAcceptDivertedPower" && personal.thePlayer.tasks.contains(tasks.divertPower) && powerDivertedArray[powerDivertedArrayIndex] == "Upper Engine" && powerDiverted{
            return true
        }
        if task == "lowerEngineAcceptDivertedPower" && personal.thePlayer.tasks.contains(tasks.divertPower) && powerDivertedArray[powerDivertedArrayIndex] == "Lower Engine" && powerDiverted{
            return true
        }
        if task == "weaponsAcceptDivertedPower" && personal.thePlayer.tasks.contains(tasks.divertPower) && powerDivertedArray[powerDivertedArrayIndex] == "Weapons" && powerDiverted{
            return true
        }
        if task == "navigationAcceptDivertedPower" && personal.thePlayer.tasks.contains(tasks.divertPower) && powerDivertedArray[powerDivertedArrayIndex] == "Navigation" && powerDiverted{
            return true
        }
        if task == "shieldsAcceptDivertedPower" && personal.thePlayer.tasks.contains(tasks.divertPower) && powerDivertedArray[powerDivertedArrayIndex] == "Shields" && powerDiverted{
            return true
        }
        if task == "o2AcceptDivertedPower" && personal.thePlayer.tasks.contains(tasks.divertPower) && powerDivertedArray[powerDivertedArrayIndex] == "O2" && powerDiverted{
            return true
        }
        if task == "commsAcceptDivertedPower" && personal.thePlayer.tasks.contains(tasks.divertPower) && powerDivertedArray[powerDivertedArrayIndex] == "Communication" && powerDiverted{
            return true
        }
        if task == "lowerEngineAlgin" && personal.thePlayer.tasks.contains(tasks.alignEngine) && alignedEngine && !alignDone{
            return true
        }
        if task == "upperEngineAlignEngine" && personal.thePlayer.tasks.contains(tasks.alignEngine) && !alignedEngine{
            return true
        }
        if task == "lowerEngineFuel" && engineTasks[engineIndex] == "Lower Engine" && personal.thePlayer.tasks.contains(tasks.fuelEngine){
            return true
        }
        if task == "upperEngineFuel" && engineTasks[engineIndex] == "Upper Engine" && personal.thePlayer.tasks.contains(tasks.fuelEngine) && !fueldEngines{
            return true
        }
        if task == "storageFuelEngine" && engineTasks[engineIndex] == "Storage" && personal.thePlayer.tasks.contains(tasks.fuelEngine){
            return true
        }
        if task == "divertPowerElectrical" && personal.thePlayer.tasks.contains(tasks.divertPower) && !powerDiverted{
            return true
        }
        return false
    }
    let taskTextures = ["upload": "uploadHighlited"]
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    //MARK: - Touches Began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var label = SKShapeNode(circleOfRadius: 40)
        var label2 = SKLabelNode(text: "")
        var labels = [SKLabelNode]()
        for child in self.camera!.children{
            if child.name == "label"{
                labels.append(child as! SKLabelNode)
            }
            if child.name == "taskBarBackground"{
                label = child as! SKShapeNode
            }else if child.name == "taskBarBackground2"{
                label2 = child as! SKLabelNode
            }
        }
        for touch in touches{
            let positionInScene = touch.location(in: self.camera!)
            let touchedNode = self.camera!.atPoint(positionInScene)
            print(touchedNode)
            if touchedNode.name != nil && touchedNode.name!.contains("taskBarBackground"){
                
                let move = SKAction.moveBy(x: dismissed ? 300 : -300, y: 0, duration: 0.75)
                if dismissed == true{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75){
                        self.dismissed.toggle()
                    }
                }else{
                    self.dismissed.toggle()
                }
                label.run(move)
                label2.run(move)
                for child in labels{
                    child.run(move)
                }
            }else if touchedNode.name != nil && touchedNode.name! == "useButton"{
                for node in self.children{
                    if node.name != nil && node.name!.contains("task") && node.alpha == 1 && node.userData!["task"] as! String == closestTask{
                        showTask(task: node.userData!["task"] as! String)
                    }
                }
            }else if touchedNode.name != nil && touchedNode.name! == "fuelButton"{
                print("Started")
                inTask = true
                stopUpdatingProgress = false
                
            }else if touchedNode.name != nil && touchedNode.name! == "acceptDivertSwitch"{
                touchedNode.run(SKAction.rotate(byAngle: CGFloat(90.0 * Double.pi / 180.0), duration: 0.4))
                self.camera!.childNode(withName: "acceptDivertMain2")!.alpha = 1
                inTask = false
                personal.thePlayer.tasksDone.append(tasks.divertPower)
                powerDivertedDone = true
                updateTasks()
                updateTaskBar()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    self.finishTask(objects: self.currentTaskObjects)
                }
            }
        }
    }
    var stopUpdatingProgress = false
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
            //if touchedNode.name != nil && touchedNode.name! == "fuelButton"{
                print("Stopped")
                stopUpdatingProgress = true
            //}
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Stopped")
        stopUpdatingProgress = true
    }
    var j = 0
    var inTask = false
    var exitHit = false
    var pastPos = CGPoint(x: 0, y: 0)
    
    //MARK: - Show Task
    func showTask(task: String){
        print("task: \(task)")
        if task == "lowerEngineAlgin" || task == "upperEngineAlignEngine"{
            let background = SKSpriteNode(imageNamed: "alignEngineBackground")
            background.position = CGPoint(x: -75, y: -500)
            self.camera!.addChild(background)
            background.zPosition = 60
            background.setScale(0.5)
            background.name = "alignBackground"
            background.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            
            let border = SKSpriteNode(imageNamed: "alignEngineFront")
            border.position = CGPoint(x: 0, y: -500)
            self.camera!.addChild(border)
            border.zPosition = 63
            border.setScale(0.5)
            border.name = "border"
            border.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            
            let line = SKSpriteNode(imageNamed: "alignEngineLine")
            line.position = CGPoint(x:-75, y: -500)
            self.camera!.addChild(line)
            line.zPosition = 62
            line.setScale(0.5)
            line.name = "line"
            line.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            
            let randomAmount = CGFloat(Double.random(in: -0.3665190935...0.593411928))
            
            let engine = SKSpriteNode(imageNamed: "alignEngineEngine")
            engine.position = CGPoint(x: 120, y: -500)
            self.camera!.addChild(engine)
            engine.zPosition = 61
            engine.anchorPoint = CGPoint(x: 1, y: 0.5)
            engine.zRotation = randomAmount
            engine.setScale(0.5)
            engine.name = "engine"
            engine.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            
            let arrow = SKSpriteNode(imageNamed: "alignEngineArrow")
            arrow.position = CGPoint(x: 600, y: -500)
            self.camera!.addChild(arrow)
            arrow.zPosition = 66
            arrow.anchorPoint = CGPoint(x: 1, y: 0.5)
            arrow.setScale(0.5)
            arrow.zRotation = randomAmount
            arrow.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            arrow.name = "arrow"
            
            print("Uh-Oh")
            panGesture = UIPanGestureRecognizer(target: self, action:(#selector(self.handleGesture(_:))))
            self.view!.addGestureRecognizer(panGesture)
            inTask = true
            taskType = "alignEngine\(task == "lowerEngineAlgin" ? "lower" : "upper")"
            currentTaskObjects = ["alignBackground", "border", "line", "engine", "arrow", "lines"]
        }
        else if task == "storageFuelEngine"{
            let background = SKSpriteNode(imageNamed: "FuelEngineMain")
            background.position = CGPoint(x: 0, y: -500)
            self.camera!.addChild(background)
            background.zPosition = 61
            background.setScale(0.6)
            background.name = "fuelMain"
            background.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            
            let button = SKSpriteNode(imageNamed: "fuelEngineButton")
            button.position = CGPoint(x: 210, y: -705)
            self.camera!.addChild(button)
            button.zPosition = 62
            button.setScale(0.6)
            button.name = "fuelButton"
            button.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            
            let blackPart = SKShapeNode(rect: CGRect(x: -270, y: -750, width: 300, height: 500))
            self.camera!.addChild(blackPart)
            blackPart.zPosition = 59
            blackPart.name = "blackPart"
            blackPart.strokeColor = UIColor.black
            blackPart.fillColor = UIColor.black
            blackPart.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            
            let yellowPart = SKShapeNode(rect: CGRect(x: -270, y: -750, width: 300, height: 0))
            self.camera!.addChild(yellowPart)
            yellowPart.zPosition = 60
            yellowPart.name = "yellowPart"
            yellowPart.strokeColor = UIColor.yellow
            yellowPart.fillColor = UIColor.yellow
            yellowPart.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            progressVar = 1
            inTask = true
            currentTaskObjects = ["fuelMain", "fuelButton", "blackPart", "yellowPart"]
        }else if task.contains("EngineFuel"){
            let background = SKSpriteNode(imageNamed: "refuelEnginePart2")
            background.position = CGPoint(x: 0, y: -500)
            self.camera!.addChild(background)
            background.zPosition = 61
            background.size = CGSize(width: 919, height: 816)
            background.setScale(0.65)
            background.name = "fuelMain"
            background.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            
            let button = SKSpriteNode(imageNamed: "fuelEngineButton")
            button.position = CGPoint(x: 230, y: -704)
            self.camera!.addChild(button)
            button.zPosition = 62
            button.setScale(0.6)
            button.name = "fuelButton"
            button.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            
            let blackPart = SKShapeNode(rect: CGRect(x: -270, y: -750, width: 300, height: 500))
            self.camera!.addChild(blackPart)
            blackPart.zPosition = 59
            blackPart.name = "blackPart"
            blackPart.strokeColor = UIColor.black
            blackPart.fillColor = UIColor.black
            blackPart.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            
            let yellowPart = SKShapeNode(rect: CGRect(x: -270, y: -750, width: 300, height: 0))
            self.camera!.addChild(yellowPart)
            yellowPart.zPosition = 60
            yellowPart.name = "yellowPart"
            yellowPart.strokeColor = UIColor.yellow
            yellowPart.fillColor = UIColor.yellow
            yellowPart.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            
            progressVar = 1
            
            currentTaskObjects = ["fuelMain", "fuelButton", "blackPart", "yellowPart"]
        }
        else if task == "divertPowerElectrical"{
            currentTaskObjects = []
           // self.camera.child
            let background = SKSpriteNode(imageNamed: "divertPowerBase")
            background.position = CGPoint(x: 0, y: -500)
            self.camera!.addChild(background)
            background.zPosition = 60
            background.setScale(0.6)
            background.name = "divertMain"
            background.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            currentTaskObjects.append("divertMain")
            for n in 0..<8{
                let arrow = SKSpriteNode(imageNamed: "divertPowerArrow")
                arrow.position = CGPoint(x: -200 + n * 58, y: -650)
                self.camera!.addChild(arrow)
                arrow.zPosition = 61
                arrow.setScale(0.6)
                arrow.alpha = (n == powerDivertedArrayIndex) ? 1 : 0.7
                arrow.name = "arrow\(n)"
                currentTaskObjects.append("arrow\(n)")
                arrow.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            }
            taskType = "divertPower"
            panGesture = UIPanGestureRecognizer(target: self, action:(#selector(self.handleGesture(_:))))
            self.view!.addGestureRecognizer(panGesture)
            //inTask = true
        }else if task.contains("AcceptDivertedPower"){
            currentTaskObjects = ["acceptDivertMain","acceptDivertSwitch","acceptDivertMain2"]
            let background = SKSpriteNode(imageNamed: "divertPower2Base")
            background.position = CGPoint(x: 0, y: -500)
            self.camera!.addChild(background)
            background.zPosition = 60
            background.setScale(0.6)
            background.name = "acceptDivertMain"
            background.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            
            let background2 = SKSpriteNode(imageNamed: "divertPower2Base2")
            background2.position = CGPoint(x: 0, y: -500)
            self.camera!.addChild(background2)
            background2.zPosition = 61
            background2.alpha = 0
            background2.setScale(0.6)
            background2.name = "acceptDivertMain2"
            background2.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            
            let theSwitch = SKSpriteNode(imageNamed: "divertPower2Switch")
            theSwitch.position = CGPoint(x: 0, y: -500)
            self.camera!.addChild(theSwitch)
            theSwitch.zPosition = 62
            //theSwitch.alpha = 0
            theSwitch.setScale(0.6)
            theSwitch.name = "acceptDivertSwitch"
            theSwitch.run(SKAction.moveBy(x: 0, y: 500, duration: 0.5))
            //inTask = true
        }
        else if task.contains("wires"){
            var path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, 100, 100)
            CGPathAddLineToPoint(path, nil, 500, 500)
            let shape = SKShapeNode()
            shape.path = path
            shape.strokeColor = UIColor.whiteColor()
            shape.lineWidth = 2
            addChild(shape)
        }
    }
    var progressVar = 1
    func updateProgress(){
        self.camera!.childNode(withName: "yellowPart")!.removeFromParent()
        let yellowPart = SKShapeNode(rect: CGRect(x: -270, y: -250 , width: 300, height: 50 + progressVar * 2))
        self.camera!.addChild(yellowPart)
        yellowPart.zPosition = 60
        yellowPart.name = "yellowPart"
        yellowPart.strokeColor = UIColor.yellow
        //yellowPart.zRotation =  CGFloat(180.0 * Double.pi / 180.0)
        yellowPart.fillColor = UIColor.yellow
        //yellowPart.run(SKAction.moveBy(x: 0, y: 5, duration: 0.5))
        progressVar += 1
    }
    var panGesture = UIPanGestureRecognizer()
    var taskType = ""
    var preventRepeat = false
    @objc func handleGesture(_ sender: UIPanGestureRecognizer){
        let positionInScene = sender.location(in: self.camera!.inputView)
        print("Drag")
        if taskType.contains("alignEngine") && !preventRepeat{
            let touchedNode = self.camera!.childNode(withName: "arrow")!
            if pastPos.y < positionInScene.y{
                let temp = touchedNode.zRotation + CGFloat(1.0 * Double.pi / 180.0)
                if temp < 0.593411928 && temp > -0.3665190935{
                    touchedNode.zRotation = temp
                }
            }else{
                let temp = touchedNode.zRotation - CGFloat(1.0 * Double.pi / 180.0)
                if temp < 0.593411928 && temp > -0.3665190935{
                    touchedNode.zRotation = temp
                }
            }
            if sender.state == .ended{
                if touchedNode.zRotation < 0.10471975803375244 && touchedNode.zRotation > -0.05235987529158592{
                let line = SKSpriteNode(imageNamed: "alignEngineLines")
                line.position = CGPoint(x:-75, y: 0)
                self.camera!.addChild(line)
                line.zPosition = 64
                line.setScale(0.5)
                line.name = "lines"
                line.alpha = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25){
                    line.alpha = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    line.alpha = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75){ [self] in
                    line.alpha = 0
                    inTask = false
                    finishTask(objects: currentTaskObjects)
                    print("task: \(taskType)")
                    if alignedEngine && taskType.contains("lower"){
                        alignDone = true
                        personal.thePlayer.tasksDone.append(tasks.alignEngine)
                        updateTaskBar()
                    }else{
                        alignedEngine = true
                    }
                    
                    updateTasks()
                    canUse = false
                    taskType = ""
                }
                if let gestures = view!.gestureRecognizers {
                    for gesture in gestures {
                        if let recognizer = gesture as? UIPanGestureRecognizer {
                            view!.removeGestureRecognizer(recognizer)
                        }
                    }
                }
            }
            }
            self.camera!.childNode(withName: "engine")?.zRotation = touchedNode.zRotation - CGFloat(2.0 * Double.pi / 180.0)
            pastPos = positionInScene
        }
        else if taskType == "divertPower"{
            var touchedNode = self.camera!.childNode(withName: "arrow0")!
            for child in self.camera!.children{
                if child.name != nil && child.name!.contains("arrow") && child.alpha == 1{
                    touchedNode = child
                }
            }
            if pastPos.y < positionInScene.y{
                //if touchedNode.position.y < -70{
                    touchedNode.position.y -= 3
                //}
                //-80
                
            }else{
               // if touchedNode.position.y > -200{
                touchedNode.position.y += 3
                //-222
                //}
            }
            if touchedNode.position.y > -80{
                touchedNode.position.y = -80
            }
            if touchedNode.position.y < -222{
                touchedNode.position.y = -222
            }
            print(touchedNode.position.y)
            if sender.state == .ended{
                if touchedNode.position.y == -80{
                    inTask = false
                    finishTask(objects: currentTaskObjects)
                    print("task: \(taskType)")
                    powerDiverted = true
                    
                    updateTasks()
                    canUse = false
                    taskType = ""
                    if let gestures = view!.gestureRecognizers {
                        for gesture in gestures {
                            if let recognizer = gesture as? UIPanGestureRecognizer {
                                view!.removeGestureRecognizer(recognizer)
                            }
                        }
                    }
                }
                
            }
            pastPos = positionInScene
        }
    }
    var currentTaskObjects = [String]()
    func finishTask(objects: [String]){
        let moveOut = SKAction.moveBy(x: 0, y: -500, duration: 0.5)
        for child in self.camera!.children{
            for object in objects{
                if child.name != nil && child.name! == object{
                    self.camera!.childNode(withName: child.name!)!.run(moveOut)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                            child.removeFromParent()
                    }
                }
            }
        }
        let successLabel = SKLabelNode(text: "Task Completed!")
        successLabel.position = CGPoint(x: 0, y: 0)
        successLabel.fontName = "Arial"
        successLabel.fontSize = 40
        successLabel.zPosition = 70
        successLabel.fontColor = UIColor.white
        self.camera!.addChild(successLabel)
        successLabel.run(SKAction.fadeIn(withDuration: 0.25))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            successLabel.run(SKAction.moveBy(x: 0, y: -500, duration: 0.25))
        }
    }
    override func update(_ currentTime: TimeInterval) {
        if inTask{
            if !stopUpdatingProgress{
                updateProgress()
                print(progressVar)
                if progressVar >= (engineIndex == 0 || engineIndex == 2 ? 205 : 185){
                    inTask = false
                    finishTask(objects: currentTaskObjects)
                    if engineIndex < 3{
                        engineIndex += 1
                        
                    }else{
                        fueldEngines = true
                        personal.thePlayer.tasksDone.append(tasks.fuelEngine)
                        personal.thePlayer.tasksDone.append(tasks.fuelEngine)
                        updateTaskBar()
                    }
                    updateTasks()
                    canUse = false
                }
            }
        }
        for child in camera!.children{
            if child.name == "useButton"{
                child.alpha = canUse ? 1 : 0.5
            }
        }
        highlightCloseTasks()
        if personal.thePlayer.player.position.x > personal.thePlayer.pastPosition.x{
            personal.thePlayer.direction = directions.right
            i += 1
        }else if personal.thePlayer.player.position.x < personal.thePlayer.pastPosition.x{
            personal.thePlayer.direction = directions.left
            i += 1
        }else{
            i = 24
            personal.thePlayer.direction = directions.none
        }
        personal.thePlayer.pastPosition = personal.thePlayer.player.position
        personal.thePlayer.name.position = personal.thePlayer.player.position
        personal.thePlayer.name.position.y += 80
        for player in otherPlayers{
            player.thePlayer.name.position = player.thePlayer.player.position
            player.thePlayer.name.position.y += 80
        }
        personal.updateMovement(num: i)
        cam.position = personal.thePlayer.player.position
        self.joystick.position = CGPoint(x: -self.size.width / 2 + 150, y:  -self.size.height / 2 + 250)
        j += 1
    }
}
