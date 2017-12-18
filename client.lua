-- CONTENTS --
--[[ (to highlight occurences)
	NOTES
	TABLES
	FUNCTIONDEFINITIONS
	PREPARATIONS
	MAINCODE
]]

-- NOTES --
-- try to make a simple race
	--RP style? go into building to start a race, setup locations, money(entry fee, car, tuning, bets)
	--how to test during creating?
	--only 1 race per session? yes!
	--creator or racing - separate mod, so everyone can make their own? which one to start with? i think the race
	--need a menu system
	--need to clear all traffic-pedestrians-animals!
-- race creator? -creating races so it's not HARDCODED database sourced
	--race options (optionLOCK, population, min/max laps, starting grid)
	--placing coordinates, marker arrow pointing to next one (dynamic), last marker is finish, land-air-water?
	--placing props
	--special markers such as repair, A-B route, boost, specialability, etc
	--individual checkpoint settings (type, route, transform, wrongway notification?)
	--SAVE DATA: sql server?
-- race mode -running the race, reading specs from database, 
	--SETUP: opctions (type, traffic, laps, class, custom cars, time, weather, camlock, etc)
		--teleport to lobby area, invite players, select cars veh shop style
	--SETUP2: preparing track, spawning props, etc
		--adding blips to cars?
	--RACE: spawn in startgrid, countdown, checkpoint and lap detections, respawns, ghosting, despawn@finish
	    --@disconnect/leave despawn, falling in water despawn (toggle option?)
        --wrong way text if going opposite direction, toggle option?

--[[
	useful stuff
]]
--wiki stuff: https://wiki.gtanet.work/index.php?title=Main_Page
--All the stuff: https://wiki.gtanet.work/index.php?title=Scripting_Resources
--Marker types: https://wiki.gtanet.work/index.php?title=Marker
--Blip types: https://wiki.gtanet.work/index.php?title=Blips
--Controls: https://wiki.gtanet.work/index.php?title=Game_Controls
--vehicle shop by Arturs: https://forum.fivem.net/t/release-vehicle-shop-by-arturs/1783
--scaleform text: https://forum.fivem.net/t/how-to-use-scaleforms/49546?u=vespura&source_topic_id=50092

-- TABLES
--race start or creator marker: replayicon id:24 OR id: 1 and 4 = cylinder and flag
--need table for racestart=0 and racecreator=1 triggers
--marker coords = player coord-1
local racingTriggers = {
	{x = 1016.39, y = 176.954, z = 79.8558, type = "race"}, --next to racetrack at entrance
	{x = 1121.17, y = 249.434, z = 80.7056, type = "race"}, --only for debug
	{x = 2, y = 2, z = 2, type = "racecreator"},
}
-- lobby area to setup the race, get players to, select cars, etc
local lobbyArea = {x = 1121.17, y = 249.434, z = 80.7056}--next to racetrack in carpark, could be the big parking area nearby too

-- FUNCTIONDEFINITIONS

local fakecar = {model = '', car = nil} --for racecar selector

local function LocalPed()
	return GetPlayerPed(-1)
end

function drawTxt(text,font,centre,x,y,scale,r,g,b,a) --onscreen text
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x , y)	
end


function drawMenuButton(button,x,y,selected)
	local menu = vehshop.menu
	SetTextFont(menu.font)
	SetTextProportional(0)
	SetTextScale(menu.scale, menu.scale)
	if selected then
		SetTextColour(0, 0, 0, 255)
	else
		SetTextColour(255, 255, 255, 255)
	end
	SetTextCentre(0)
	SetTextEntry("STRING")
	AddTextComponentString(button.name)
	if selected then
		DrawRect(x,y,menu.width,menu.height,255,255,255,255)
	else
		DrawRect(x,y,menu.width,menu.height,0,0,0,150)
	end
	DrawText(x - menu.width/2 + 0.005, y - menu.height/2 + 0.0028)	
end

function drawMenuInfo(text)
	local menu = vehshop.menu
	SetTextFont(menu.font)
	SetTextProportional(0)
	SetTextScale(0.45, 0.45)
	SetTextColour(255, 255, 255, 255)
	SetTextCentre(0)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawRect(0.675, 0.95,0.65,0.050,0,0,0,150)
	DrawText(0.365, 0.934)	
