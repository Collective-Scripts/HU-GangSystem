local spawnedVehicles = {}

if GetResourceState('ox_lib') == 'started' then
	lib.locale()
end

function OpenVehicleSpawnerMenu(type, station, part, partNum)
	local playerCoords = GetEntityCoords(PlayerPedId())
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle', {
		title    = locale('garage_title'),
		align    = 'right',
		elements = {
			{label = locale('garage_storeditem'), action = 'garage'},
			{label = locale('garage_storeitem'), action = 'store_garage'},
			{label = locale('garage_buyitem'), action = 'buy_vehicle'}
	}}, function(data, menu)
		if data.current.action == 'buy_vehicle' then
			local shopElements = {}
			local shopCoords = Config.Gangs[station][part][partNum].InsideShop
			print(ESX.PlayerData.job.grade_name)
			local authorizedVehicles = Config.AuthorizedGangVehicles[station][ESX.PlayerData.job.grade_name]

			if authorizedVehicles then
				if #authorizedVehicles > 0 then
					for k,vehicle in ipairs(authorizedVehicles) do
						if IsModelInCdimage(vehicle.model) then
							local vehicleLabel = GetLabelText(GetDisplayNameFromVehicleModel(vehicle.model))

							table.insert(shopElements, {
								label = ('%s - <span style="color:green;">%s</span>'):format(vehicleLabel, locale('shop_item', ESX.Math.GroupDigits(vehicle.price))),
								name  = vehicleLabel,
								model = vehicle.model,
								price = vehicle.price,
								props = vehicle.props,
								station = station
							})
						end
					end

					if #shopElements > 0 then
						OpenShopMenu(shopElements, playerCoords, shopCoords)
					else
						CollectiveC.Notification(3, locale('garage_notauthorized'))
					end
				else
					CollectiveC.Notification(3, locale('garage_notauthorized'))
				end
			else
				CollectiveC.Notification(3, locale('garage_notauthorized'))
			end
		elseif data.current.action == 'garage' then
			local garage = {}

			ESX.TriggerServerCallback('esx_vehicleshop:retrieveJobVehicles', function(jobVehicles)
				if #jobVehicles > 0 then
					local allVehicleProps = {}

					for k,v in ipairs(jobVehicles) do
						local props = json.decode(v.vehicle)

						if IsModelInCdimage(props.model) then
							local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
							local label = ('%s - <span style="color:darkgoldenrod;">%s</span>: '):format(vehicleName, props.plate)

							if v.stored then
								label = label .. ('<span style="color:green;">%s</span>'):format(locale('garage_stored'))
							else
								label = label .. ('<span style="color:darkred;">%s</span>'):format(locale('garage_notstored'))
							end

							table.insert(garage, {
								label = label,
								stored = v.stored,
								model = props.model,
								plate = props.plate
							})

							allVehicleProps[props.plate] = props
						end
					end

					if #garage > 0 then
						ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_garage', {
							title    = locale('garage_title'),
							align    = 'right',
							elements = garage
						}, function(data2, menu2)
							if data2.current.stored then
								local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(station, part, partNum)

								if foundSpawn then
									menu2.close()

									ESX.Game.SpawnVehicle(data2.current.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
										local vehicleProps = allVehicleProps[data2.current.plate]
										ESX.Game.SetVehicleProperties(vehicle, vehicleProps)

										TriggerServerEvent('esx_vehicleshop:setJobVehicleState', data2.current.plate, false)
										CollectiveC.Notification(1, locale('garage_released'))
									end)
								end
							else
								CollectiveC.Notification(3, locale('garage_notavailable'))
							end
						end, function(data2, menu2)
							menu2.close()
						end)
					else
						CollectiveC.Notification(3, locale('garage_empty'))
					end
				else
					CollectiveC.Notification(3, locale('garage_empty'))
				end
			end, 'car')
		elseif data.current.action == 'store_garage' then
			StoreNearbyVehicle(playerCoords)
		end
	end, function(data, menu)
		menu.close()
	end)
end

function StoreNearbyVehicle(playerCoords)
	local vehicles, vehiclePlates = ESX.Game.GetVehiclesInArea(playerCoords, 30.0), {}
	if #vehicles > 0 then
		for k,v in ipairs(vehicles) do
			if GetVehicleNumberOfPassengers(v) == 0 and IsVehicleSeatFree(v, -1) then
				table.insert(vehiclePlates, {
					vehicle = v,
					plate = ESX.Math.Trim(GetVehicleNumberPlateText(v))
				})
			end
		end
	else
		CollectiveC.Notification(3, locale('garage_store_nearby'))
		return
	end
	lib.callback('HU-GangSystem:storeNearbyVehicle', false, function(theValue)
		if theValue.isBool then
			local vehicleId = vehiclePlates[theValue.foundNum]
			local attempts = 0
			ESX.Game.DeleteVehicle(vehicleId.vehicle)
			IsBusy = true
			Citizen.CreateThread(function()
				while IsBusy do
					Citizen.Wait(0)
					drawLoadingText(locale('garage_storing'), 255, 255, 255, 255)
				end
			end)
			while DoesEntityExist(vehicleId.vehicle) do
				Citizen.Wait(500)
				attempts = attempts + 1
				if attempts > 30 then
					break
				end
				vehicles = ESX.Game.GetVehiclesInArea(playerCoords, 30.0)
				if #vehicles > 0 then
					for k,v in ipairs(vehicles) do
						if ESX.Math.Trim(GetVehicleNumberPlateText(v)) == vehicleId.plate then
							ESX.Game.DeleteVehicle(v)
							break
						end
					end
				end
			end
			IsBusy = false
			CollectiveC.Notification(1, locale('garage_has_stored'))
		else
			CollectiveC.Notification(3, locale('garage_has_notstored'))
		end
	end, vehiclePlates)
