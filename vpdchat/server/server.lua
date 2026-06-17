-- Discord Webhook Logging
local function SendDiscordLog(channel, playerName, playerId, message)
    if Config.DiscordWebhook == "" then return end
    if not Config.DiscordLogs[channel] then return end

    local colorMap = {
        ME = 13149896,
        TWT = 1941234,
        BLACKWEB = 10233008,
        OOC = 13421772
    }

    local embed = {
        {
            title = channel .. " Chat Log",
            description = message,
            color = colorMap[channel] or 0,
            fields = {
                { name = "Player", value = playerName, inline = true },
                { name = "Server ID", value = tostring(playerId), inline = true }
            },
            footer = {
                text = "VAPD Chat Pack | " .. os.date("%Y-%m-%d %H:%M:%S")
            }
        }
    }

    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, "POST", json.encode({
        username = Config.DiscordBotName,
        avatar_url = Config.DiscordBotAvatar,
        embeds = embed
    }), { ["Content-Type"] = "application/json" })
end

-- Local proximity chat (non-command text)
RegisterNetEvent("vpdchat:localChat")
AddEventHandler("vpdchat:localChat", function(msg)
    local src = source
    if not msg or msg == "" then return end

    local name = GetPlayerName(src)
    TriggerClientEvent("vpdchat:local", -1, src, name, msg)
end)

-- /me command - proximity-based 3D action text
RegisterCommand("me", function(source, args, rawCommand)
    if not args or #args == 0 then return end

    local name = GetPlayerName(source)
    local msg = table.concat(args, " ")

    TriggerClientEvent("vpdchat:3dme", -1, source, msg)
    SendDiscordLog("ME", name, source, msg)
end, false)

-- /twt command - global social media channel
RegisterCommand("twt", function(source, args, rawCommand)
    if not args or #args == 0 then return end

    local name = GetPlayerName(source)
    local msg = table.concat(args, " ")

    TriggerClientEvent("vpdchat:twt", -1, name, msg)
    SendDiscordLog("TWT", name, source, msg)
end, false)

-- /blackweb command - anonymous dark web messaging
RegisterCommand("blackweb", function(source, args, rawCommand)
    if not args or #args == 0 then return end

    local name = GetPlayerName(source)
    local msg = table.concat(args, " ")

    TriggerClientEvent("vpdchat:blackweb", -1, msg)
    SendDiscordLog("BLACKWEB", name, source, msg)
end, false)

-- /ooc command - out of character
RegisterCommand("ooc", function(source, args, rawCommand)
    if not args or #args == 0 then return end

    local name = GetPlayerName(source)
    local msg = table.concat(args, " ")

    TriggerClientEvent("vpdchat:ooc", -1, name, msg)
    SendDiscordLog("OOC", name, source, msg)
end, false)