end

function drawMenuRight(txt,x,y,selected)
	local menu = vehshop.menu
	SetTextFont(menu.font)
	SetTextProportional(0)
	SetTextScale(menu.scale, menu.scale)
	SetTextRightJustify(1)
	if selected then
		SetTextColour(0, 0, 0, 255)
	else
		SetTextColour(255, 255, 255, 255)
	end
	SetTextCentre(0)
	SetTextEntry("STRING")
	AddTextComponentString(txt)
	DrawText(x + menu.width/2 - 0.03, y - menu.height/2 + 0.0028)	
end

function drawMenuTitle(txt,x,y)
local menu = vehshop.menu
	SetTextFont(2)
	SetTextProportional(0)
	SetTextScale(0.5, 0.5)
	SetTextColour(255, 255, 255, 255)
	SetTextEntry("STRING")
	AddTextComponentString(txt)
	DrawRect(x,y,menu.width,menu.height,0,0,0,150)
	DrawText(x - menu.width/2 + 0.005, y - menu.height/2 + 0.0028)	
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
function Notify(text)
SetNotificationTextEntry('STRING')
AddTextComponentString(text)
DrawNotification(false, false)
end
local counter = '3'
function raceCountdown()
	while raceProgress == "startup" do
		Citizen.Wait(1000)	-- wait 1 sec to adjust text
		if counter == '1' then 
			counter ='GO'
			raceProgress = "started"
		end
		if counter == '2' then 
			counter ='1'
		end
		if counter == '3' then 
			counter ='2'
		end
	end			
end

-- PREPARATIONS
-- Draw Markers -- 
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		for k in pairs(racingTriggers) do
			-- Draw Marker Here --
			if racingTriggers[k].type == "race" then
				DrawMarker(1, racingTriggers[k].x, racingTriggers[k].y, racingTriggers[k].z, 0, 0, 0, 0, 0, 0, 1.001, 1.0001, 0.5001, 0, 0, 255, 200, 0, 0, 0, 0)
				--change color or add another marker into it
			end
			if racingTriggers[k].type == "racecreator" then
				DrawMarker(1, racingTriggers[k].x, racingTriggers[k].y, racingTriggers[k].z, 0, 0, 0, 0, 0, 0, 1.001, 1.0001, 0.5001, 0, 0, 255, 200, 0, 0, 0, 0)
			end
		end
	end
end)

-- Countdown test --

-- MAINCODE

local raceProgress = "none"
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		for k in pairs(racingTriggers) do --foreach marker in racingTriggers

			local plyCoords = GetEntityCoords(GetPlayerPed(-1), false) --get player coords
			local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, racingTriggers[k].x, racingTriggers[k].y, racingTriggers[k].z) --distance

			if dist <= 1.2 then --distance less than
				--drawTxt('Press E to begin',0,1,0.5,0.8,0.6,255,255,255,255)
				Citizen.CreateThread(function()
					function Initialize(scaleform)
						local scaleform = RequestScaleformMovie(scaleform)
				
						while not HasScaleformMovieLoaded(scaleform) do
							Citizen.Wait(0)
						end
						PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
						PushScaleformMovieFunctionParameterString("~r~WASTED")
						PushScaleformMovieFunctionParameterString("You commited suicide")
						PopScaleformMovieFunctionVoid()
						return scaleform
					end
					scaleform = Initialize("mp_big_message_freemode")
					while true do
						Citizen.Wait(0)
						DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
					end
				end)
				if IsControlJustPressed(1, 51) then --pressed CONTEXT button
                    pP = GetPlayerPed(-1) --get playerid
					SetEntityCoords(pP, lobbyArea.x, lobbyArea.y, lobbyArea.z) --teleport to lobby area
					raceProgress = "startup"
					counter = '3'
				end
			end
		end
		
		if raceProgress == "startup" then
			drawTxt(counter,0,1,0.5,0.8,0.6,255,255,255,255)
			raceCountdown()
			requestsc
		end

		if raceProgress == "started" then
			raceProgress = "none"
		end

	end
end)

