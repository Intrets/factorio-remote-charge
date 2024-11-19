require("__intrets-lib__.util.math")
require("__intrets-lib__.rework-control")

local detonation_time_interval_milliseconds = { min = 30, max = 120 }
local get_detonation_trigger = function()
    return math.random(detonation_time_interval_milliseconds.min,
        detonation_time_interval_milliseconds.max)
end

rework_control.on_init("init remote charge", function()
    storage.detonation_list = {}
    storage.detonation_index = 1
    storage.detonation_list_end = 1

    storage.detonation_timer = 0
    storage.detonation_trigger = 300
end)

rework_control.on_event(
    "remote charge remote trigger",
    defines.events.on_player_used_capsule, function(event)
        local player = game.players[event.player_index]
        if player == nil then return end

        local surface = player.surface
        if surface == nil then return end

        local entities = surface.find_entities_filtered {
            area = rmath.bounding_box_from_position_and_size(
                event.position,
                rmath.vec2(200, 200)
            ),
            name = "remote-charge"
        }

        total = 0
        storage.detonation_list = {}
        storage.detonation_index = 1
        storage.detonation_list_end = 1
        for _, remote_charge in pairs(entities) do
            storage.detonation_list[storage.detonation_list_end] = remote_charge
            storage.detonation_list_end = storage.detonation_list_end + 1
            storage.detonation_trigger = get_detonation_trigger()
            storage.detonation_timer = 0
        end

        table.sort(storage.detonation_list, function(left, right) return left.unit_number < right.unit_number end)
    end)

rework_control.on_event(
    "remote charge detonation",
    defines.events.on_tick,
    function(event)
        if storage.detonation_list_end ~= storage.detonation_index then
            storage.detonation_timer = storage.detonation_timer + 16.6666
            if storage.detonation_timer > storage.detonation_trigger then
                storage.detonation_timer = storage.detonation_timer - storage.detonation_trigger
                storage.detonation_trigger = get_detonation_trigger()

                local try_detonate = function(index)
                    if index == storage.detonation_list_end then
                        return false
                    end

                    local remote_charge = storage.detonation_list[index]

                    if not remote_charge.valid then
                        return false
                    end

                    remote_charge.surface.create_entity {
                        name = "remote-charge-explosion-dummy-capsule",
                        position = remote_charge.position,
                        force = "neutral",
                        target = remote_charge
                    }
                    remote_charge.destroy()

                    return true
                end

                for i = storage.detonation_index, storage.detonation_list_end do
                    if try_detonate(i) then
                        storage.detonation_index = i
                        return
                    end
                end

                if storage.detonation_index == storage.detonation_list_end then
                    storage.detonation_list = {}
                    storage.detonation_index = 1
                    storage.detonation_list_end = 1
                end
            end
        end
    end)
