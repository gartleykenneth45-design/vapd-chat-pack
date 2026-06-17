RegisterNetEvent("vpdchat:3dme")
AddEventHandler("vpdchat:3dme", function(id,text)

    local player = GetPlayerFromServerId(id)

    if player == -1 then return end

    local ped = GetPlayerPed(player)

    local displayTime = GetGameTimer() + 7000

    CreateThread(function()

        while GetGameTimer() < displayTime do

            Wait(0)

            local coords = GetEntityCoords(ped)

            DrawText3D(
                coords.x,
                coords.y,
                coords.z + 1.0,
                "* "..text.." *"
            )

        end

    end)

end)

function DrawText3D(x,y,z,text)

    local onScreen,_x,_y = World3dToScreen2d(x,y,z)

    if onScreen then

        SetTextScale(0.35,0.35)
        SetTextFont(4)
        SetTextCentre(true)
        SetTextColour(200,162,200,255)

        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(_x,_y)

    end

end