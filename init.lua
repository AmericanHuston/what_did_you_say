local http = core.request_http_api and core.request_http_api() --Needs this for the python stuff
local loadedStamina = core.get_modpath("stamina") ~= nil
local triggers = {
    "apple",
    "bomb",
    "tnt",
    "die",
    "dead",
    "hungry",
    "mob",
    "hole",
    "block",
    "jump",
    "lava",
    "heart",
    "end",
    "night"
} --Trigger words

core.register_on_dieplayer(function(player)
    player:set_properties({hp_max = 20}) --Give back the player their hearts if they die
end)

if http then
    local function loop(period, func) --Timing
        local timer = 0
        core.register_globalstep(function(dtime)
            timer = timer + dtime
            if timer > period then
                func()
                timer = 0
            end
        end)
    end

    local function triggerAction(triggerWord) --Process trigger words/what they do
        local players = core.get_connected_players()
        for _, player in pairs(players) do
            if triggerWord == triggers[1] then
                core.chat_send_all("You look hungry, have an apple!")
                player:get_inventory():add_item("main", "default:apple")
            elseif triggerWord == triggers[2] or triggerWord == triggers[3] then
                local spawned = 0
                core.chat_send_all("Spawning TNT")
                repeat
                    core.set_node(player:get_pos(), {name = "tnt:tnt_burning"})
                    spawned = spawned + 1
                until spawned == 20
            elseif triggerWord == triggers[4] or triggerWord == triggers[5] then
                core.chat_send_all("Now you're dead")
                player:set_hp(0, "what_did_you_say mod killed you")
            elseif triggerWord == triggers[6] then
                core.chat_send_all("Lets eat, they said. It'll be fun, they said.")
                if loadedStamina then
                    stamina.set_saturation(player, 0)
                end
            elseif triggerWord == triggers[7] then
                core.add_entity(player:get_pos(), "mobs_monster:dirt_monster", nil)
            elseif triggerWord == triggers[8] then
                core.chat_send_all("Digging you a hole")
                local pos = player:get_pos()
                for i = 1, 40, 1 do
                    core.remove_node({x = pos.x - 1, y = pos.y - i, z = pos.z})
                    core.remove_node({x = pos.x, y = pos.y - i, z = pos.z})
                    core.remove_node({x = pos.x + 1, y = pos.y - i, z = pos.z})

                    core.remove_node({x = pos.x - 1, y = pos.y - i, z = pos.z - 1})
                    core.remove_node({x = pos.x, y = pos.y - i, z = pos.z - 1})
                    core.remove_node({x = pos.x + 1, y = pos.y - i, z = pos.z - 1})

                    core.remove_node({x = pos.x - 1, y = pos.y - i, z = pos.z + 1})
                    core.remove_node({x = pos.x, y = pos.y - i, z = pos.z + 1})
                    core.remove_node({x = pos.x + 1, y = pos.y - i, z = pos.z + 1})
                end
            elseif triggerWord == triggers[9] then
                core.chat_send_all("We use the word node around here, partner *tips fedora*")
                local pos = player:get_pos()
                    for i = 1, 40, 1 do
                    core.set_node({x = pos.x - 1, y = pos.y + i, z = pos.z}, {name = "default:obsidian"})
                    core.set_node({x = pos.x, y = pos.y + i, z = pos.z}, {name = "default:obsidian"})
                    core.set_node({x = pos.x + 1, y = pos.y + i, z = pos.z}, {name = "default:obsidian"})

                    core.set_node({x = pos.x - 1, y = pos.y + i, z = pos.z - 1}, {name = "default:obsidian"})
                    core.set_node({x = pos.x, y = pos.y + i, z = pos.z - 1}, {name = "default:obsidian"})
                    core.set_node({x = pos.x + 1, y = pos.y + i, z = pos.z - 1}, {name = "default:obsidian"})

                    core.set_node({x = pos.x - 1, y = pos.y + i, z = pos.z + 1}, {name = "default:obsidian"})
                    core.set_node({x = pos.x, y = pos.y + i, z = pos.z + 1}, {name = "default:obsidian"})
                    core.set_node({x = pos.x + 1, y = pos.y + i, z = pos.z + 1}, {name = "default:obsidian"})
                end
            elseif triggerWord == triggers[10] then
                core.chat_send_all("Sending you for a short flight")
                local pos = player:get_pos()
                player:set_pos({x = pos.x, y = pos.y + 100, z = pos.z})
            elseif triggerWord == triggers[11] then
                core.chat_send_all("Wow... this is a very warm pool")
                core.set_node(player:get_pos(), {name = "default:lava_source"})
            elseif triggerWord == triggers[12] then
                core.chat_send_all("Removing hearts")
                player:set_properties({hp_max = 4})
                player:set_hp(4, "Player lost hearts (what_did_you_say)")
            elseif triggerWord == triggers[13] then
                core.chat_send_all("This is the end for us all")
                player:set_hp(0)
            elseif triggerWord == triggers[14] then
                core.chat_send_all("Now its night time")
                core.set_timeofday(0)
            end
        end
    end

    core.register_chatcommand("event", {
        func = function (name, param)
            triggerAction(triggers[tonumber(param)])
        end
    })

    -- core.register_on_joinplayer(function(player, last_login)
    --     core.after(2, function ()
    --         for i, value in ipairs(triggers) do
    --             core.chat_send_all("Running testcase " .. value)
    --             triggerAction(value)
    --         end
    --     end)
    -- end)

    loop(1, function () --Check for new trigger words
        http.fetch({ url = "http://localhost:5000/get-words" }, function(response)
            for index, value in ipairs(triggers) do
                local first, last = string.find(response.data, value)
                if first ~= nil and last ~= nil then
                    local word = string.sub(response.data, first, last)
                    triggerAction(word)
                end
            end
        end)
    end)
else
    core.chat_send_all("Mod what_did_you_say couldn't use Luanti's http! Check README.txt in mod files!")
end