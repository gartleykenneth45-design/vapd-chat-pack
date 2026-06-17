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
        html = '<div class="twt">&#x1F426; @' .. name .. ': ' .. msg .. '</div>'
    })
end)

-- /blackweb - anonymous dark web channel
RegisterNetEvent("vpdchat:blackweb")
AddEventHandler("vpdchat:blackweb", function(msg)
    SendNUIMessage({
        action = "addMessage",
        html = '<div class="blackweb">&#x1F577;&#xFE0F; BLACKWEB: ' .. msg .. '</div>'
    })
end)

-- /ooc - out of character
RegisterNetEvent("vpdchat:ooc")
AddEventHandler("vpdchat:ooc", function(name, msg)
    SendNUIMessage({
        action = "addMessage",
        html = '<div class="ooc">(( ' .. name .. ': ' .. msg .. ' ))</div>'
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
