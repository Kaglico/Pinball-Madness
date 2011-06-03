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

--Declare Collision Audio Properties
local flipperSound
local plungerSound
local collisionSound

--Declare Background Audio Properties 
local backgroundSound 

--Initialize audio
function init()
	
	--Load collision audio 
	collisionEffects()
	--Load Background audio
	backgroundMusic()

end

function collisionEffects()

	-- Assign collision audio effects to propeties
	flipperSound = audio.loadSound("flipper.wav")
	plungerSound = audio.loadSound("plunger.wav")
	collisionSound = audio.loadSound("ding1.wav")
	
	print("Collision audio has been initialzed")
end

-- Play Flipper Audio Effect 
function playFlipperSound()
	audio.play(flipperSound)
end
--Play Plunger Audio Effect
function playPlungerSound()
	audio.play(plungerSound)
end
--Play Collision Audio Effect
function playCollisionSound()
	timer.performWithDelay(300,
	function()
		audio.play(collisionSound)
	end
	,1)
end

function backgroundMusic()
	
	--Assign background audio to properties

end
