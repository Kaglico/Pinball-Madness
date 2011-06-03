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
-- Module for creating a spring found in pinball machines that shoots the ball into the main game

-- The Y coordinate we will set the spring so it launches the ball
local maxPullBackCoordY

local extraPullBack = 0

local spring
local anchor
local pullBackAnchor 
local pullBackJoint
--
function init(locationX, locationY, width, height)
	
	-- Anchor which the spring is attached too
	anchor = display.newRect( 0, 0, width, width)
	anchor.x = locationX
	anchor.y = locationY
	
	anchor.isVisible = false
	physics.addBody(anchor, "static", {bounce = 0})

	
	spring = display.newImage( "spring.png", 27, 200)
	spring.x = locationX
	spring.y = locationY
	spring.rotation = -10
	physics.addBody(spring, "dynamic", {density = 1, bounce = 0})
	spring.isBullet = true
	
	anchor.rotation = -10 
	-- Will be used in the "pullBack" function to pull down the spring
	pullBackAnchor = display.newRect( 0, 0, 25, 25)
	pullBackAnchor.x = spring.x
	pullBackAnchor.y = display.contentHeight + 300 -- position this object outside the screen
	physics.addBody(pullBackAnchor, "static", {bounce = 0})

	-- Create a piston joint so the spring can only move along the y axis
	pistontJoint = physics.newJoint( "piston", anchor, spring, anchor.x ,anchor.y, math.sin(spring.rotation  * -1 * (math.pi / 180)), math.cos(spring.rotation * -1 * (math.pi / 180)) ) 
	
	-- Create a distance joint to imitate the springy/bouncy feel
	distanceJoint = physics.newJoint( "distance", anchor, spring, anchor.x ,anchor.y, spring.x, spring.y)
	
	distanceJoint.frequency = 1
	distanceJoint.dampingRatio = 8 -- Need a high damping ratio so we have a really "tight" string

	-- Limit the distance the spring can move so it doesn't fall below the screen
	pistontJoint.isLimitEnabled = true
	pistontJoint:setLimits( -height / 4,  height / 2 - width / 2)
	
end


function pullBack()
	
	pullBackAnchor.y = spring.y + spring.height
	
	-- This joint is used in conjuction with the pullBackAnchor to pull back the spring
	pullBackJoint = physics.newJoint( "distance", pullBackAnchor, spring, pullBackAnchor.x ,pullBackAnchor.y, spring.x, spring.y + spring.height / 10)

	transition.to(pullBackAnchor, {time = 1000, y = pullBackAnchor.y + spring.height })	
end


function shoot()
	pullBackJoint:removeSelf()
end

