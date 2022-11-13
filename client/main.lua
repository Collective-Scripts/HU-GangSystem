local ox_inventory = exports.ox_inventory
local CurrentActionData = {}
local HasAlreadyEnteredMarker = false
local LastStation, LastPart, LastPartNum, CurrentAction, CurrentActionMsg
isInShopMenu = false

if GetResourceState('ox_lib') == 'started' then
	lib.locale()
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
    ESX.PlayerLoaded = true
end)

local function isBoss()
    local theReturnValue = false
    for i = 1, #Config.GangBossActions, 1 do
        local data = Config.GangBossActions[i]
        if ESX.PlayerData.job and ESX.PlayerData.job.name == data.Job and ESX.PlayerData.job.grade_name == 'boss' then
            theReturnValue = true
        end
    end
    return theReturnValue
end

local function openInventory(id)
    ox_inventory:openInventory('stash', id)
end

local function OpenGangTasks(gangName)
    if not GlobalState.isGangTasksLoaded then
        CollectiveC.Notification(3, locale('gang_tasks_fetch'))
        CollectiveC.Notification(3, locale('gang_tasks_try_again'))
        TriggerServerEvent('HU-GangSystem:FetchGangTasks')
        return
    end
    lib.callback('HU-GangSystem:getGangTasks', false, function(gangTasks)
        local SendMenu = {}
        for i=1, #gangTasks, 1 do
            if gangTasks[i].taskStatus == "Pending" then
                if gangTasks[i].businessName == gangName then
                    table.insert(SendMenu, {
                        title = gangTasks[i].taskTitle,
                        description = gangTasks[i].taskStatus..' ['.. gangTasks[i].assignedName ..']',
                        event = 'HU-GangSystem:GangTasksActions',
                        args = {
                            taskId = gangTasks[i].taskId,
                            businessName = gangTasks[i].businessName,
                            taskTitle = gangTasks[i].taskTitle,
                            deliveryid = gangTasks[i].deliveryid,
                            reward = gangTasks[i].reward,
                            assignedTo = gangTasks[i].assignedTo,
                            assignedName = gangTasks[i].assignedName,
                            taskStatus = gangTasks[i].taskStatus
                        }    
                    })
                end
            else
                if gangTasks[i].businessName == gangName then
                    table.insert(SendMenu, {
                        title = gangTasks[i].taskTitle,
                        description = gangTasks[i].taskStatus,
                        event = 'HU-GangSystem:GangTasksActions',
                        args = {
                            taskId = gangTasks[i].taskId,
                            businessName = gangTasks[i].businessName,
                            taskTitle = gangTasks[i].taskTitle,
                            deliveryid = gangTasks[i].deliveryid,
                            reward = gangTasks[i].reward,
                            assignedTo = gangTasks[i].assignedTo,
                            assignedName = gangTasks[i].assignedName,
                            taskStatus = gangTasks[i].taskStatus
                        }  
                    })
                end
            end
        end
        lib.registerContext({
            id = 'gang_tasks_menu',
            title = locale('gang_tasks'),
            options = SendMenu
        })
        lib.showContext('gang_tasks_menu')
    end, gangName)
end

AddEventHandler('HU-GangSystem:GangTasksActions', function(theDataZ)
    local event = theDataZ
    if event.taskStatus == "Unassigned" then       
        local input = lib.inputDialog('Assign Tasks [Player ID]', {'Player ID'})
        if not input then return end
        local thePlayerID = tonumber(input[1])
        if thePlayerID == nil or thePlayerID == "" or type(thePlayerID) ~= 'number' then
            CollectiveC.Notification(3, locale('gang_tasks_invalid_id'))
            return
        else
            TriggerServerEvent('HU-GangSystem:AssignGangTask', event.businessName, event.taskId, event.taskTitle, thePlayerID)
        end
    elseif event.taskStatus == "Pending" then
        OpenTaskCancel(event.businessName, event.taskId)
    elseif event.taskStatus == "Accepted" then
        CollectiveC.Notification(3, locale('gang_tasks_accepted'))
    elseif event.taskStatus == "Completed" then
        CollectiveC.Notification(3, locale('gang_tasks_completed'))
    elseif event.action == 'accept_task' then
        ConfirmAcceptTask(event.businessName, event.taskId)
    end
end)

