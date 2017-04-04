//
//  GameScene.swift
//  App_CiceBird
//
//  Created by Formador on 21/9/16.
//  Copyright (c) 2016 Formador. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    //MARK: - VARIBALES LOCALES
    //Un SpriteKit es un nodo que dibuja una imagen texturizada, tambien puede proporcionarnos un sombreado personalizado
    var background = SKSpriteNode()
    var bird = SKSpriteNode()
    var pipeFinal1 = SKSpriteNode()
    var pipeFinal2 = SKSpriteNode()
    var limitLand = SKNode()
    var timer = NSTimer()
    
    //grupos de colision
    let birdGroup : UInt32 = 1 // 1 << 0
    let objectsGroup : UInt32 = 2 // 1 << 1
    let gapGroup : UInt32 = 4 // 1 << 2
    var movingGroup = SKNode()
    
    //GRUPO LABELS
    var score = 0
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var gameOver = false
    
    
    //MARK: - LLAMADA CUANDO LA VISTA DE HA MODIFICADO
    override func didMoveToView(view: SKView) {
        //definimos quien es el delegado para tener en cuenta las colisiones
        self.physicsWorld.contactDelegate = self
        //aqui manipulo la gravedad
        self.physicsWorld.gravity = CGVectorMake(0, -5.0)
        
        //Añado el SuperGrupo de Movimiento
        self.addChild(movingGroup)
        
        makeLimitLand()
        makeBackground()
        makeLoopPipe1And2()
        makeBird()
        makeLabel()
    }
    
    //MARK: - TEST DE LOS CONTACTOS / COLISIONES
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == gapGroup || contact.bodyB.categoryBitMask == gapGroup{
            score += 1
            scoreLabel.text = "\(score)"
        }else if !gameOver{
            gameOver = true
            movingGroup.speed = 0
            timer.invalidate()
            makeLabelGameOver()
        }
    }
    
    //MARK: - LLAMADA CUANDO LOS TOQUES HAN COMENZADO
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !gameOver{
            //aqui realizamos un reset de la posicion de posicion y velocidad del pajaro
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            //le proporciono un pequeño impulso al pajaro
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 70))
        }else{
            resetGame()
        }
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    //MARK: - UTILS
    func makeLimitLand(){
        //le decimos que la linea de la posicion de la tierra es bajo a la izquierda
        limitLand.position = CGPointMake(0, 0)
        //asignamos las  fisicas
        limitLand.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        //si es dinamico o no
        limitLand.physicsBody?.dynamic = false
        
            //GRUPO DE COLISIONES
            limitLand.physicsBody?.categoryBitMask = objectsGroup
        
        //nos aseguramos de la posicion
        limitLand.zPosition = 3
        self.addChild(limitLand)
    }
    
    
    //MARK: - HACEMOS EL BACKGROUND
    func makeBackground(){
        //1. Creacion de texturas
        let backgroundFinal = SKTexture(imageNamed: "bg.png")
        //2. Dotamos de movimiento al Background
        let moveBackground = SKAction.moveByX(-backgroundFinal.size().width, y: 0, duration: 19)
        let replaceBackground = SKAction.moveByX(backgroundFinal.size().width, y: 0, duration: 0)
        let moveBackgroundForever = SKAction.repeatActionForever(SKAction.sequence([moveBackground, replaceBackground]))
        
        for indice in 0..<3{
            background = SKSpriteNode(texture: backgroundFinal)
            background.position = CGPoint(x: (backgroundFinal.size().width / 2) + (backgroundFinal.size().width * CGFloat(indice)), y: CGRectGetMidY(self.frame))
            //3. posicion abstracta
            background.zPosition = 1
            //4. Ajustamos la altura de manera proporcional al dispositivo
            background.size.height = self.frame.height
            //5. Ejecuto la accion
            background.runAction(moveBackgroundForever)
            self.movingGroup.addChild(background)
        }
    }
    
    
    //MARK: - HACEMOS LAS TUBERIAS
    func makePipesFinal(){
        //VARIABLES INTERNAS
        let gapHeight = bird.size.height * 4
        //Aqui le decimos cuanto nos vamos a mover una vez que salga una tuberia tabto para arriba como para abjo que quiero que me devuelve un numero enytre 0 y la mitad de la pantalla
        let movementAmount = arc4random_uniform(UInt32(self.frame.size.height / 2))
        //creamos el desplazamiento de la tuberia  que esta entre 0 y la mitad de la pantalla pero le resto 1/4 de esta
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4
        
        //movemos las tuberias
        let movePipes = SKAction.moveByX(-self.frame.width - 200 , y: 0, duration: NSTimeInterval(self.frame.width / 200))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        //1. creamos la textura Uno
        let pipeTexture1 = SKTexture(imageNamed: "pipe1.png")
        pipeFinal1 = SKSpriteNode(texture: pipeTexture1)
        pipeFinal1.position = CGPointMake(self.frame.width + 60, CGRectGetMidY(self.frame) + (pipeFinal1.size.height / 2) + (gapHeight / 2) + pipeOffset)
        pipeFinal1.physicsBody = SKPhysicsBody(rectangleOfSize: pipeFinal1.size)
        pipeFinal1.physicsBody?.dynamic = false
        
            //GRUPO DE COLISIONES
            pipeFinal1.physicsBody?.categoryBitMask = objectsGroup
        
        pipeFinal1.runAction(moveAndRemovePipes)
        pipeFinal1.zPosition = 5
        
        self.movingGroup.addChild(pipeFinal1)
        
        //1. creamos la textura Uno
        let pipeTexture2 = SKTexture(imageNamed: "pipe2.png")
        pipeFinal2 = SKSpriteNode(texture: pipeTexture2)
        pipeFinal2.position = CGPointMake(self.frame.width + 60, CGRectGetMidY(self.frame) - (pipeFinal1.size.height / 2) - (gapHeight / 2) + pipeOffset)
        pipeFinal2.physicsBody = SKPhysicsBody(rectangleOfSize: pipeFinal2.size)
        pipeFinal2.physicsBody?.dynamic = false
        
            //GRUPO DE COLISIONES
            pipeFinal2.physicsBody?.categoryBitMask = objectsGroup
        
        pipeFinal2.runAction(moveAndRemovePipes)
        pipeFinal2.zPosition = 5
        
        self.movingGroup.addChild(pipeFinal2)
        
        //GRUPO DE COLISION EN EL HUECO QUE ATRAVIESA EL PAJARO
        makeGapNode(pipeOffset, gapHeight: gapHeight, moveAndRemovePipes: moveAndRemovePipes)
    }
    
    //MARK: - HACEMOS EL GAPNODE DE COLISION Y SUMA DE PUNTOS
    func makeGapNode(pipeOffset : CGFloat, gapHeight : CGFloat, moveAndRemovePipes : SKAction){
        let gap = SKNode()
        gap.position = CGPointMake(self.frame.width + 60, CGRectGetMidY(self.frame) + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipeFinal1.size.width, gapHeight))
        gap.physicsBody?.dynamic = false
        gap.runAction(moveAndRemovePipes)
        gap.zPosition = 30
        gap.physicsBody?.categoryBitMask = gapGroup
        self.movingGroup.addChild(gap)
    }
    
    
    //MARK: - HACEMOS EL BICHO VOLANDO
    func makeBird(){
        //1. Creacion de texturas
        let birdTexture1 = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        //2. Accion (SKScene)
        let animationBird = SKAction.animateWithTextures([birdTexture1, birdTexture2], timePerFrame: 0.1)
        //3. Accion para siempre
        let makeBirdForever = SKAction.repeatActionForever(animationBird)
        //4. asigno la animacion a nuestro SKSpriteNode
        bird = SKSpriteNode(texture: birdTexture1)
        //5. Asignamos la posicion en el espacio
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        //6. Asignamos la altura (abstracto) de nivel  de 0 - 15
        bird.zPosition = 15
        //6.1 ejecuta la accion de moverse para siempre
        bird.runAction(makeBirdForever)
        
            //GRUPO DE FISICAS DEL BIRD
            //Aqui asignamos las fisica del pajaro que envuelve nuestro spriteKit
            bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2)
            /*bird.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed:"flappy1.png"), alphaThreshold: 0.5, size: CGSizeMake(bird.size.width, bird.size.height
                ))*/
            //Implemento la gravedad (-5.0m/s) ->
            bird.physicsBody?.dynamic = true
        
                //GRUPO DE COLISIONES
                bird.physicsBody?.categoryBitMask = birdGroup
                bird.physicsBody?.collisionBitMask = objectsGroup
                bird.physicsBody?.contactTestBitMask = objectsGroup | gapGroup
        
            //Desactivamos la rotacion del pajaro
            bird.physicsBody?.allowsRotation = false
        
        
        //7. Aqui lo añadimos a la escena
        self.addChild(bird)
    }
    
    
    //MARK: - HACEMOS EL LOOP DE LOS PIPES
    func makeLoopPipe1And2(){
        //Usamos un objeto que determine cada cuantos segundos debe crearse una tuberia
        timer = NSTimer.scheduledTimerWithTimeInterval(2,
                                                       target: self,
                                                       selector: #selector(GameScene.makePipesFinal),
                                                       userInfo: nil,
                                                       repeats: true)
    }
    
    //MARK: LABEL DE PUNTUACION
    func makeLabel(){
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(self.frame.midX, self.frame.height - 70)
        scoreLabel.zPosition = 16
        self.addChild(scoreLabel)
    }
    
    //MARK: - LABEL GAME OVER
    func makeLabelGameOver(){
        gameOverLabel.fontName = "Helvetica"
        gameOverLabel.fontSize = 30
        gameOverLabel.text = "GAME OVER :("
        gameOverLabel.position = CGPointMake(self.frame.midX, self.frame.midY)
        gameOverLabel.zPosition = 16
        self.addChild(gameOverLabel)
    }
    
    func resetGame(){
        score = 0
        scoreLabel.text = "0"
        movingGroup.removeAllChildren()
        makeBackground()
        makeLoopPipe1And2()
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bird.physicsBody?.velocity = CGVectorMake(0, 0)
        gameOverLabel.removeFromParent()
        movingGroup.speed = 1
        gameOver = false
    }
    
    
    
    
    
    
    
   
}