end

function GetAvailableVehicleSpawnPoint(station, part, partNum)
	local spawnPoints = Config.Gangs[station][part][partNum].SpawnPoints
	local found, foundSpawnPoint = false, nil

	for i=1, #spawnPoints, 1 do
		if ESX.Game.IsSpawnPointClear(spawnPoints[i].coords, spawnPoints[i].radius) then
			found, foundSpawnPoint = true, spawnPoints[i]
			break
		end
	end

	if found then
		return true, foundSpawnPoint
	else
		CollectiveC.Notification(3, locale('vehicle_blocked'))
		return false
	end
end

function OpenShopMenu(elements, restoreCoords, shopCoords)
	local playerPed = PlayerPedId()
	isInShopMenu = true

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop', {
		title    = locale('vehicleshop_title'),
		align    = 'right',
		elements = elements
	}, function(data, menu)
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop_confirm', {
			title    = locale('vehicleshop_confirm', data.current.name, data.current.price),
			align    = 'right',
			elements = {
				{label = locale('confirm_no'), value = 'no'},
				{label = locale('confirm_yes'), value = 'yes'}
		}}, function(data2, menu2)
			if data2.current.value == 'yes' then
				local newPlate = exports['esx_vehicleshop']:GeneratePlate()
				local vehicle  = GetVehiclePedIsIn(playerPed, false)
				local props    = ESX.Game.GetVehicleProperties(vehicle)
				props.plate    = newPlate
				lib.callback('HU-GangSystem:buyJobVehicle', false, function(bought)
					if bought then
						CollectiveC.Notification(1, locale('vehicleshop_bought', data.current.name, ESX.Math.GroupDigits(data.current.price)))
						isInShopMenu = false
						ESX.UI.Menu.CloseAll()
						DeleteSpawnedVehicles()
						FreezeEntityPosition(playerPed, false)
						SetEntityVisible(playerPed, true)
						ESX.Game.Teleport(playerPed, restoreCoords)
					else
						CollectiveC.Notification(3, locale('vehicleshop_money'))
						menu2.close()
					end
				end, props, data.current.station)
			else
				menu2.close()
			end
		end, function(data2, menu2)
			menu2.close()
		end)
	end, function(data, menu)
		isInShopMenu = false
		ESX.UI.Menu.CloseAll()
		DeleteSpawnedVehicles()
		FreezeEntityPosition(playerPed, false)
		SetEntityVisible(playerPed, true)
		ESX.Game.Teleport(playerPed, restoreCoords)
	end, function(data, menu)
		DeleteSpawnedVehicles()
		WaitForVehicleToLoad(data.current.model)
		ESX.Game.SpawnLocalVehicle(data.current.model, shopCoords, 0.0, function(vehicle)
			table.insert(spawnedVehicles, vehicle)
			TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
			FreezeEntityPosition(vehicle, true)
			SetModelAsNoLongerNeeded(data.current.model)
			if data.current.props then
				ESX.Game.SetVehicleProperties(vehicle, data.current.props)
			end
		end)
	end)
	WaitForVehicleToLoad(elements[1].model)
	ESX.Game.SpawnLocalVehicle(elements[1].model, shopCoords, 0.0, function(vehicle)
		table.insert(spawnedVehicles, vehicle)
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		FreezeEntityPosition(vehicle, true)
		SetModelAsNoLongerNeeded(elements[1].model)
		if elements[1].props then
			ESX.Game.SetVehicleProperties(vehicle, elements[1].props)
		end
	end)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local sleep = true
		if isInShopMenu then
			sleep = false
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
		end
		if sleep then
			Citizen.Wait(500)
		end
	end
end)

function DeleteSpawnedVehicles()
	while #spawnedVehicles > 0 do
		local vehicle = spawnedVehicles[1]
		ESX.Game.DeleteVehicle(vehicle)
		table.remove(spawnedVehicles, 1)
	end
end

function WaitForVehicleToLoad(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		BeginTextCommandBusyspinnerOn('STRING')
		AddTextComponentSubstringPlayerName(locale('vehicleshop_awaiting_model'))
		EndTextCommandBusyspinnerOn(4)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(0)
			DisableAllControlActions(0)
		end

		BusyspinnerOff()
	end
end