function OpenTaskCancel(businessname, taskid)
    local alert = lib.alertDialog({
        header = '⛔ Gang Tasks',
        content = 'Are you sure you want to cancel this pending task?',
        centered = true,
        cancel = true
    })
    if alert == 'confirm' then
        TriggerServerEvent('HU-GangSystem:CancelGangTask', businessname, taskid)
    end
end


local TasksLimit = 0
RegisterCommand('tasks', function()
    if (GetGameTimer() - TasksLimit) < 3000 then 
        CollectiveC.Notification(3, locale('gang_tasks_rate_limit', (3 - math.floor((GetGameTimer() - TasksLimit) / 1000))))
		return 
	end
	TasksLimit = GetGameTimer()
    OpenTasksMenu()
end)

-- TASKSS
function OpenTasksMenu()
    lib.callback('HU-GangSystem:getMyTasks', false, function(mylist)
        if mylist then
            local elements = {}
            for i=1, #mylist, 1 do
                table.insert(elements, {
                    title = mylist[i].tasktitle,
                    description = 'ACCEPT?',
                    event = 'HU-GangSystem:GangTasksActions',
                    args = {
                        action = 'accept_task',
                        taskTitle = mylist[i].tasktitle,
                        taskId = mylist[i].taskid,
                        businessName = mylist[i].businessname,
                        taskPayout = mylist[i].taskpayout
                    }
                })
            end
            lib.registerContext({
                id = 'my_gang_tasks',
                title = 'The Title',
                options = elements
            })
            lib.showContext('my_gang_tasks')
        end
    end)
end
-- ACCEPT TASKS
function ConfirmAcceptTask(businessname, taskid)
    local alert = lib.alertDialog({
        header = '⛔ Gang Tasks',
        content = 'Do you really want to accept this task?',
        centered = true,
        cancel = true
    })
    if alert == 'confirm' then
        TriggerServerEvent('HU-GangSystem:AcceptGangTask', businessname, taskid)
    end  
end

-- GANG TASKS THREAD --
local bodyModels = {
    [1] = "a_m_m_acult_01",
    [2] = "cs_andreas",
    [3] = "s_f_y_bartender_01",
    [4] = "mp_f_deadhooker",
    [5] = "u_m_o_finguru_01"
}

local bodyDrops = {
    { x = 1887.19, y = 247.76, z = 161.78 },
    { x = -341.19, y = 3014.65, z = 15.21 },
    { x = -1375.09, y = 4309.33, z = 1.02 }
}

