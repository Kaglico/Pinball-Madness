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

module(..., package.seeall)
-- Module that instantiates all the pinball table objects

-- Display settings (determine the bounding box of the visible playing screen)
local topLeft
local bottomRight

-- Game properties
local launchWidthBuffer
local borderWidth
local ballRadius

--Audio Properties
local flipperSound
local plungerSound
local bumperSound
local objectSounds

-- Object properties
local centerX -- the center after taking into consideratoin the size of the ball slot
local tableObjectWidth -- Width of the area after subracting the width of the ball slot

-- Object dimensions
local topSquaresSize = 200
local ballCatcherSize = 200

-- Bumper prop
local bumperProp = {density = 1, bonce = 1, friction = .3}
local pointsPerBump = 25

-- Flippers
local leftFlipper, leftFlipperJoint
local rightFlipper, rightFlipperJoint 

local flipperFlipSpeed = 800 -- How fas the flipper shoots up
local flipperLowerSpeed = 400

local impulseStrength = 2 -- The impulse strength used for all the bumpers

local scaleFactor = 1

local scoreFunction

--

function init(pLaunchWidthBuffer, pBorderWidth, pBallRadius, pTopLeft, pBottomRight, pScoreFunction)
	
	launchWidthBuffer = pLaunchWidthBuffer
	borderWidth = pBorderWidth
	ballRadius = pBallRadius
	topLeft = pTopLeft
	bottomRight = pBottomRight
	scoreFunction = pScoreFunction


 	tableObjectWidth = display.contentWidth - launchWidthBuffer - borderWidth 
	centerX = tableObjectWidth / 2

	
	local leftCatcher, rightCatcher = setUpBottomBallCatchers()
	setUpFlippers(leftCatcher, rightCatcher, 90)
	

end

function setUpFlippers(leftCatcher, rightCatcher, length)
	
	local offSetY = 0 -- used to align the flipper
	local offSetX = 0
	
	local leftFlipper = getFlipper("left")		
	leftFlipper.x = leftCatcher.x + leftCatcher.width / 2 + leftFlipper.height / 2 - offSetX
	leftFlipper.y = leftCatcher.y + leftCatcher.height / 2 + offSetY
	leftFlipper.rotation = 0
	leftFlipper.isBullet = true

	leftFlipperJoint = physics.newJoint( "pivot", leftCatcher, leftFlipper, leftCatcher.x + leftCatcher.width / 2,leftCatcher.y + leftCatcher.height / 2 )
	
	leftFlipperJoint.isMotorEnabled = true
	leftFlipperJoint.maxMotorTorque  = 100000000

	-- Limit the flipper's rotation
	leftFlipperJoint.isLimitEnabled = true 
	leftFlipperJoint:setRotationLimits( -45, 0 )
	
	-- Right flipper

	rightFlipper = getFlipper("right")
	rightFlipper.x = rightCatcher.x - rightCatcher.width / 2 - rightFlipper.height / 2 + offSetX
	rightFlipper.y = rightCatcher.y + rightCatcher.height / 2 + offSetY 
	rightFlipper.rotation = 0
	
	rightFlipperJoint = physics.newJoint( "pivot", rightCatcher, rightFlipper, rightCatcher.x - rightCatcher.width / 2,rightCatcher.y + rightCatcher.height / 2 )
	
	rightFlipperJoint.isMotorEnabled = true
	rightFlipperJoint.maxMotorTorque  = 100000000

	-- Limit the flipper's rotation
	rightFlipperJoint.isLimitEnabled = true 
	rightFlipperJoint:setRotationLimits( 0, 45 )


end

function getFlipper(side)
	
	local flipper 
	if(side == "left") then
		-- Physics body data required from PhysicsEditor File
		local physicsData = (require "flipperleft").physicsData(scaleFactor)
		flipper = display.newImage("flipperleft.png")
		physics.addBody( flipper, physicsData:get("flipperleft"))

	else
		-- Physics body data required from PhysicsEditor File
		local physicsData = (require "flipperright").physicsData(scaleFactor)
		flipper = display.newImage("flipperright.png")
		physics.addBody( flipper, physicsData:get("flipperright"))
	end


	flipper.isBullet = true
	
	return flipper
end




function flipLeftFlipper()
	leftFlipperJoint.motorSpeed = -flipperFlipSpeed
end

function lowerLeftFlipper()
	leftFlipperJoint.motorSpeed = flipperLowerSpeed
end

