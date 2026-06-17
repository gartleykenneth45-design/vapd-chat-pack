local isChatOpen = false

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
    local html = ""
    if data.template then
        html = data.template
        if data.args then
            for i, arg in ipairs(data.args) do
                html = html:gsub("{" .. (i - 1) .. "}", arg)
            end
        end
    elseif data.args and #data.args > 0 then
        if #data.args > 1 then
            html = '<div class="msg-local"><span class="msg-name">' .. tostring(data.args[1]) .. '</span>: ' .. tostring(data.args[2]) .. '</div>'
        else
            html = '<div class="msg-local">' .. tostring(data.args[1]) .. '</div>'
        end
    end

    if html ~= "" then
        SendNUIMessage({ action = "addMessage", html = html })
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
        html = '<div class="msg-local"><span class="msg-name">' .. name .. '</span>: ' .. msg .. '</div>'
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
        html = '<div class="msg-me">* ' .. text .. ' *</div>'
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
        html = '<div class="msg-twt"><span class="msg-icon">&#x1F426;</span> <span class="msg-tag">@' .. name .. '</span>: ' .. msg .. '</div>'
    })
end)

-- /blackweb - anonymous dark web channel
RegisterNetEvent("vpdchat:blackweb")
AddEventHandler("vpdchat:blackweb", function(msg)
    SendNUIMessage({
        action = "addMessage",
        html = '<div class="msg-blackweb"><span class="msg-icon">&#x1F577;&#xFE0F;</span> <span class="msg-tag">BLACKWEB</span>: ' .. msg .. '</div>'
    })
end)

-- /ooc - out of character
RegisterNetEvent("vpdchat:ooc")
AddEventHandler("vpdchat:ooc", function(name, msg)
    SendNUIMessage({
        action = "addMessage",
        html = '<div class="msg-ooc">(( <span class="msg-name">' .. name .. '</span>: ' .. msg .. ' ))</div>'
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
