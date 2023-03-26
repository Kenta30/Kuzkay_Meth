

RegisterServerEvent('esx_methcar:start')
AddEventHandler('esx_methcar:start', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if xPlayer.getInventoryItem('acetone').count >= 5 and xPlayer.getInventoryItem('lithium').count >= 2 and xPlayer.getInventoryItem('methlab').count >= 1 then
		if xPlayer.getInventoryItem('meth').count >= 30 then
				TriggerClientEvent('esx_methcar:notify', _source, "~h~Nem fér el nálad több ~b~Meth")
		else
			TriggerClientEvent('esx_methcar:startprod', _source)
			xPlayer.removeInventoryItem('acetone', 5)
			xPlayer.removeInventoryItem('lithium', 2)
		end

		
		
	else
		TriggerClientEvent('esx_methcar:notify', _source, "~r~Nincs elég hozzávalo hogy elkészitsd a ~b~Meth-et~s~!")

	end
	
end)
RegisterServerEvent('esx_methcar:stopf')
AddEventHandler('esx_methcar:stopf', function(id)
local _source = source
	local xPlayers = ESX.GetExtendedPlayers()
	--local xPlayer = ESX.GetPlayerFromId(_source)
	for _, xPlayer in pairs(xPlayers) do
		TriggerClientEvent('esx_methcar:stopfreeze', xPlayer.source, id)
	end
	
end)
RegisterServerEvent('esx_methcar:make')
AddEventHandler('esx_methcar:make', function(posx,posy,posz)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if xPlayer.getInventoryItem('methlab').count >= 1 then
	
		local Players = ESX.GetExtendedPlayers()
		for _, Player in pairs(Players) do
			TriggerClientEvent('esx_methcar:smoke', Player.source, posx, posy, posz, 'a') 
		end
		
	else
		TriggerClientEvent('esx_methcar:stop', _source)
	end
	
end)
RegisterServerEvent('esx_methcar:finish')
AddEventHandler('esx_methcar:finish', function(qualtiy)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	print(qualtiy)
	local rnd = math.random(-5, 5)
	xPlayer.addInventoryItem('meth', math.floor(qualtiy / 2) + rnd)
	
end)

RegisterServerEvent('esx_methcar:blow')
AddEventHandler('esx_methcar:blow', function(posx, posy, posz)
	local _source = source
	local Players = ESX.GetExtendedPlayers()
	local xPlayer = ESX.GetPlayerFromId(_source)
	for _, Player in pairs(Players) do
		TriggerClientEvent('esx_methcar:blowup', Player.source, posx, posy, posz)
	end
	xPlayer.removeInventoryItem('methlab', 1)
end)