function flipRightFlipper()
	rightFlipperJoint.motorSpeed = flipperFlipSpeed
end

function lowerRightFlipper()
	rightFlipperJoint.motorSpeed = -flipperLowerSpeed
end



function setUpBottomBallCatchers()
	-- Left triangel
	local leftCatcher = display.newRect(0,0, 25, 25)
	leftCatcher.x = borderWidth * 2 + launchWidthBuffer + leftCatcher.width / 2 + 170 -- 170 is used to offset the left flipper 
	leftCatcher.y = bottomRight.y - leftCatcher.height - 50 -- 50 is used to offset the right flipper
	leftCatcher.isVisible = false
	triangleShape = { -leftCatcher.width / 2, -leftCatcher.height / 2, leftCatcher.width / 2, leftCatcher.height / 2, -leftCatcher.width / 2, leftCatcher.height / 2, -leftCatcher.width / 2, -leftCatcher.height / 2}
	physics.addBody(leftCatcher, "static", {shape=triangleShape})
	
	-- Right triangel
	local rightCatcher = display.newRect(0,0, 25, 25)
	rightCatcher.x = tableObjectWidth -  rightCatcher.width / 2 - launchWidthBuffer - ballRadius -  borderWidth * 2 - 185 -- 185 offsets flipper position
	rightCatcher.y = bottomRight.y - rightCatcher.height - 48 -- 48 offsets flipper position
	rightCatcher.isVisible = false
	triangleShape = { rightCatcher.width / 2, -rightCatcher.height / 2, rightCatcher.width / 2, rightCatcher.height / 2, -rightCatcher.width / 2, rightCatcher.height / 2, rightCatcher.width / 2, -rightCatcher.height / 2}
	physics.addBody(rightCatcher, "static", {shape=triangleShape})
	
	return leftCatcher, rightCatcher
end

function initCollisionObjects()
	
	--Bumper 1
	local physicsData = (require "bumperOne").physicsData(scaleFactor)
	collisionObject1 = display.newImage("bumperOne.png", 350, 130, true)
	physics.addBody( collisionObject1, "kinematic", physicsData:get("bumperOne"))
	collisionObject1.onImg = display.newImage( "bumperOn.png", 280, 48, true)
	collisionObject1.onImg.isVisible = false
	collisionObject1.collision = onObjectCollision
	collisionObject1:addEventListener("collision", collisionObject1)
	--Bumper 2
	local physicsData = (require "bumperOne").physicsData(scaleFactor)
	collisionObject2 = display.newImage("bumperOne.png", 420, 250, true)
	physics.addBody( collisionObject2, "kinematic", physicsData:get("bumperOne"))
	collisionObject2.onImg = display.newImage( "bumperOn.png", 350, 166, true)
	collisionObject2.onImg.isVisible = false
	collisionObject2.collision = onObjectCollision
	collisionObject2:addEventListener("collision", collisionObject2)
	--Bumper 3
	local physicsData = (require "bumperOne").physicsData(scaleFactor)
	collisionObject3 = display.newImage("bumperOne.png", 300, 250, true)
	physics.addBody( collisionObject3, "kinematic", physicsData:get("bumperOne"))
	collisionObject3.onImg = display.newImage( "bumperOn.png", 230, 166, true)
	collisionObject3.onImg.isVisible = false
	collisionObject3.collision = onObjectCollision
	collisionObject3:addEventListener("collision", collisionObject3)
	--Bumper 4
	local physicsData = (require "bumperOne").physicsData(scaleFactor)
	collisionObject4 = display.newImage("bumperOne.png", 205, 20, true)
	physics.addBody( collisionObject4, "kinematic", physicsData:get("bumperOne"))
	collisionObject4.onImg = display.newImage( "bumperOn.png", 135, -62, true)
	collisionObject4.onImg.isVisible = false
	collisionObject4.collision = onObjectCollision
	collisionObject4:addEventListener("collision", collisionObject4)
	--Bumper 5
	local physicsData = (require "purpleBumper").physicsData(scaleFactor)
	collisionObject5 = display.newImage("purpleBumper.png", 140, 400, true)
	physics.addBody( collisionObject5, "kinematic", physicsData:get("purpleBumper"))
	collisionObject5.onImg = display.newImage( "purpleBumperOn.png", -25, 240, true)
	collisionObject5.onImg.isVisible = false
	collisionObject5.collision = onObjectCollision
	collisionObject5:addEventListener("collision", collisionObject5)
	
	
end



