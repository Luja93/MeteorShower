-- Hides the status bar
display.setStatusBar(display.HiddenStatusBar)



--------------------------------------------------------------------------------------
-- Global contsts
--------------------------------------------------------------------------------------
Global = {
	screenHeight = display.viewableContentHeight,
	screenWidth  = display.viewableContentWidth, 
	extraX = math.abs(display.screenOriginX),
	extraY = math.abs(display.screenOriginY)
}
local totalScreenWidth = Global.screenWidth + 2*Global.extraX
local totalScreenHeight = Global.screenHeight + 2*Global.extraY
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------




--------------------------------------------------------------------------------------
-- Global requirements/implementations
-- Add new libraries here..
--------------------------------------------------------------------------------------
local json = require( "json" )
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------




--------------------------------------------------------------------------------------
-- Global definitions and setup (load strings res, database, fonts, audio, etc..)
--------------------------------------------------------------------------------------
local paint = {
			type = "gradient",
			color1 = { 9/255, 15/255, 15/255 },
			color2 = { 74/255, 116/255, 116/255 },
			direction = "down"
		}

bcg = display.newRect( Global.screenWidth*.5, Global.screenHeight*.5, totalScreenWidth, totalScreenHeight )
bcg.fill = paint
bcg:toBack()

-- Load meteor particles data
local meteorParticlesFilePath = system.pathForFile( "particles/meteor.json" )
local meteorFile = io.open( meteorParticlesFilePath, "r" )
local meteorParticlesFileData = meteorFile:read( "*a" )
meteorFile:close()
local meteorEmitterParams = json.decode(meteorParticlesFileData)

-- Load rain particles data
local rainParticlesFilePath = system.pathForFile( "particles/rain.json" )
local rainFile = io.open( rainParticlesFilePath, "r" )
local rainParticlesFileData = rainFile:read( "*a" )
rainFile:close()
local rainEmitterParams = json.decode(rainParticlesFileData)

-- Load cloud particles data
local cloudParticlesFilePath = system.pathForFile( "particles/cloud.json" )
local cloudFile = io.open( cloudParticlesFilePath, "r" )
local cloudParticlesFileData = cloudFile:read( "*a" )
cloudFile:close()
local cloudsEmitterParams = json.decode(cloudParticlesFileData)

local meteorsGroup = display.newGroup()
local cloudsGroup = display.newGroup()
local rainGroup = display.newGroup()
local thundersGroup = display.newGroup()
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------




--------------------------------------------------------------------------------------
-- (Particle) effects functions..
--------------------------------------------------------------------------------------
local function goMeteor()
	-- Shoots one meteor
	local emitter = display.newEmitter( meteorEmitterParams )
	emitter.x = Global.screenWidth*.75 + Global.extraX
	emitter.x = math.random(Global.screenWidth*.5, Global.screenWidth + Global.extraX)
	emitter.y = - Global.extraY
	emitter:rotate(-45)

	meteorsGroup:insert(emitter)

	transition.to(emitter, {x = emitter.x - totalScreenWidth, y = Global.screenHeight + Global.extraY + 200, time = 2800, onComplete = function()
		display.remove(emitter)
		emitter = nil
	end})
end

local function goRain()
	-- Creates rain over the whole screen
	local emitter = display.newEmitter( rainEmitterParams )
	emitter.x = Global.screenWidth*.5
	emitter.y = Global.screenHeight*.3 - Global.extraY

	rainGroup:insert(emitter)
end

local function goClouds()
	-- Emitts clouds to fill the entire screen width
	local i
	for i = 1, math.ceil(totalScreenWidth/200) do
		local emitter = display.newEmitter( cloudsEmitterParams )
		emitter.x = - 200 + (i-1)*200
		emitter.y = - Global.extraY + 50
		-- Use the group to destroy the emitters when exiting the scene
		cloudsGroup:insert(emitter)
	end
end

local function goThunder()
	-- Creates a thunder-flash effect
	local flash = display.newRect(Global.screenWidth*.5, Global.screenHeight*.5, totalScreenWidth, totalScreenHeight)
	flash.alpha = 0

	thundersGroup:insert(flash)

	transition.to(flash, {alpha = 1, time = 100})
	transition.to(flash, {alpha = 0, time = 100, delay = 100})
	transition.to(flash, {alpha = 1, time = 100, delay = 200})
	transition.to(flash, {alpha = 0, time = 100, delay = 300, onComplete = function()
		display.remove(flash)
		flash = nil
	end})
end
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------


local function startThunder()
	timer.performWithDelay(math.random(2500, 4000), goThunder, -1)
	cloudsGroup:toFront()
end

local function startRain()
	timer.performWithDelay(200, goRain, 1)
	cloudsGroup:toFront()
end

local function startMetheors()
	timer.performWithDelay(math.random(400, 800), goMeteor, 30)
	cloudsGroup:toFront()
end

goClouds()
timer.performWithDelay(1000, goThunder, 1)
timer.performWithDelay(1000, startThunder, 1)
timer.performWithDelay(1000, startRain)
timer.performWithDelay(2000, startMetheors, 1)




