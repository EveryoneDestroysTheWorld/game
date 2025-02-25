--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents an Archetype, which contains a list of powers.

export type ClientArchetypeProperties = {
  
  id: string;
  
  name: string;

  description: string?;

  type: "Fighter" | "Defender" | "Destroyer" | "Supporter";

  iconImage: string;

  actionIDs: {string};

  breakdown: (self: ClientArchetype) -> ();
  
}

local ClientArchetype = {}

export type ClientArchetype = ClientArchetypeProperties;

function ClientArchetype.get(archetypeID: string): ClientArchetype

  for _, instance in ipairs(script.Parent.Archetypes:GetChildren()) do
  
    if instance:IsA("ModuleScript") then
  
      local archetype = require(instance) :: any;
      if archetype.id == archetypeID then
  
        return archetype.new();
  
      end;
  
    end
  
  end;

  error(`Couldn't find archetype from ID {archetypeID}.`);

end;

return ClientArchetype;