RegisterNetEvent("HU-GangSystem:StartGangTask")
AddEventHandler("HU-GangSystem:StartGangTask", function(businessname, taskid)
    local businessid = 0
    for i = 1, #Config.TaskZones, 1 do
        if Config.TaskZones[i].GangName == businessname then
            businessid = i
        end
    end
    local deliveryPoint = 0
    local startPoint = vector3(Config.TaskZones[businessid].taskspawn.x, Config.TaskZones[businessid].taskspawn.y, Config.TaskZones[businessid].taskspawn.z)
    repeat
        local deliveryid = math.random(1, #Config.TaskDeliveryPoints)
        deliveryPoint = vector3(Config.TaskDeliveryPoints[deliveryid].x, Config.TaskDeliveryPoints[deliveryid].y, Config.TaskDeliveryPoints[deliveryid].z)
        del_dist = #(deliveryPoint - startPoint)
    until del_dist >= 500.0
    Citizen.Wait(1000)
    local dist = 100.0
    local failure = 300000
    SetNewWaypoint(startPoint.x, startPoint.y)
    CollectiveC.Notification(2, locale('gang_tasks_set_wyp'))
    while dist > 15.0 and failure > 0 do
        Citizen.Wait(1)
        local pedCoords = GetEntityCoords(PlayerPedId())
        dist = #(startPoint - pedCoords)
        failure = failure - 1
    end
    if failure == 0 then
        print('Gang Tasks Failed.')
        return
    end
    CollectiveC.Notification(2, locale('gang_tasks_deliver'))
    local taskveh = 0
    lib.requestModel("paradise", 100)
    taskveh = CreateVehicle(`paradise`, Config.TaskZones[businessid].taskspawn.x, Config.TaskZones[businessid].taskspawn.y, Config.TaskZones[businessid].taskspawn.z, Config.TaskZones[businessid].taskheading, true, false)
    SetVehicleLivery(taskveh, 1)    
    SetVehicleOnGroundProperly(taskveh)
    SetVehicleHasBeenOwnedByPlayer(taskveh,true)
    local plt = GetVehicleNumberPlateText(taskveh)
    SetVehicleHasBeenOwnedByPlayer(taskveh, true)
    local id = NetworkGetNetworkIdFromEntity(taskveh)
    SetNetworkIdCanMigrate(id, true)
    SetVehicleWindowTint(taskveh, 1.0)
    local plate = GetVehicleNumberPlateText(taskveh)
    SetVehicleHasBeenOwnedByPlayer(taskveh,true)
    if math.random(100) < 35 then
        lib.requestModel("prop_cs_cardbox_01", 100)
        local obj = CreateObject(`prop_cs_cardbox_01`, Config.TaskZones[businessid].taskspawn.x, Config.TaskZones[businessid].taskspawn.y, Config.TaskZones[businessid].taskspawn.z-10, 1, 0, 0)
        AttachEntityToEntity(obj, taskveh, GetEntityBoneIndexByName(taskveh, 'bodyshell'), 0.0, -0.8, -0.4, 0, 0, 0, 1, 1, 0, 1, 0, 1)
        failure = DoObjectTask(deliveryPoint, failure, taskveh, obj)
    else
        local BodyDropsLocation = math.random(1, #bodyModels)
        lib.requestModel(bodyModels[BodyDropsLocation], 100)
        local ped = CreatePed(GetPedType(GetHashKey(bodyModels[BodyDropsLocation])), GetHashKey(bodyModels[BodyDropsLocation]), Config.TaskZones[businessid].taskspawn.x, Config.TaskZones[businessid].taskspawn.y, Config.TaskZones[businessid].taskspawn.z-10, Config.TaskZones[businessid].taskheading, 1, 1)  
        AttachEntityToEntity(ped, taskveh, GetEntityBoneIndexByName(taskveh, 'bodyshell'), 0.0, -0.8, 0.6, 0, 0, 0, 1, 1, 0, 1, 0, 1)
        lib.requestAnimDict( "dead", 100) 
        TaskPlayAnim(ped, "dead", "dead_f", 8.0, 8.0, -1, 1, 0, 0, 0, 0)
        failure = DoBodyTask(deliveryPoint, failure, taskveh, ped)            
    end    
    local pedCoords = GetEntityCoords(PlayerPedId())
    local dist = #(startPoint - pedCoords)
    Citizen.Wait(1000)
    SetNewWaypoint(startPoint.x, startPoint.y)
    CollectiveC.Notification(2, locale('gang_tasks_delivered'))
    while dist > 5.0 and failure > 0 do
        Citizen.Wait(1)
        local myCrds = GetEntityCoords(PlayerPedId())
        dist = #(startPoint - myCrds)
        failure = failure - 1
    end
    while GetEntitySpeed(taskveh) > 1.0 and taskveh ~= 0 do
        Citizen.Wait(1)
    end
    SetVehicleAsNoLongerNeeded(taskveh)
    ESX.Game.DeleteVehicle(taskveh)
    TriggerServerEvent('HU-GangSystem:CompleteGangTask', businessname, taskid)   
end)

function DoObjectTask(deliveryPoint, failure, taskveh, obj)

    local pedCoords = GetEntityCoords(PlayerPedId())
    local dst = #(deliveryPoint - pedCoords)

    Citizen.Wait(1000)
    
    SetNewWaypoint(deliveryPoint.x, deliveryPoint.y)

    while dst > 50.0 and failure > 0 do
        Citizen.Wait(1)
        dst = #(deliveryPoint - GetEntityCoords(PlayerPedId()))
        failure = failure - 1
    end

    local pickedup = false
    while not pickedup and failure > 0 do
        Citizen.Wait(1)
        local d1,d2 = GetModelDimensions(GetEntityModel(taskveh))
        local myCrds = GetOffsetFromEntityInWorldCoords(taskveh, 0.0, d1["y"]-0.5,0.0)
        dst = #(GetEntityCoords(PlayerPedId()) - myCrds)
        failure = failure - 1

        if not IsPedInAnyVehicle(PlayerPedId(), true) then
            ESX.DrawText3D(myCrds["x"],myCrds["y"],myCrds["z"], "[E] to take the package")
            
            if IsControlJustPressed(0, 38) and dst < 1.5 then

                SetVehicleDoorOpen(taskveh, 2, 1, 1)
                SetVehicleDoorOpen(taskveh, 3, 1, 1) 
                TaskTurnPedToFaceEntity(PlayerPedId(), taskveh, 1.0)
                Citizen.Wait(500)


                Citizen.Wait(500)
                DetachEntity(obj)
                attachObjPed(obj)
                ClearPedTasks(PlayerPedId())
                ClearPedSecondaryTask(PlayerPedId())
                CarryBoxAnim()

                SetVehicleDoorShut(taskveh, 2, 1, 1)
                SetVehicleDoorShut(taskveh, 3, 1, 1) 
                pickedup = true
            end
        end
    end

    local holdingPackage = true
    dst = #(deliveryPoint - GetEntityCoords(PlayerPedId()))
    while dst > 0.8 and failure > 0 do
        Citizen.Wait(1)

        local myCrds = GetEntityCoords(PlayerPedId())
        dst = #(deliveryPoint - myCrds)
        failure = failure - 1

        if holdingPackage then
            ESX.DrawText3D(deliveryPoint.x, deliveryPoint.y, deliveryPoint.z, "Drop Here")
            if not IsEntityPlayingAnim(PlayerPedId(), "anim@heists@box_carry@", "idle", 3) then
                CarryBoxAnim()
            end
        else
            local pedcrds = GetEntityCoords(obj)
            ESX.DrawText3D(pedcrds["x"],pedcrds["y"],pedcrds["z"], "Pickup Package [E]")
        end
        
        if IsControlJustPressed(0, 38) or (`WEAPON_UNARMED` ~= GetSelectedPedWeapon(PlayerPedId()) and holdingPackage) then
            holdingPackage = not holdingPackage
            if holdingPackage then
                CarryBoxAnim()
                Citizen.Wait(500)
                attachObjPed(obj)
            else
                ClearPedTasks(PlayerPedId())
                DetachEntity(obj)
                DetachEntity(PlayerPedId())
            end
        end
    end 

    DetachEntity(obj)
    SetEntityAsNoLongerNeeded(obj)
    ClearPedTasks(PlayerPedId())
    ClearPedSecondaryTask(PlayerPedId())
    DeleteEntity(obj)
    return failure
end

function DoBodyTask(deliveryPoint, failure, taskveh, ped)
    local myCrds = GetEntityCoords(PlayerPedId())
    local tskCrds = GetEntityCoords(taskveh)
    local dst = #(tskCrds - myCrds)
    local BodyDropsLocation = math.random(1, #bodyDrops)
    SetBlockingOfNonTemporaryEvents(ped, true)      
    SetPedSeeingRange(ped, 0.0)     
    SetPedHearingRange(ped, 0.0)        
    SetPedFleeAttributes(ped, 0, false)     
    SetPedKeepTask(ped, true)       
    local taskcomplete = false
    while dst > 50.0 and failure > 0 do
        Citizen.Wait(1)
        local myCrds = GetEntityCoords(PlayerPedId())
        dst = #(tskCrds - myCrds)
        tskCrds = GetEntityCoords(taskveh)
        ESX.DrawText3D(tskCrds["x"],tskCrds["y"],tskCrds["z"], "Get In Vehicle")
        failure = failure - 1
    end
    SetNewWaypoint(bodyDrops[BodyDropsLocation].x, bodyDrops[BodyDropsLocation].y)
    dst = #(vector3(bodyDrops[BodyDropsLocation].x, bodyDrops[BodyDropsLocation].y, bodyDrops[BodyDropsLocation].z) - GetEntityCoords(PlayerPedId()))
    while dst > 50.0 and failure > 0 do
        local myCrds = plyCoords
        dst = #(vector3(bodyDrops[BodyDropsLocation].x, bodyDrops[BodyDropsLocation].y, bodyDrops[BodyDropsLocation].z) - GetEntityCoords(PlayerPedId()))
        Citizen.Wait(1)
    end
    local bodyTaken = false
    while not bodyTaken and failure > 0 do
        local d1,d2 = GetModelDimensions(GetEntityModel(taskveh))
        local myCrds = GetOffsetFromEntityInWorldCoords(taskveh, 0.0,d1["y"]-0.5,0.0)
        dst = #(GetEntityCoords(PlayerPedId()) - myCrds)
        if not IsPedInAnyVehicle(PlayerPedId(), true) then
            ESX.DrawText3D(myCrds["x"],myCrds["y"],myCrds["z"], "[E] to take the body")  
            if IsControlJustPressed(0, 38) and dst < 1.5 then
                lib.requestAnimDict('anim@narcotics@trash', 100)
                TaskPlayAnim(PlayerPedId(),'anim@narcotics@trash', 'drop_front',0.9, -8, 1500, 49, 3.0, 0, 0, 0) 
                TaskTurnPedToFaceEntity(PlayerPedId(), taskveh, 1.0)
                SetVehicleDoorOpen(taskveh, 2, 1, 1)
                SetVehicleDoorOpen(taskveh, 3, 1, 1)   
                Citizen.Wait(1600)
                ClearPedTasks(PlayerPedId())      
                bodyTaken = true 
                DetachEntity(ped)
                ClearPedTasks(ped)
                lib.requestAnimDict("amb@world_human_bum_slumped@male@laying_on_left_side@base", 100) 
                TaskPlayAnim(ped, "amb@world_human_bum_slumped@male@laying_on_left_side@base", "base", 8.0, 8.0, -1, 1, 999.0, 0, 0, 0)
                AttachEntityToEntity(ped, PlayerPedId(), 1, -0.68, -0.2, 0.82, 180.0, 180.0, 60.0, 1, 1, 0, 1, 0, 1)
                lib.requestAnimDict( "missfinale_c2mcs_1", 100) 
                TaskPlayAnim(PlayerPedId(), "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 1.0, 1.0, -1, 50, 0, 0, 0, 0)
                SetVehicleDoorShut(taskveh, 2, 1, 1)
                SetVehicleDoorShut(taskveh, 3, 1, 1) 
            end
        end
        Citizen.Wait(1)
    end
    local dst = #(vector3(bodyDrops[BodyDropsLocation].x, bodyDrops[BodyDropsLocation].y, bodyDrops[BodyDropsLocation].z) - GetEntityCoords(PlayerPedId()))
    local holdingBody = true
    while (dst > 2.0 or not holdingBody) and failure > 0 do
        Citizen.Wait(1)
        if holdingBody then
            ESX.DrawText3D(bodyDrops[BodyDropsLocation].x, bodyDrops[BodyDropsLocation].y, bodyDrops[BodyDropsLocation].z, "Dispose dead body")
            if not IsEntityPlayingAnim(PlayerPedId(), "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 3) then
                lib.requestAnimDict( "missfinale_c2mcs_1", 100) 
                TaskPlayAnim(PlayerPedId(), "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 1.0, 1.0, -1, 50, 0, 0, 0, 0)
            end
        else
            local pedcrds = GetEntityCoords(ped)
            ESX.DrawText3D(pedcrds["x"],pedcrds["y"],pedcrds["z"], "[E] to pickup body")
        end
        if IsControlJustPressed(0, 38) or (`WEAPON_UNARMED` ~= GetSelectedPedWeapon(PlayerPedId()) and holdingBody)  then
            holdingBody = not holdingBody
            if holdingBody then
                ClearPedTasks(ped)
                lib.requestAnimDict("amb@world_human_bum_slumped@male@laying_on_left_side@base", 100) 
                TaskPlayAnim(ped, "amb@world_human_bum_slumped@male@laying_on_left_side@base", "base", 8.0, 8.0, -1, 1, 0, 0, 0, 0)
                AttachEntityToEntity(ped, PlayerPedId(), 1, -0.68, -0.2, 0.82, 180.0, 180.0, 60.0, 1, 1, 0, 1, 0, 1)
                lib.requestAnimDict( "missfinale_c2mcs_1", 100) 
                TaskPlayAnim(PlayerPedId(), "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 1.0, 1.0, -1, 50, 0, 0, 0, 0)
            else
                lib.requestAnimDict('anim@narcotics@trash', 100)
                TaskPlayAnim(PlayerPedId(),'anim@narcotics@trash', 'drop_front',0.9, -8, 1500, 49, 3.0, 0, 0, 0) 
                DetachEntity(ped)
            end
        end
        local myCrds = plyCoords
        dst = #(vector3(bodyDrops[BodyDropsLocation].x, bodyDrops[BodyDropsLocation].y, bodyDrops[BodyDropsLocation].z) - GetEntityCoords(PlayerPedId()))
        failure = failure - 1
    end
    if failure > 0 then
        lib.requestAnimDict('anim@narcotics@trash', 100)
        TaskPlayAnim(PlayerPedId(),'anim@narcotics@trash', 'drop_front',0.9, -8, 1500, 49, 3.0, 0, 0, 0) 
        DetachEntity(ped)
        SetEntityCoords(ped, 975.0, -2165.9, 29.47)
        SetEntityHeading(ped, 82.02)
        SetPedAsNoLongerNeeded(ped)
        DeleteEntity(ped)
    end 
    return failure
end

function CarryBoxAnim()
    local dic = "anim@heists@box_carry@"
    local anim = "idle"
    local lPed = PlayerPedId()
    if not IsEntityPlayingAnim(lPed, dic, anim, 3) and not IsPedInAnyVehicle(PlayerPedId(), false) then
        lib.requestAnimDict(dic, 100) 
        TaskPlayAnim(lPed, dic, anim, 1.0, 1.0, -1, 50, 0, 0, 0, 0)
    end
end

function attachObjPed(obj)
    local bone = GetPedBoneIndex(PlayerPedId(), 28422)
    AttachEntityToEntity(obj, PlayerPedId(), bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
end

AddEventHandler('HU-GangSystem:hasEnteredMarker', function(station, part, partNum)
	if part == 'Vehicles' then
		CurrentAction     = 'menu_vehicle_spawner'
		CurrentActionMsg  = locale('garage_prompt')
		CurrentActionData = {station = station, part = part, partNum = partNum}
	end
end)

AddEventHandler('HU-GangSystem:hasExitedMarker', function(station, part, partNum)
	if not isInShopMenu then ESX.UI.Menu.CloseAll() end CurrentAction = nil
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
        if ESX.PlayerLoaded then
            for k,v in pairs(Config.Gangs) do
                if ESX.PlayerData.job and ESX.PlayerData.job.name == k then
                    local playerPed = PlayerPedId()
                    local playerCoords = GetEntityCoords(playerPed)
                    local isInMarker, hasExited, letSleep = false, false, true
                    local currentStation, currentPart, currentPartNum
                    for i=1, #v.Vehicles, 1 do
                        local distance = #(playerCoords - v.Vehicles[i].Spawner)
                        if distance <= 1.0 then
                            letSleep = false
                            ESX.DrawText3D(v.Vehicles[i].Spawner.x, v.Vehicles[i].Spawner.y, v.Vehicles[i].Spawner.z, '[~b~E~w~] Garage')
                            isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Vehicles', i
                        elseif distance < 10.0 then
                            DrawMarker(2, v.Vehicles[i].Spawner.x, v.Vehicles[i].Spawner.y, v.Vehicles[i].Spawner.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 255, 255, 255, 222, false, false, false, true, false, false, false)
                            letSleep = false
                        end
                    end
                    if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then
                        if (LastStation and LastPart and LastPartNum) and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum) then
                            TriggerEvent('HU-GangSystem:hasExitedMarker', LastStation, LastPart, LastPartNum)
                            hasExited = true
                        end
                        HasAlreadyEnteredMarker = true
                        LastStation             = currentStation
                        LastPart                = currentPart
                        LastPartNum             = currentPartNum
                        TriggerEvent('HU-GangSystem:hasEnteredMarker', currentStation, currentPart, currentPartNum)
                    end
                    if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
                        HasAlreadyEnteredMarker = false
                        TriggerEvent('HU-GangSystem:hasExitedMarker', LastStation, LastPart, LastPartNum)
                    end
        
                    if letSleep then
                        Citizen.Wait(500)
                    end
                end
            end
        end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if CurrentAction then
            if IsControlJustReleased(0, 38) then
                if CurrentAction == 'menu_vehicle_spawner' then
                    OpenVehicleSpawnerMenu('car', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
                elseif CurrentAction == 'delete_vehicle' then
                    ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
                end
                CurrentAction = nil
            end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		local sleep = 500
        local ped = PlayerPedId()
		local playerPos = GetEntityCoords(ped)
        if ESX.PlayerLoaded then
            local isBoss = isBoss()
            for i = 1, #Config.StashZoneLocation, 1 do
                local dataZ = Config.StashZoneLocation[i]
                local distZ = #(playerPos - dataZ.pos)
                for k, v in pairs(dataZ.AuthorizeRanks) do
                    if distZ <= 1.0 then
                        if ESX.PlayerData.job.name == dataZ.setjob and ESX.PlayerData.job.grade_name == v or ESX.PlayerData.job.name == dataZ.setjob and v == 'all' then
                            sleep = 0
                            ESX.DrawText3D(dataZ.pos.x, dataZ.pos.y, dataZ.pos.z, dataZ.text)
                            if IsControlJustReleased(0, 38) then
                                openInventory(dataZ.targetstash)
                            end
                        end
                    elseif distZ <= 10.0 then
                        if ESX.PlayerData.job.name == dataZ.setjob and ESX.PlayerData.job.grade_name == v or ESX.PlayerData.job.name == dataZ.setjob and v == 'all' then
                            sleep = 0
                            DrawMarker(2, dataZ.pos.x, dataZ.pos.y, dataZ.pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 255, 255, 255, 222, false, false, false, true, false, false, false)
                        end
                    end 
                end
            end
            for i = 1, #Config.GangBossActions, 1 do
                local dataX = Config.GangBossActions[i]
                local distX = #(playerPos - dataX.BossActionLocation)
                if distX < 1.0 and isBoss then
                    sleep = 0
                    ESX.DrawText3D(dataX.BossActionLocation.x, dataX.BossActionLocation.y, dataX.BossActionLocation.z, '[~b~E~w~] Boss Action - '..dataX.JobLabel)
                    if IsControlJustReleased(0, 38) then
                        TriggerEvent('esx_society:openBossMenu', dataX.Job, function(data, menu)
                            menu.close()
                        end, {wash = false}) -- Disabling Money Wash
                    end
                elseif distX <= 10.0 and isBoss then
                    sleep = 0
                    DrawMarker(2, dataX.BossActionLocation.x, dataX.BossActionLocation.y, dataX.BossActionLocation.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 255, 255, 255, 222, false, false, false, true, false, false, false)
                end
            end
            for theDataC, theValueC in pairs(Config.GangTasks) do
                for theDataV, theValueV in pairs(theValueC.AuthorizeRanks) do
                    local distV = #(playerPos - theValueC.menuPos)
                    if distV <= 1.0 then
                        if ESX.PlayerData.job and ESX.PlayerData.job.name == theDataC and ESX.PlayerData.job.grade_name == theValueV then
                            sleep = 0
                            ESX.DrawText3D(theValueC.menuPos.x, theValueC.menuPos.y, theValueC.menuPos.z, '[~b~E~w~] Gang Tasks - '..ESX.PlayerData.job.label)
                            if IsControlJustReleased(0, 38) then
                                OpenGangTasks(theDataC)
                            end
                        end
                    elseif distV <= 10.0 then
                        if ESX.PlayerData.job and ESX.PlayerData.job.name == theDataC and ESX.PlayerData.job.grade_name == theValueV then
                            sleep = 0
                            DrawMarker(2, theValueC.menuPos.x, theValueC.menuPos.y, theValueC.menuPos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 255, 255, 255, 222, false, false, false, true, false, false, false)
                        end
                    end
                end
            end
        end
		Citizen.Wait(sleep)
	end
end)