local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand("starterpack", function(source, args, rawCommand)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local hasReceived = Player.PlayerData.metadata[Config.MetadataKey]
    if hasReceived then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'You have already claimed your starter pack!',
            duration = 5000
        })
        return
    end

    -- Give items from config
    for _, item in pairs(Config.StarterItems) do
        exports.ox_inventory:AddItem(source, item.name, item.count)
    end

    -- Mark as received in metadata
    Player.Functions.SetMetaData(Config.MetadataKey, true)

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = 'You have received your starter pack!',
        duration = 5000
    })

    -- Log to Discord
    local playerName = GetPlayerName(source)
    local license = Player.PlayerData.license or "N/A"
    local cid = Player.PlayerData.citizenid or "N/A"

    local itemList = ""
    for _, item in pairs(Config.StarterItems) do
        itemList = itemList .. string.format("**%s** x%s\n", item.name, item.count)
    end

    local embed = {
        {
            title = "?? Starter Pack Claimed",
            color = 65280, -- Green
            fields = {
                { name = "Player", value = playerName, inline = true },
                { name = "Citizen ID", value = cid, inline = true },
                { name = "License", value = license, inline = false },
                { name = "Items Given", value = itemList, inline = false }
            },
            footer = {
                text = os.date("Claimed on %Y-%m-%d at %H:%M:%S")
            }
        }
    }

    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, "POST", json.encode({
        username = "Starter Pack Logger",
        embeds = embed,
        avatar_url = "https://i.imgur.com/vb4tRWD.png"
    }), { ["Content-Type"] = "application/json" })
end, false)
