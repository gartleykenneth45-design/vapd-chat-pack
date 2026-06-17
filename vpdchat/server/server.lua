RegisterCommand("me", function(source, args, rawCommand)

    if not args or #args == 0 then
        return
    end

    local msg = table.concat(args, " ")

    TriggerClientEvent("vpdchat:3dme", -1, source, msg)

end, false)

RegisterCommand("twt", function(source, args, rawCommand)

    if not args or #args == 0 then
        return
    end

    local name = GetPlayerName(source)
    local msg = table.concat(args, " ")

    TriggerClientEvent("chat:addMessage", -1, {
        template = '<div class="twt">🐦 @{0}: {1}</div>',
        args = {
            name,
            msg
        }
    })

end, false)

RegisterCommand("blackweb", function(source, args, rawCommand)

    if not args or #args == 0 then
        return
    end

    local msg = table.concat(args, " ")

    TriggerClientEvent("chat:addMessage", -1, {
        template = '<div class="blackweb">🕷️ BLACKWEB: {0}</div>',
        args = {
            msg
        }
    })

end, false)

RegisterCommand("ooc", function(source, args, rawCommand)

    if not args or #args == 0 then
        return
    end

    local name = GetPlayerName(source)
    local msg = table.concat(args, " ")

    TriggerClientEvent("chat:addMessage", -1, {
        template = '<div class="ooc">(( {0}: {1} ))</div>',
        args = {
            name,
            msg
        }
    })

end, false)