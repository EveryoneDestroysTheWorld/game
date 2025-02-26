--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientArchetype = require(ReplicatedStorage.Client.Interfaces.IClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;

local BatterUpDemonClientArchetype = {
  id = script.Name:sub(1, script.Name:gsub("ClientArchetype", ""):len());
  name = "Batter-Up Demon";
  description = "You'll never strike out with this one.";
  iconImage = "rbxassetid://18584519829";
  actionIDs = {
    "StrikeOutSwipe", -- Only available in batter mode
    "HeresThePitch", "ChangeBallType", -- Only available in pitcher mode
    "ChangeModes" -- Global
  };
  type = "Fighter" :: "Fighter";
};

function BatterUpDemonClientArchetype.new(): ClientArchetype

  local archetype: ClientArchetype = {
    id = BatterUpDemonClientArchetype.id;
    iconImage = BatterUpDemonClientArchetype.iconImage;
    name = BatterUpDemonClientArchetype.name;
    description = BatterUpDemonClientArchetype.description;
    actionIDs = BatterUpDemonClientArchetype.actionIDs;
    type = BatterUpDemonClientArchetype.type;
    breakdown = function(self: ClientArchetype)

      

    end;
  };

  return archetype;

end;

return BatterUpDemonClientArchetype;