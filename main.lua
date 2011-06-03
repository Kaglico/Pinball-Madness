-- 
-- Abstract: Pinball Sample Project
-- A basic game of PInball using the physics engine
-- (This is easiest to play on iPad or other large devices)
-- 
-- Version: 1.0
--
-- Code By Edgar Miranda
-- Design By Cesar Miranda
-- 
-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--
--
--

system.activate( "multitouch" )
local physics = require( "physics" )
local spring = require("spring")
local pinballTableObjects = require("pinballtableobjects")
local gameAudio = require("gameaudio")

physics.start(true) -- pass in true so bodies do not sleep
--physics.setDrawMode ( "hybrid" )	 -- Uncomment if you want to see all the physics bodies
physics.setGravity(0, 9.8 * 2) 

-- Display settings (determine the bounding box of the visible playing screen)
local topLeft = {
	x = (display.contentWidth - display.viewableContentWidth) / 2, 
	y = (display.contentHeight - display.viewableContentHeight) / 2}
	
local bottomRight = {
	x = topLeft.x + display.viewableContentWidth, 
	y = topLeft.y + display.viewableContentHeight}
	
--Center position of visible playing screen 	
local center = (display.contentWidth/2)

-- Ball properties
local ballProp = {}
local ballRadius = 20

-- Game properties
local launchWidthBuffer = 5
local borderWidth = 25

--Scoring Properties
local scoreText
--Splash Properties
local splashGroup
local machineBackground 
local splashBackground


function main()
	
	--Setup splash screen
	
	local splashGroup = display.newGroup()
	
	--Splash Background
	local tableBackground = display.newImage("background.png")
	splashGroup:insert(tableBackground)
	local splashBackGround = display.newImage( "splashScreen.png")
	splashGroup:insert(splashBackGround)
	local splashButton = display.newImage("pinballStartButton.png")
	splashButton.x = center;  splashButton.y = 615;
	splashGroup:insert(splashButton)

	splashButton:addEventListener("touch", 
		function() 
			splashGroup:removeSelf()
			init()
		end)

	
	

end


function init()
	
	display.setStatusBar( display.HiddenStatusBar )

	 setUpBackground()
	
	 placeNewBall()

     setupCollisionObjects()

	 setUpBallCatcher()

	spring.init(display.contentWidth - borderWidth - ballRadius - launchWidthBuffer / 2, display.contentHeight - 25, 25, 200)
	
	pinballTableObjects.init(launchWidthBuffer, borderWidth, ballRadius, topLeft, bottomRight, incrementScore)
	
	 setUpControls()

	 setUpScoreBoard()
	
	 gameAudio.init()


end

function setUpBackground()

	local background = display.newImage( "background.png")
	local physicsData = (require "pinball").physicsData(scaleFactor)
	physics.addBody( background, "static", physicsData:get("pinballMachinePhysics") )

end
	
function setUpScoreBoard()
	
	local scoreBoardObject = display.newImage("scoreBoard.png")
	
	scoreBoardObject.x = (center + scoreBoardObject.contentWidth/2)
	
	scoreText = display.newText("000000000", display.contentWidth / 2 + 100, 0, native.systemFont, 30)
	
	scoreText:setTextColor(255, 255, 255)
end

function incrementScore(points)
	scoreText.text = tonumber(scoreText.text) + points
end

-- The left side of the screen will control the left flipper, the right side of the screen will control the right flipper
-- Press down on any part of the screen will cause the spring ot pull back
function setUpControls()
	
	--TODO: Add listeners for the flippers (after creating the actual flippers)
	
	local callSpring = function(event)
		if(event.phase == "began") then 
			spring.pullBack()
			 pinballTableObjects.flipLeftFlipper()
			 pinballTableObjects.flipRightFlipper() 
			 gameAudio.playFlipperSound()
		end
		if(event.phase == "ended") then 
			spring.shoot()
			gameAudio.playPlungerSound()
			pinballTableObjects.lowerLeftFlipper()
			pinballTableObjects.lowerRightFlipper()
		end
	end
	
	Runtime:addEventListener("touch", callSpring)
end



-- Creates a platform at the bottom of the game "catch" the fruit and remove it
function setUpBallCatcher()
	
	local platform = display.newRect( 0, 0, display.contentWidth * 4, 50)
	platform.x =  (display.contentWidth / 2)
	platform.y = display.contentHeight / 2 + display.contentHeight 
	physics.addBody(platform, "static")
	
	platform.collision = function(self, event)
	
		event.other:removeSelf()
		-- Need to use a timer to create a new ball, since you can not create new physics objects during a collision
		timer.performWithDelay(1, function(event) placeNewBall() end)
	end
	platform:addEventListener( "collision", platform)
end

function placeNewBall()
	local ball = display.newImage( "ball.png")
	ball.x = display.contentWidth - borderWidth - ballRadius - launchWidthBuffer / 2
	ball.y = display.contentHeight - display.contentHeight / 5
	physics.addBody( ball, "dynamic", {bounce = .6, friciton = .3, density = .3, radius = ballRadius})
	ball.angularDamping = .3
	ball.isBullet = true
end
function setupCollisionObjects()
	-- Toggles images on collision
	function onObjectCollision(self, event)
			self.onImg.isVisible = true
			gameAudio.playCollisionSound()
			incrementScore(103)
			--Toggles collision image to visible
			timer.performWithDelay(200, function() self.onImg.isVisible = false end, 1)
	end
	
	pinballTableObjects.initCollisionObjects()
	
	
end

main()