-- NOTES --
-- try to make a simple race
	--RP style? go into building to start a race, setup locations, money(entry fee, car, tuning, bets)
	--how to test during creating?
	--only 1 race per session? yes!
	--creator or racing - separate mod, so everyone can make their own? which one to start with?
    --
-- race creator? -creating races so it's not HARDCODED database sourced
	--race options (optionLOCK, population, min/max laps, starting grid)
	--placing coordinates, marker arrow pointing to next one (dynamic), last marker is finish, land-air-water?
	--placing props
	--special markers such as repair, A-B route, boost, specialability, etc
	--individual checkpoint settings (type, route, transform, wrongway notification?)
-- race mode -running the race, reading specs from database, 
	--SETUP: opctions (type, traffic, laps, class, custom cars, time, weather, camlock, etc)
		--SETUP2: preparing track, spawning props, etc
	--RACE: spawn in startgrid, countdown, checkpoint and lap detections, respawns, ghosting, despawn@finish
	    --@disconnect/leave despawn, falling in water despawn (toggle option?)
        --wrong way text if going opposite direction, toggle option?

--useful stuff
--wiki stuff: https://wiki.gtanet.work/index.php?title=Main_Page
--All the stuff: https://wiki.gtanet.work/index.php?title=Scripting_Resources
--Marker types: https://wiki.gtanet.work/index.php?title=Marker
--Blip types: https://wiki.gtanet.work/index.php?title=Blips


local table = {
	{x = 1,y = 1,z = 1},
	{x = 2,y = 2,z = 2},
	{x = 3,y = 3,z = 3}
}

-- Draw Markers -- 
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		for k in pairs(table) do
			-- Draw Marker Here --
			DrawMarker(1, table[k].x, table[k].y, table[k].z, 0, 0, 0, 0, 0, 0, 1.001, 1.0001, 0.5001, 0, 0, 255, 200, 0, 0, 0, 0)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		for k in pairs(table) do

			local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
			local dis = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, table[k].x, table[k].y, table[k].z)

			if dist <= 1.2 then
				if IsControlJustPressed(1, 51) then
                    pP = GetPlayerPed(-1)
					SetEntityCoords(pP, x, y, z)
				end
			end
		end
	end
end)