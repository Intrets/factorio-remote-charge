if mods["space-age"] ~= nil then
    local function add_ground_explosion_vulnerability(prototype)
        prototype.resistances = prototype.resistances or {}
        table.insert(prototype.resistances, { type = "ground-explosion", decrease = -5000, percent = -500 })
    end

    for name, prototype in pairs(data.raw.segment) do
        local demolisher_segment = (string.match(name, "small%-demolisher%-segment%-x0_%d+") or string.match(name, "medium%-demolisher%-segment%-x0_%d+") or string.match(name, "big%-demolisher%-segment%-x0_%d+")) ~= nil

        if demolisher_segment then
            add_ground_explosion_vulnerability(prototype)
        end
    end
end
