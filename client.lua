-- NOTES --
-- try to make a simple race
    --RP szerű? irodába menni, és onnan lehessen tervezni, indítás helyszínek, pénz(nevezés, autók, tuning)?
    --tesztelést hogyan lehet megoldani?
    --egyszerre csak 1 mehessen? igen!
    --építés vagy verseny - külön mod rá, hogy mindenki saját maga csinálhassa meg? melyik legyen előbb?
    --
-- race creator? -versenyek létrehozása, hogy ne database-t kelljen írni
    --opciók (optionLOCK, létszám, min/max körök, spawn rend)
    --koordináták lepakolása, marker nyíl a következőre mutasson (dinamikus!), utolsó marker finish
    --props
    --speckó markerek, repair, stb
-- race mode -verseny futtatása, táblákból kiolvasni az adatokat
    --SETUP: opciók (tipus, traffic, körök, class, custom autok, idő, időjárás, kameralock, )
    --RACE: spawn rendben, visszaszámlálás, checkpoint és kör figyelés, respawnok, ghosting, despawn@finish
        --@disconnect/leave despawn, vízbe esett despawn(kikapcsolható?)
        --wrong way, ha rossz irányba halad az ember - kikapcsolható legyen

--useful stuff
--wiki stuff: https://wiki.gtanet.work/index.php?title=Main_Page
--Minden cucc: https://wiki.gtanet.work/index.php?title=Scripting_Resources
--Marker = kék karika, trigger zone
--Marker types: https://wiki.gtanet.work/index.php?title=Marker
--Blip = térképen jelölő ikon
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