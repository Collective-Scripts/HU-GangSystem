local ox_inventory, GetCurrentResourceName = exports.ox_inventory, GetCurrentResourceName()
GlobalState.isGangTasksLoaded = false
local loaded, tasks, playerTasks = false, {}, {}

local TasksWH = GetConvar('server:gang:tasks', '')

if GetResourceState('ox_lib') == 'started' then
	lib.locale()
end

function getPriceFromHash(hashKey, jobGrade, station)
	local vehicles = Config.AuthorizedGangVehicles[station][jobGrade]
	local theReturnValue = 0
	for k, v in pairs(vehicles) do
		if v.model == hashKey then
			theReturnValue = v.price
		end
	end
	return theReturnValue
end

AddEventHandler('onResourceStart', function(resourceName)
	Citizen.Wait(1000)
	if GetCurrentResourceName == resourceName then
		for i=1, #Config.GangBossActions do
			local data = Config.GangBossActions[i]
			TriggerEvent('esx_society:registerSociety', data.Job, data.Job, data.SocietyFunds, data.SocietyFunds, data.SocietyFunds, {type = 'public'})
		end
	end
end)

AddEventHandler('onServerResourceStart', function(resourceName)
	if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName then
		for i=1, #Config.Stashes do
			local stash = Config.Stashes[i]
			ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, stash.owner, stash.jobs)
		end
	end
end)

RegisterServerEvent('HU-GangSystem:FetchGangTasks')
AddEventHandler('HU-GangSystem:FetchGangTasks', function()
    if not loaded then
        for i = 1, #Config.TaskZones do
            for j = 1, 20 do
                table.insert(tasks, {
                    id = j,
                    businessName = Config.TaskZones[i].GangName,
                    title = 'Gang Tasks ('..ESX.GetRandomString(8)..') #'..j,
                    deliveryid = j,
                    reward = math.random(Config.GangTaskMinReward, Config.GangTaskMaxReward),
                    assignedTo = 0,
                    assignedName = nil,
                    status = 'Unassigned'
                })
            end
            loaded = true
        end
        GlobalState.isGangTasksLoaded = true
    end
end)

RegisterServerEvent('HU-GangSystem:AssignGangTask')
AddEventHandler('HU-GangSystem:AssignGangTask', function(businessname, taskID, taskTitle, targetid)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(targetid)
    if xPlayer == nil then CollectiveS.Notification(src, 3, locale('gang_tasks_invalid_id')) return end
    local fullname = xPlayer.variables.firstName ..' '.. xPlayer.variables.lastName
    table.insert(playerTasks,{
        identifier = xPlayer.identifier,
        taskid = taskID,
        tasktitle = taskTitle,
        businessname = businessname,
    })
    for i = 1, #tasks do
        if  tasks[i].id == taskID then
            tasks[i].assignedTo = targetid
            tasks[i].assignedName = fullname
            tasks[i].status = 'Pending'
        end
    end        
    CollectiveS.Notification(targetid, 2, locale('gang_tasks_received_tasks'))
    CollectiveS.Notification(src, 2, locale('gang_tasks_assigned', fullname))
end)

RegisterServerEvent('HU-GangSystem:CancelGangTask')
AddEventHandler('HU-GangSystem:CancelGangTask', function(businessname, taskid)
    local cancelled = false
    for i = 1, #tasks do
        if tasks[i].id == taskid and tasks[i].businessName == businessname then
            if tasks[i].status == 'Pending' then
                tasks[i].assignedTo = 0
                tasks[i].assignedName = nil
                tasks[i].status = 'Unassigned'
                cancelled = true
            else
                cancelled = false
            end
        end
    end
    for k, v in pairs(playerTasks) do
        if v.businessname == businessname and v.taskid == taskid then
            table.remove(playerTasks, k)
        end
    end
    if cancelled then
        CollectiveS.Notification(source, 1, locale('gang_tasks_cancelled'))
    else
        CollectiveS.Notification(source, 3, locale('gang_tasks_cant_cancelled'))
    end
end)

RegisterServerEvent('HU-GangSystem:AcceptGangTask')
AddEventHandler('HU-GangSystem:AcceptGangTask', function(businessname, taskid)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local shouldAccept = false
    for i = 1, #tasks do
        if tasks[i].id == taskid and tasks[i].businessName == businessname then
            if tasks[i].status == 'Pending' then
                tasks[i].status = 'Accepted'
                shouldAccept = true
            elseif tasks[i].status == 'Accepted' then
                shouldAccept = false
            end
        end
    end
    if shouldAccept then
        TriggerClientEvent("HU-GangSystem:StartGangTask", src, businessname, taskid)
    else
        CollectiveS.Notification(source, 3, locale('gang_tasks_already'))
    end
end)

