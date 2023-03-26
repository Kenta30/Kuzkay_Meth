local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
local started = false
local displayed = false
local progress = 0
local CurrentVehicle 
local pause = false
local selection = 0
local quality = 0

local LastCar

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

RegisterNetEvent('esx_methcar:stop')
AddEventHandler('esx_methcar:stop', function()
	started = false
	DisplayHelpText("~r~Készités abbahagyva...")
	FreezeEntityPosition(LastCar, false)
end)
RegisterNetEvent('esx_methcar:stopfreeze')
AddEventHandler('esx_methcar:stopfreeze', function(id)
	FreezeEntityPosition(id, false)
end)
RegisterNetEvent('esx_methcar:notify')
AddEventHandler('esx_methcar:notify', function(message)
	ESX.ShowNotification(message)
end)

RegisterNetEvent('esx_methcar:startprod')
AddEventHandler('esx_methcar:startprod', function()
	DisplayHelpText("~g~Elkészités folyamatban")
	started = true
	FreezeEntityPosition(CurrentVehicle,true)
	displayed = false
	print('Started Meth production')
	ESX.ShowNotification("~r~MMeth elkészités folyamatban")	
	SetPedIntoVehicle(PlayerPedId(), CurrentVehicle, 3)
	SetVehicleDoorOpen(CurrentVehicle, 2)
end)

RegisterNetEvent('esx_methcar:blowup')
AddEventHandler('esx_methcar:blowup', function(posx, posy, posz)
	AddExplosion(posx, posy, posz + 2,23, 20.0, true, false, 1.0, true)
	if not HasNamedPtfxAssetLoaded("core") then
		RequestNamedPtfxAsset("core")
		while not HasNamedPtfxAssetLoaded("core") do
			Citizen.Wait(1)
		end
	end
	SetPtfxAssetNextCall("core")
	local fire = StartParticleFxLoopedAtCoord("ent_ray_heli_aprtmnt_l_fire", posx, posy, posz-0.8 , 0.0, 0.0, 0.0, 0.8, false, false, false, false)
	Citizen.Wait(6000)
	StopParticleFxLooped(fire, 0)
	
end)


RegisterNetEvent('esx_methcar:smoke')
AddEventHandler('esx_methcar:smoke', function(posx, posy, posz, bool)

	if bool == 'a' then

		if not HasNamedPtfxAssetLoaded("core") then
			RequestNamedPtfxAsset("core")
			while not HasNamedPtfxAssetLoaded("core") do
				Citizen.Wait(1)
			end
		end
		SetPtfxAssetNextCall("core")
		local smoke = StartParticleFxLoopedAtCoord("exp_grd_flare", posx, posy, posz + 1.7, 0.0, 0.0, 0.0, 2.0, false, false, false, false)
		SetParticleFxLoopedAlpha(smoke, 0.8)
		SetParticleFxLoopedColour(smoke, 0.0, 0.0, 0.0, 0)
		Citizen.Wait(22000)
		StopParticleFxLooped(smoke, 0)
	else
		StopParticleFxLooped(smoke, 0)
	end

end)
RegisterNetEvent('esx_methcar:drugged')
AddEventHandler('esx_methcar:drugged', function()
	SetTimecycleModifier("drug_drive_blend01")
	SetPedMotionBlur(PlayerPedId(), true)
	SetPedMovementClipset(PlayerPedId(), "MOVE_M@DRUNK@SLIGHTLYDRUNK", true)
	SetPedIsDrunk(PlayerPedId(), true)

	Citizen.Wait(300000)
	ClearTimecycleModifier()
end)



