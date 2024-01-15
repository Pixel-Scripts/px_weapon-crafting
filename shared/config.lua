Crafting = {}

Crafting = {
    EnableDebug = false,
    XpSystem = false,
    ExperiancePerCraft = 2.5,
    Weapon = {
        ["w_sr_sniperrifle"] = {
            weaponCode = 'WEAPON_SNIPERRIFLE',
            weaponName = 'Sniper Rifle',
            requiredJob = true,
            requiredXp = 10,
            allowlistJob = {
                "police"
            },
            ItemRequired = {
                { itemName = "phone", quantity = 2},
                { itemName = "burger", quantity = 5}
            }
        },
        ["w_pi_pistol"] = {
            weaponCode = 'WEAPON_PISTOL',
            weaponName = 'Pistol',
            requiredJob = true,
            requiredXp = 0,
            allowlistJob = {
                "police"
            },
            ItemRequired = {
                { itemName = "radio", quantity = 1}
            }
        },
        ["w_ar_carbinerifle"] = {
            weaponCode = 'WEAPON_CARBINERIFLE',
            weaponName = 'Carabine Rifle',
            requiredJob = true,
            requiredXp = 1,
            allowlistJob = {
                "ambulance",
            },
            ItemRequired = {
                { itemName = "water", quantity = 1}
            }
        }
    },

    PositionCrafting = {
        {coords = vector3(-16.471076965332, 4.4761486053467, 70.613090515137), heading =165.0}
    }
}