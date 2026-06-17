local isChatOpen = false

local function escapeHtml(str)
    if not str then return "" end
    str = tostring(str)
    str = str:gsub("&", "&amp;")
    str = str:gsub("<", "&lt;")
    str = str:gsub(">", "&gt;")
    str = str:gsub('"', "&quot;")
    str = str:gsub("'", "&#39;")
    return str
end

-- Disable default GTA V text chat on startup
Citizen.CreateThread(function()
    Wait(500)
    SetTextChatEnabled(false)
end)

-- T key opens chat for normal typing
RegisterCommand("vpdchat_open", function()
    if not isChatOpen then
        isChatOpen = true
        SetNuiFocus(true, false)
        SendNUIMessage({ action = "openChat", prefix = "" })
    end
end, false)
RegisterKeyMapping("vpdchat_open", "Open Chat", "keyboard", "t")

-- / key opens chat with command prefix
RegisterCommand("vpdchat_command", function()
    if not isChatOpen then
        isChatOpen = true
        SetNuiFocus(true, false)
        SendNUIMessage({ action = "openChat", prefix = "/" })
    end
end, false)
RegisterKeyMapping("vpdchat_command", "Open Chat (Command)", "keyboard", "SLASH")

-- NUI callback: player submitted a message
RegisterNUICallback("sendMessage", function(data, cb)
    SetNuiFocus(false, false)
    isChatOpen = false

    local msg = data.message
    if msg and msg ~= "" then
        if string.sub(msg, 1, 1) == "/" then
            ExecuteCommand(string.sub(msg, 2))
        else
            TriggerServerEvent("vpdchat:localChat", msg)
        end
    end

    cb("ok")
end)

-- NUI callback: player closed chat (Escape)
RegisterNUICallback("closeChat", function(data, cb)
    SetNuiFocus(false, false)
    isChatOpen = false
    cb("ok")
end)

-- Intercept default chat:addMessage from other resources
RegisterNetEvent("chat:addMessage")
AddEventHandler("chat:addMessage", function(data)
    if data.template then
        local html = data.template
        if data.args then
            for i, arg in ipairs(data.args) do
                local safe = escapeHtml(arg):gsub("%%", "%%%%")
                html = html:gsub("{" .. (i - 1) .. "}", safe)
            end
        end
        SendNUIMessage({ action = "addRawHtml", html = html })
    elseif data.args and #data.args > 0 then
        if #data.args > 1 then
            SendNUIMessage({
                action = "addMessage",
                type = "local",
                name = tostring(data.args[1]),
                message = tostring(data.args[2])
            })
        else
            SendNUIMessage({
                action = "addMessage",
                type = "local",
                message = tostring(data.args[1])
            })
        end
    end
end)

-- Local proximity chat
RegisterNetEvent("vpdchat:local")
AddEventHandler("vpdchat:local", function(senderId, name, msg)
    local player = GetPlayerFromServerId(senderId)
    if player == -1 then return end

    local ped = GetPlayerPed(player)
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local targetCoords = GetEntityCoords(ped)

    if #(myCoords - targetCoords) > Config.ChatRange then return end

    SendNUIMessage({
        action = "addMessage",
        type = "local",
        name = name,
        message = msg
    })
end)

-- /me - 3D text above player head (proximity-based)
RegisterNetEvent("vpdchat:3dme")
AddEventHandler("vpdchat:3dme", function(id, text)
    local player = GetPlayerFromServerId(id)
    if player == -1 then return end

    local ped = GetPlayerPed(player)
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local targetCoords = GetEntityCoords(ped)

    if #(myCoords - targetCoords) > Config.ChatRange then return end

    SendNUIMessage({
        action = "addMessage",
        type = "me",
        message = text
    })

    local displayTime = GetGameTimer() + Config.MeDuration

    CreateThread(function()
        while GetGameTimer() < displayTime do
            Wait(0)
            local coords = GetEntityCoords(ped)
            DrawText3D(coords.x, coords.y, coords.z + 1.0, "* " .. text .. " *")
        end
    end)
end)

-- /twt - global social media channel
RegisterNetEvent("vpdchat:twt")
AddEventHandler("vpdchat:twt", function(name, msg)
    SendNUIMessage({
        action = "addMessage",
        type = "twt",
        name = name,
        message = msg
    })
end)

-- /blackweb - anonymous dark web channel
RegisterNetEvent("vpdchat:blackweb")
AddEventHandler("vpdchat:blackweb", function(msg)
    SendNUIMessage({
        action = "addMessage",
        type = "blackweb",
        message = msg
    })
end)

-- /ooc - out of character
RegisterNetEvent("vpdchat:ooc")
AddEventHandler("vpdchat:ooc", function(name, msg)
    SendNUIMessage({
        action = "addMessage",
        type = "ooc",
        name = name,
        message = msg
    })
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextCentre(true)
        SetTextColour(200, 162, 200, 255)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(_x, _y)
    end
end
