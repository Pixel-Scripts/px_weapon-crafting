# px_weapon-crafting


Simple weapon crafting system with XP system and job control

Frameworks
- ESX
Features
EnableDebug: A boolean flag indicating whether debugging is enabled for the crafting system.
XpSystem: A boolean flag indicating activate the experience system for crafting weapons.
ExperiancePerCraft: The amount of experience gained per craft in the crafting system.
Weapon: A set of definitions for different weapons in the game, each with details such as weapon code, name, job requirements, required experience, an allowed job list, and items required for crafting.
For example, the sniper rifle requires the police job, 10 experience points, and 2 iron and 5 copper for crafting.
PositionCrafting: A list of locations in the game where you can craft, defined by coordinates and direction.