CreateThread(function()
	while true do
		local sleep = 2500
		local playerPed = PlayerPedId()
		local pos = GetEntityCoords(playerPed)
		if IsPedInAnyVehicle(playerPed) then
			
			
			CurrentVehicle = GetVehiclePedIsUsing(playerPed)

			car = GetVehiclePedIsIn(playerPed, false)
			LastCar = GetVehiclePedIsUsing(playerPed)
	
			local model = GetEntityModel(CurrentVehicle)
			local modelName = GetDisplayNameFromVehicleModel(model)
			
			if modelName == 'JOURNEY' and car then
				        sleep = 3
					if GetPedInVehicleSeat(car, -1) == playerPed then
						if started == false then
							if displayed == false then
								DisplayHelpText("Nyomj ~INPUT_THROW_GRENADE~ gombot a ~b~Meth~s~ készítéséhez")
								displayed = true
							end
						end
						if IsControlJustReleased(0, Keys['G']) then
							if pos.y >= 3500 then
								if IsVehicleSeatFree(CurrentVehicle, 3) then
									TriggerServerEvent('esx_methcar:start')	
									progress = 0
									pause = false
									selection = 0
									quality = 0
									
								else
									DisplayHelpText('~r~Az auto már használatban van')
								end
							else
								ESX.ShowNotification('~r~Túl közel vagy a városhoz, menj el távolabb')
							end
							
							
							
							
		
						end
					end
					
				
				
			
			end
			
		else

				
				if started then
					started = false
					displayed = false
					TriggerEvent('esx_methcar:stop')
					print('Stopped making drugs')
					FreezeEntityPosition(LastCar,false)
				end
		end
		
		if started == true then
			
			if progress < 96 then
				Citizen.Wait(6000)
				if not pause and IsPedInAnyVehicle(playerPed) then
					progress = progress +  1
					ESX.ShowNotification('~r~Meth Készítés: ~g~~h~' .. progress .. '%')
					Citizen.Wait(6000) 
				end

				--
				--   EVENT 1
				--
				if progress > 22 and progress < 24 then
					pause = true
					if selection == 0 then
					pause = true
						ESX.ShowNotification('~o~A propán tank elkezd szivárogni, mit teszel?')	
						ESX.ShowNotification('~o~1. Leragasztom Szigetelö Szallaggal')
						ESX.ShowNotification('~o~2. Nem csinálok semmit ')
						ESX.ShowNotification('~o~3. Kicserélem a propán tankot')
						ESX.ShowNotification('~c~Nyomd meg azt a lehetöséget, amit te tennél')
					end
					if selection == 1 then
						print("Slected 1")
						ESX.ShowNotification('~r~A leragasztással megakadályoztad a szivárgást')
						quality = quality - 1
						pause = false
					end
					if selection == 2 then
						print("Slected 2")
						ESX.ShowNotification('~r~Felrobbant a propán tank, meghaltál...')
						TriggerServerEvent('esx_methcar:blow', pos.x, pos.y, pos.z)
						SetVehicleEngineHealth(CurrentVehicle, 0.0)
						quality = 0
						started = false
						displayed = false
						ApplyDamageToPed(PlayerPedId(), 10, false)
						print('Stopped making drugs')
					end
					if selection == 3 then
						print("Selected 3")
						ESX.ShowNotification('~r~Szép munka, a legjobb lehetöséget választottad!')
						pause = false
						quality = quality + 5
					end
				end
				--
				--   EVENT 5
				--
				if progress > 30 and progress < 32 then
					pause = true
					if selection == 0 then
					pause = true
						ESX.ShowNotification('~o~Kilöttyintettél egy kis acetont a földre, mit teszel?')	
						ESX.ShowNotification('~o~1. Kinyitom az ablakot, hogy kiszálljon a szag')
						ESX.ShowNotification('~o~2. Nem csinálok semmit')
						ESX.ShowNotification('~o~3. Felveszek egy oxygén maszkot')
						ESX.ShowNotification('~c~Nyomd meg azt a lehetöséget, amit te tennél')
					end
					if selection == 1 then
						print("Slected 1")
						ESX.ShowNotification('~r~Kinyittotad az ablakot és kiment a szag')
						quality = quality - 1
						pause = false
					end
					if selection == 2 then
						print("Slected 2")
						ESX.ShowNotification('~r~Tul sok acetont lélegeztél be')
						pause = false
						TriggerEvent('esx_methcar:drugged')
					end
					if selection == 3 then
						print("Slected 3")
						ESX.ShowNotification('~r~Ez a legegyszerübb modja hogy megoldodjon a probléma')
						SetPedPropIndex(playerPed, 1, 26, 7, true)
						pause = false
					end
				end
				--
				--   EVENT 2
				--
				if progress > 38 and progress < 40 then
					pause = true
					if selection == 0 then
					pause = true
						ESX.ShowNotification('~o~Tul gyorsan megszilárdul a meth, mit csinálsz? ')	
						ESX.ShowNotification('~o~1. Felemelem a nyomást')
						ESX.ShowNotification('~o~2. Emelem a hömérsékletet')
						ESX.ShowNotification('~o~3. Csökkentem a nyomást')
						ESX.ShowNotification('~c~Nyomd meg azt a lehetöséget, amit te tennél')
					end
					if selection == 1 then
						print("Slected 1")
						ESX.ShowNotification('~r~Fokoztad a nyomást, és a propán elkezdett lehülni már minden rendben van')
						pause = false
					end
					if selection == 2 then
						print("Slected 2")
						ESX.ShowNotification('~r~Hömérséklet csökkentése segitett...')
						quality = quality + 5
						pause = false
					end
					if selection == 3 then
						print("Slected 3")
						ESX.ShowNotification('~r~Nem jol döntöttél...')
						pause = false
						quality = quality -4
					end
				end
				--
				--   EVENT 8 - 3
				--
				if progress > 41 and progress < 43 then
					pause = true
					if selection == 0 then
					pause = true
						ESX.ShowNotification('~o~Véletlenül tul sok acetont használtál, mit csinálsz?')	
						ESX.ShowNotification('~o~1. Semmit')
						ESX.ShowNotification('~o~2. Megprobálom fecskendövel kiszedni')
						ESX.ShowNotification('~o~3. Több lithiumot adok hozzá, ezzel kiegyensulyozva azt')
						ESX.ShowNotification('~c~Nyomd meg azt a lehetöséget, amit te tennél')
					end
					if selection == 1 then
						print("Slected 1")
						ESX.ShowNotification('~r~Egy kicsit aceton illate lett a meth-nek')
						quality = quality - 3
						pause = false
					end
					if selection == 2 then
						print("Slected 2")
						ESX.ShowNotification('~r~Olyan jol müködött, de még mindig tul sok')
						pause = false
						quality = quality - 1
					end
					if selection == 3 then
						print("Slected 3")
						ESX.ShowNotification('~r~Sikeresen kiegyensulyoztad a vegyületet')
						pause = false
						quality = quality + 3
					end
				end
				--
				--   EVENT 3
				--
				if progress > 46 and progress < 49 then
					pause = true
					if selection == 0 then
					pause = true
						ESX.ShowNotification('~o~Találtál néhány viz szinezéket, mit csinálsz?')	
						ESX.ShowNotification('~o~1. Hozzáadom')
						ESX.ShowNotification('~o~2. Félre rakom')
						ESX.ShowNotification('~o~3. Megiszom')
						ESX.ShowNotification('~c~Nyomd meg azt a lehetöséget, amit te tennél')
					end
					if selection == 1 then
						print("Slected 1")
						ESX.ShowNotification('~r~Jo ötlet, az emberek szeretik a szines dolgokat')
						quality = quality + 4
						pause = false
					end
					if selection == 2 then
						print("Slected 2")
						ESX.ShowNotification('~r~Igaz, elrontaná a meth izét')
						pause = false
					end
					if selection == 3 then
						print("Slected 3")
						ESX.ShowNotification('~r~Kezded kicsit furán érezni magadat')
						pause = false
					end
				end
				--
				--   EVENT 4
				--
				if progress > 55 and progress < 58 then
					pause = true
					if selection == 0 then
					pause = true
						ESX.ShowNotification('~o~A szürö eldugult, mit csinálsz?')	
						ESX.ShowNotification('~o~1. Megtisztitom süritett levegövel')
						ESX.ShowNotification('~o~2. Kicserélem a szüröt')
						ESX.ShowNotification('~o~3. Megtisztitom egy ecset segitségével')
						ESX.ShowNotification('~c~Nyomd meg azt a lehetöséget, amit te tennél')
					end
					if selection == 1 then
						print("Slected 1")
						ESX.ShowNotification('~r~A süritett levegö elrontotta a meth minöségét')
						quality = quality - 2
						pause = false
					end
					if selection == 2 then
						print("Slected 2")
						ESX.ShowNotification('~r~Ez a legjobb lehetöség')
						pause = false
						quality = quality + 3
					end
					if selection == 3 then
						print("Slected 3")
						ESX.ShowNotification('~r~Müködik, de egy kicsit koszos maradt')
						pause = false
						quality = quality - 1
					end
				end
				--
				--   EVENT 5
				--
				if progress > 58 and progress < 60 then
					pause = true
					if selection == 0 then
					pause = true
						ESX.ShowNotification('~o~Kilöttyintettél egy kis acetont a földre, mit teszel?')	
						ESX.ShowNotification('~o~1. Kinyitom az ablakot, hogy kiszálljon a szag')
						ESX.ShowNotification('~o~2. Nem csinálok semmit')
						ESX.ShowNotification('~o~3. Felveszek egy oxygén maszkot')
						ESX.ShowNotification('~c~Nyomd meg azt a lehetöséget, amit te tennél')
					end
					if selection == 1 then
						print("Slected 1")
						ESX.ShowNotification('~r~Kinyittotad az ablakot és kiment a szag')
						quality = quality - 1
						pause = false
					end
					if selection == 2 then
						print("Slected 2")
						ESX.ShowNotification('~r~Tul sok acetont lélegeztél be')
						pause = false
						TriggerEvent('esx_methcar:drugged')
					end
					if selection == 3 then
						print("Slected 3")
						ESX.ShowNotification('~r~Ez a legegyszerübb modja hogy megoldodjon a probléma')
						SetPedPropIndex(playerPed, 1, 26, 7, true)
						pause = false
					end
				end
				--
				--   EVENT 1 - 6
				--
				if progress > 63 and progress < 65 then
					pause = true
					if selection == 0 then
					pause = true
						ESX.ShowNotification('~o~A propán tank elkezd szivárogni, mit teszel?')	
						ESX.ShowNotification('~o~1. Leragasztom Szigetelö Szallaggal')
						ESX.ShowNotification('~o~2. Nem csinálok semmit ')
						ESX.ShowNotification('~o~3. Kicserélem a propán tankot')
						ESX.ShowNotification('~c~Nyomd meg azt a lehetöséget, amit te tennél')
					end
					if selection == 1 then
						print("Slected 1")
						ESX.ShowNotification('~r~A leragasztással megakadályoztad a szivárgást')
						quality = quality - 3
						pause = false
					end
					if selection == 2 then
						print("Slected 2")
						ESX.ShowNotification('~r~Felrobbant a propán tank, meghaltál...')
						TriggerServerEvent('esx_methcar:blow', pos.x, pos.y, pos.z)
						SetVehicleEngineHealth(CurrentVehicle, 0.0)
						quality = 0
						started = false
						displayed = false
						ApplyDamageToPed(PlayerPedId(), 10, false)
						print('Stopped making drugs')
					end
					if selection == 3 then
						print("Slected 3")
						ESX.ShowNotification('~r~Szép munka, a legjobb lehetöséget választottad!')
						pause = false
						quality = quality + 5
					end
				end
				--
				--   EVENT 4 - 7
				--
				if progress > 71 and progress < 73 then
					pause = true
					if selection == 0 then
					pause = true
						ESX.ShowNotification('~o~A szürö eldugult, mit csinálsz?')	
						ESX.ShowNotification('~o~1. Megtisztitom süritett levegövel')
						ESX.ShowNotification('~o~2. Kicserélem a szüröt')
						ESX.ShowNotification('~o~3. Megtisztitom egy ecset segitségével')
						ESX.ShowNotification('~c~Nyomd meg azt a lehetöséget, amit te tennél')
					end
					if selection == 1 then
						print("Slected 1")
						ESX.ShowNotification('~r~A süritett levegö elrontotta a meth minöségét')
						quality = quality - 2
						pause = false
					end
					if selection == 2 then
						print("Slected 2")
						ESX.ShowNotification('~r~Ez a legjobb lehetöség')
						pause = false
						quality = quality + 3
					end
					if selection == 3 then
						print("Slected 3")
						ESX.ShowNotification('~r~Müködik, de egy kicsit koszos maradt')
						pause = false
						quality = quality - 1
					end
				end
				--
				--   EVENT 8
				--
				if progress > 76 and progress < 78 then
					pause = true
					if selection == 0 then
					pause = true
						ESX.ShowNotification('~o~Véletlenül tul sok acetont használtál, mit csinálsz?')	
						ESX.ShowNotification('~o~1. Semmit')
						ESX.ShowNotification('~o~2. Megprobálom fecskendövel kiszedni')
						ESX.ShowNotification('~o~3. Több lithiumot adok hozzá, ezzel kiegyensulyozva azt')
						ESX.ShowNotification('~c~Nyomd meg azt a lehetöséget, amit te tennél')
					end
					if selection == 1 then
						print("Slected 1")
						ESX.ShowNotification('~r~Egy kicsit aceton illate lett a meth-nek')
						quality = quality - 3
						pause = false
					end
					if selection == 2 then
						print("Slected 2")
						ESX.ShowNotification('~r~Olyan jol müködött, de még mindig tul sok')
						pause = false
						quality = quality - 1
					end
					if selection == 3 then
						print("Slected 3")
						ESX.ShowNotification('~r~Sikeresen kiegyensulyoztad a vegyületet')
						pause = false
						quality = quality + 3
					end
				end
				--
				--   EVENT 9
				--
				if progress > 82 and progress < 84 then
					pause = true
					if selection == 0 then
					pause = true
						ESX.ShowNotification('~o~Rádjött a szarás, mit teszel?')	
						ESX.ShowNotification('~o~1. Megprobálom visszatartani')
						ESX.ShowNotification('~o~2. Kimegyek, és szarok')
						ESX.ShowNotification('~o~3. Beszarok a kocsiba')
						ESX.ShowNotification('~c~Nyomd meg azt a lehetöséget, amit te tennél')
					end
					if selection == 1 then
						print("Slected 1")
						ESX.ShowNotification('~r~Szép munka, elsö a meth fözés, utánna szarhatsz')
						quality = quality + 1
						pause = false
					end
					if selection == 2 then
						print("Slected 2")
						ESX.ShowNotification('~r~Amig te kint szartál, a kocsiban felborult az asztal és kiborult minde a földre...')
						pause = false
						quality = quality - 2
					end
					if selection == 3 then
						print("Slected 3")
						ESX.ShowNotification('~r~A levegö szar szagu lett')
						pause = false
						quality = quality - 1
					end
				end
				--
				--   EVENT 10
				--
				if progress > 88 and progress < 90 then
					pause = true
					if selection == 0 then
					pause = true
						ESX.ShowNotification('~o~Adjak hozzá a methez több üvegszilánkot, hogy többnek tünjön?')	
						ESX.ShowNotification('~o~1. Igen!')
						ESX.ShowNotification('~o~2. Nem')
						ESX.ShowNotification('~o~3. Mi lenne ha inkább methet adnék az üveghez?')
						ESX.ShowNotification('~c~Nyomd meg azt a lehetöséget, amit te tennél')
					end
					if selection == 1 then
						print("Slected 1")
						ESX.ShowNotification('~r~Kicsit több tasakot tudtál gyártani emiatt')
						quality = quality + 1
						pause = false
					end
					if selection == 2 then
						print("Slected 2")
						ESX.ShowNotification('~r~Te egy jó meth gyárto vagy, kiválló minöségü kokaint csináltál')
						pause = false
						quality = quality + 1
					end
					if selection == 3 then
						print("Slected 3")
						ESX.ShowNotification('~r~Ez egy kicsit tul sok, de nem probléma')
						pause = false
						quality = quality - 1
					end
				end
				
				if IsPedInAnyVehicle(playerPed) then
					TriggerServerEvent('esx_methcar:make', pos.x,pos.y,pos.z)
					if pause == false then
						selection = 0
						quality = quality + 1
						progress = progress +  math.random(1, 2)
						ESX.ShowNotification('~r~Meth Készítés: ~g~~h~' .. progress .. '%')
					end
				else
					TriggerEvent('esx_methcar:stop')
				end

			else
				TriggerEvent('esx_methcar:stop')
				progress = 100
				ESX.ShowNotification('~r~Meth Készítés: ~g~~h~' .. progress .. '%')
				ESX.ShowNotification('~g~~h~Befejezve')
				TriggerServerEvent('esx_methcar:finish', quality)
				FreezeEntityPosition(LastCar, false)
				started = false
				displayed = false
			end	
			
		end
		Wait(sleep)
	end
end)

CreateThread(function()
	while true do
		local sleep = 1000		
		if pause == true then
		sleep = 5
			if IsControlJustReleased(0, Keys['1']) then
				selection = 1
				ESX.ShowNotification('~g~Selected option number 1')
			end
			if IsControlJustReleased(0, Keys['2']) then
				selection = 2
				ESX.ShowNotification('~g~Selected option number 2')
			end
			if IsControlJustReleased(0, Keys['3']) then
				selection = 3
				ESX.ShowNotification('~g~Selected option number 3')
			end
		end
        Wait(sleep)
	end
end)
