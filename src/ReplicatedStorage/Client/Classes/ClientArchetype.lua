--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents an Archetype, which contains a list of powers.

export type ClientArchetypeProperties = {
  
  ID: number;
  
  name: string;

  description: string?;

  type: "Fighter" | "Defender" | "Destroyer" | "Supporter";

  iconImage: string;

  actionIDs: {number};

  breakdown: (self: ClientArchetype) -> ();
  
  initialize: (self: ClientArchetype) -> ();
  
}

local ClientArchetype = {}

export type ClientArchetype = ClientArchetypeProperties;

function ClientArchetype.new(properties: ClientArchetypeProperties): ClientArchetype

  return properties;
  
end

function ClientArchetype.get(archetypeID: number): ClientArchetype

  for _, instance in ipairs(script.Parent.Archetypes:GetChildren()) do
  
    if instance:IsA("ModuleScript") then
  
      local archetype = require(instance) :: any;
      if archetype.ID == archetypeID then
  
        return archetype.new();
  
      end;
  
    end
  
  end;

  error(`Couldn't find archetype from ID {archetypeID}.`);

end;

return ClientArchetype;