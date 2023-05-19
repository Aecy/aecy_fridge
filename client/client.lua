-- # region variables
local activeBlips, closestShop = {}, {}

local bottleObject, fridgeObject, bottleNet, fridgeNet, tableNet = nil, nil, nil, nil, nil
local isDrinking, isServing, isHoldingBottle, isOnTable = false, false, false, false

local isMarkerShowed, isInShopArea, isInMenu = false, false, false
-- # end region variables

-- # region local functions.
local function ShowNotification(message)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(message)
	DrawNotification(true, false)
end

local function ShowHelpNotification(message)
	SetTextComponentFormat('STRING')
	AddTextComponentString(message)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function ShowKeyboardNotification(message)
	SetTextFont(0) -- font type
	SetTextScale(0.5, 0.5) -- font size
	SetTextColour(255, 255, 255, 255) -- font color (white)
	SetTextEntry('STRING')
	AddTextComponentString(message) -- text to display
	DrawText(0.95, 0.95) -- text position (bottom right)
end

local function CreateBlips()
	local blips = {}
	for i = 1, #Config.Shops do
		if type(Config.Shops[i].blip) == 'table' and Config.Shops[i].blip.enabled then
			local blip = AddBlipForCoord(Config.Shops[i].coords.xy)
            SetBlipSprite(blip, Config.Shops[i].blip.sprite)
            SetBlipScale(blip, Config.Shops[i].blip.scale)
            SetBlipColour(blip, Config.Shops[i].blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(Config.Shops[i].name)
            EndTextCommandSetBlipName(blip)
			blips[#blips + 1] = blip
		end
	end
	activeBlips = blips
end

local function RemoveBlips()
	for i = 1, #activeBlips do
		if DoesBlipExist(activeBlips[i]) then
			RemoveBlip(activeBlips[i])
		end
	end
	activeBlips = {}
end

local function ShowMarker(coord)
	Citizen.CreateThread(function()
		while isMarkerShowed do
            DrawMarker(25, coord.x, coord.y, coord.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 0.8, 187, 255, 0, 255, false, true, 2, false, nil, nil, false)
            Wait(0)
		end
	end)
end

local function OpenMenu(items)
	isInMenu = true
    SetNuiFocus(true, true)
	SendNUIMessage({
		action = "open",
		items = items
	})
end

local function CloseMenu()
	isInMenu = false
	SetNuiFocus(false, false)
	SendNUIMessage({
		action = "close"
	})
end

local function ListenInputContextKey(items)
	Citizen.CreateThread(function()
		while (isInShopArea and not isInMenu) do
			if IsControlJustReleased(0, Config.KeyInteract) then
				OpenMenu(items)
			end
			Citizen.Wait(0)
		end
	end)
end

local function StartThread()
	Citizen.CreateThread(function()
		CreateBlips()
		while true do
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)

			if IsPedOnFoot(ped) then
				for i = 1, #Config.Shops do
					local shopDistance = #(coords - Config.Shops[i].coords.xyz)
					if shopDistance <= Config.DrawMarkerMaxDistance then
						closestShop = {
							Config.Shops[i].coords,
							shopDistance,
							Config.Shops[i].items
						}
					end
				end

				if not isMarkerShowed and next(closestShop) then
					isMarkerShowed = true
					ShowMarker(closestShop[1].xyz)
				elseif isMarkerShowed and not next(closestShop) then
					isMarkerShowed = false
				end

				if next(closestShop) then
					if not isInShopArea and closestShop[2] <= 1.0 then
						isInShopArea = true
						ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour ouvrir le catalogue des boissons")
						ListenInputContextKey(closestShop[3])
					elseif isInShopArea and closestShop[2] > 1.0 then
						isInShopArea = false
					end
				end
			end

			Citizen.Wait(1000)
		end
	end)
end

local function StartThreadHoldingBottle()
	Citizen.CreateThread(function()
		while isHoldingBottle do
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)

			for i = 1, #Config.Tables do
				local tablePos = Config.Tables[i]
				local distance = #(coords - tablePos)
				if distance <= Config.MaxDistancePutBottleOnTable then
					ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour mettre la bouteille sur la table")
					if IsControlJustReleased(0, Config.KeyInteract) then
						-- DropBottleOnTable(table)
					end
				end
			end
 			Citizen.Wait(1)
		end
	end)
end

local function BringBottleToTable(data)
	local prop = data.prop
	local ped = PlayerPedId()
	RequestModel(GetHashKey(prop))
	while not HasModelLoaded(GetHashKey(prop)) do
		Citizen.Wait(100)
	end
	local boneIndex = GetPedBoneIndex(ped, 57005)
	local coords = GetPedBoneCoords(ped, boneIndex)
	local bottle = CreateObject(GetHashKey(prop), coords.x, coords.y, coords.z, true, true, true)
	SetEntityHeading(bottle, GetEntityHeading(ped))
	AttachEntityToEntity(bottle, ped, boneIndex, 0.10, 0.06, -0.05, 0.0, 0.0, 100.0, false, false, true, false, 1, true)
	bottleObject = bottle
	isHoldingBottle = true
	StartThreadHoldingBottle()
end

-- Citizen.CreateThread(function()
-- 	while true do
-- 		Wait(0)
-- 		if not bottleObject then
-- 			local ped = PlayerPedId()
-- 			local coords = GetEntityCoords(ped)
-- 			bottleObject = CreateObject(GetHashKey(bottleProp), coords.x, coords.y, coords.z, true, true, true)
-- 			FreezeEntityPosition(bottleObject, false)
-- 			SetEntityAsMissionEntity(bottleObject, true, true)
-- 			bottleNet = ObjToNet(bottleObject)
-- 		end
-- 	end
-- end)
-- # end region local function.

-- # region event handler.
AddEventHandler('onResourceStart', function(resourceName)
	if resourceName ~= GetCurrentResourceName() then return end
	StartThread()
end)

AddEventHandler('onResourceStop', function(resourceName)
	if resourceName ~= GetCurrentResourceName() then return end
	RemoveBlips()
	if bottleObject ~= nil then
		DeleteObject(bottleObject)
	end
	if isInMenu then
		CloseMenu()
	end
end)
-- # end region event handler.

-- # region commands.

RegisterCommand('frigo', function()

end, false)

-- # end region commands.

-- # region NUI callbacks.
RegisterNUICallback('close', function(data, cb)
	CloseMenu()
	cb('ok')
end)

RegisterNUICallback('buy', function(data, cb)
	CloseMenu()
	ShowNotification("Vous avez pris ~b~une " .. data.name .. "~w~. Apportez-la à table.")
	BringBottleToTable(data)
	cb('ok')
end)
-- # end region NUI callbacks.