RegisterServerEvent('HU-GangSystem:CompleteGangTask')
AddEventHandler('HU-GangSystem:CompleteGangTask', function(businessname, taskid)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local payout = 0
    local reward = 0
    for i = 1, #tasks do
        if tasks[i].id == taskid and tasks[i].businessName == businessname then
            tasks[i].status = 'Completed'
            reward = tasks[i].reward
        end
    end
    for k, v in pairs(playerTasks) do
        if v.businessname == businessname and v.taskid == taskid then
            payout = v.taskpayout
        end
    end
    ox_inventory:AddItem(src, 'black_money', reward * 0.50)
    ESX.CreateLog('Gang Tasks - '..xPlayer.job.label, 'player '..xPlayer.name..' received '.. reward * 0.50 ..' money from Gang Task\n**Gang Task ID:** '..taskid..'\n**Gang Name:** '..xPlayer.job.label..'\n**Player Details:**\n```'..json.encode(GetPlayerIdentifiers(src))..'```', TasksWH) 
    CollectiveS.Notification(src, 1, locale('gang_tasks_received_money', ESX.Math.GroupDigits(reward * 0.50)))
	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..businessname, function(account)
        account.addMoney(reward * 0.50)
    end)
    for k, v in pairs(playerTasks) do
        if v.businessname == businessname and v.taskid == taskid then
            table.remove(playerTasks, k)
        end
    end
end)


lib.callback.register('HU-GangSystem:storeNearbyVehicle', function(source, nearbyVehicles)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local foundPlate, foundNum
	local theReturnValue = {isBool = false, foundNum = nil}
	for k,v in pairs(nearbyVehicles) do
		local result = MySQL.query.await('SELECT plate FROM owned_vehicles WHERE owner = ? AND plate = ? AND job = ?', {xPlayer.identifier, v.plate, xPlayer.job.name})
		if result[1] then
			foundPlate, foundNum = result[1].plate, k
			break
		end
	end
	if foundPlate then
		local affectedRows = MySQL.update.await('UPDATE owned_vehicles SET stored = true WHERE owner = ? AND plate = ? AND job = ?', {xPlayer.identifier, foundPlate, xPlayer.job.name})
		if affectedRows then
			theReturnValue = {isBool = true, foundNum = foundNum}
		end
	end
    return theReturnValue
end)


lib.callback.register('HU-GangSystem:buyJobVehicle', function(source, vehicleProps, station)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local price = getPriceFromHash(vehicleProps.model, xPlayer.job.grade_name, station)
	local theReturnValue = false
	if price == 0 then
		print(('HU-GangSystem: %s %s attempted to exploit the shop! (invalid vehicle model)'):format(xPlayer.name, xPlayer.identifier))
		cb(false)
	else
		if ox_inventory:Search(xPlayer.source, 'count', 'money') >= price then
			ox_inventory:RemoveItem(xPlayer.source, 'money', price)
			local rowsChanged = MySQL.insert.await('INSERT INTO owned_vehicles (owner, vehicle, plate, type, job, stored) VALUES (?, ?, ?, ?, ?, ?)', {
				xPlayer.identifier, 
				json.encode(vehicleProps),
				vehicleProps.plate,
				'car',
				xPlayer.job.name,
				true
			})
			if rowsChanged then
				theReturnValue = true
			end
		end
	end
    return theReturnValue
end)

lib.callback.register('HU-GangSystem:getGangTasks', function(source, gangName)
    local list = {}
    for i = 1, #tasks do
        if tasks[i].businessName == gangName then
            table.insert(list , {
                taskId = tasks[i].id,
                businessName = tasks[i].businessName,
                taskTitle = tasks[i].title,
                deliveryid = tasks[i].deliveryid,
                reward = tasks[i].reward,
                assignedTo = tasks[i].assignedTo,
                assignedName = tasks[i].assignedName,
                taskStatus = tasks[i].status
            })
        end
    end
    return list
end)

lib.callback.register('HU-GangSystem:getMyTasks', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local mylist = {}
	if type(Config.GangTasks[xPlayer.job.name]) == 'table' then
		for k, v in pairs(playerTasks) do
			if v.identifier == xPlayer.identifier and xPlayer.job.name == v.businessname then
				table.insert(mylist, {
					taskid = v.taskid,
					tasktitle = v.tasktitle,
					businessname = v.businessname,
					taskpayout = v.taskpayout
				})
			end
		end
	else
		CollectiveS.Notification(src, 3, locale('gang_tasks_no_gang'))
		return false  
	end
	if #mylist > 0 then
		return mylist    
	else
		CollectiveS.Notification(src, 3, locale('gang_tasks_no_tasks'))
		return false    
	end
end)