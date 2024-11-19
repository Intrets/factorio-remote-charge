local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local item_sounds = require("__base__.prototypes.item_sounds")
local explosion_animations = require("__base__.prototypes.entity.explosion-animations")

require("sound-util")
require("__intrets-lib__.util.math")
require("__intrets-lib__.util.mod_name")

local scaled_big_explosion = explosion_animations.big_explosion()
scaled_big_explosion[1].scale = 2.0
scaled_big_explosion[1].shift = { 0.1875 * 2, -0.75 * 2 - 1 }

local remote_charge_damage_payload = {
    {
        type = "direct",
        action_delivery = {
            type = "instant",
            target_effects = { {
                type = "create-entity",
                entity_name = "remote-charge-explosion",
            } }
        }
    },
    {
        type = "area",
        radius = 10.0,
        action_delivery =
        {
            type = "instant",
            target_effects =
            {
                {
                    type = "damage",
                    damage = { amount = 1000, type = "explosion" }
                }
            }
        }
    },
    {
        type = "area",
        radius = 1.0,
        action_delivery =
        {
            type = "instant",
            target_effects =
            {
                {
                    type = "damage",
                    damage = { amount = 0.1, type = "ground-explosion" }
                }
            }
        }
    },
    {
        type = "direct",
        action_delivery =
        {
            type = "instant",
            target_effects =
            {
                {
                    type = "create-entity",
                    entity_name = "big-scorchmark-tintable",
                    check_buildability = true
                },
                {
                    type = "destroy-cliffs",
                    radius = 5.0,
                },
                {
                    type = "invoke-tile-trigger",
                    repeat_count = 1
                },
            }
        }
    }
}

data:extend({
    {
        type = "damage-type",
        name = "ground-explosion",
    },
    {
        type = "trigger-target-type",
        name = "demolisher",
    },
    {
        type = "explosion",
        name = "remote-charge-explosion",
        icon = "__base__/graphics/icons/land-mine.png",
        flags = { "not-on-map" },
        hidden = true,
        subgroup = "gun-explosions",
        order = "a-a-a",
        height = 0,
        animations = scaled_big_explosion,
        smoke = "smoke-fast",
        smoke_count = 20,
        smoke_slow_down_factor = 1,
        sound = {
            category = "weapon",
            variations = sound_variations("__base__/sound/small-explosion", 5, 0.8),
            priority = 64
        }
    },
    {
        type = "projectile",
        name = "remote-charge-explosion-dummy-capsule",
        flags = { "not-on-map" },
        hidden = true,
        acceleration = 50,
        action = remote_charge_damage_payload
    },
    {
        type = "capsule",
        name = "remote-charge-remote",
        icon = get_mod_namespace() .. "/graphics/icons/remote-charge-remote.png",
        flags = { "only-in-cursor", "not-stackable", "spawnable" },
        capsule_action =
        {
            type = "use-on-self",
            uses_stack = false,
            attack_parameters = {
                type = "projectile",
                activation_type = "activate",
                ammo_category = "capsule",
                cooldown = 30,
                range = 0,
                ammo_type =
                {
                    target_type = "position",
                    action =
                    {
                        type = "direct",
                        action_delivery =
                        {
                            type = "instant",
                            target_effects =
                            {
                                {
                                    type = "damage",
                                    damage = { type = "physical", amount = 0 },
                                    use_substitute = false
                                },
                            }
                        }
                    }
                }
            }
        },
        subgroup = "spawnables",
        order = "b[active-defense]-b[remote-charge]-b[remote]",
        inventory_move_sound = item_sounds.electric_small_inventory_move,
        pick_sound = item_sounds.electric_small_inventory_pickup,
        drop_sound = item_sounds.electric_small_inventory_move,
        stack_size = 1
    },
    {
        type = "shortcut",
        name = "give-remote-charge-remote",
        order = "e[remote-charge-remote]",
        action = "spawn-item",
        localised_name = { "shortcut.make-remote-charge-remote" },
        associated_control_input = "give-remote-charge-remote",
        item_to_spawn = "remote-charge-remote",
        icon = get_mod_namespace().. "/graphics/icons/shortcut-toolbar/mip/remote-charge-remote-x32.png",
        icon_size = 32,
        small_icon = get_mod_namespace().. "/graphics/icons/shortcut-toolbar/mip/remote-charge-remote-x24.png",
        small_icon_size = 24
    },
    {
        type = "custom-input",
        name = "give-remote-charge-remote",
        key_sequence = "ALT + H",
        consuming = "game-only",
        item_to_spawn = "remote-charge-remote",
        action = "spawn-item"
    },
    {
        type = "recipe",
        name = "remote-charge",
        enabled = true,
        energy_required = 20,
        ingredients =
        {
            { type = "item", name = "steel-plate",        amount = 1 },
            { type = "item", name = "battery",            amount = 1 },
            { type = "item", name = "electronic-circuit", amount = 1 },
            { type = "item", name = "explosives",         amount = 100 }
        },
        results = { { type = "item", name = "remote-charge", amount = 1 } }
    },
    {
        type = "item",
        name = "remote-charge",
        icon = "__base__/graphics/icons/land-mine.png",
        subgroup = "defensive-structure",
        order = "f[land-mine]",
        inventory_move_sound = item_sounds.explosive_inventory_move,
        pick_sound = item_sounds.explosive_inventory_pickup,
        drop_sound = item_sounds.explosive_inventory_move,
        place_result = "remote-charge",
        stack_size = 1
    },
    {
        type = "land-mine",
        name = "remote-charge",
        icon = "__base__/graphics/icons/land-mine.png",
        flags =
        {
            "placeable-player",
            "placeable-enemy",
            "player-creation",
            "placeable-off-grid",
            "not-on-map"
        },
        minable = { mining_time = 0.5, result = "remote-charge" },
        fast_replaceable_group = "land-mine",
        mined_sound = sounds.deconstruct_small(1.0),
        max_health = 15,
        trigger_radius = 0,
        timeout = 4294967295,
        create_ghost_on_death = false,
        resistances = { { type = "impact", decrease = 10000, percent = 100 }, { type = "explosion", decrease = 10000, percent = 100 }, { type = "ground-explosion", decrease = 10000, percent = 100 } },
        corpse = "land-mine-remnants",
        collision_box = { { -1.1, -1.1 }, { 1.1, 1.1 } },
        selection_box = { { -1.0, -1.0 }, { 1.0, 1.0 } },
        damaged_trigger_effect = hit_effects.entity(),
        open_sound = sounds.machine_open,
        close_sound = sounds.machine_close,
        picture_safe =
        {
            filename = "__base__/graphics/entity/land-mine/land-mine.png",
            priority = "medium",
            width = 64,
            height = 64,
            scale = 1.0,
            tint = { 0.5, 0.5, 0.5, 1.0 },
        },
        action = remote_charge_damage_payload
    },
})
