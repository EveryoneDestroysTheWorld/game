--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents an Archetype, which contains a list of powers.

export type ServerArchetypeProperties = {
  
  ID: number;
  
  name: string;

  description: string?;

  type: "Fighter" | "Defender" | "Destroyer" | "Supporter";

  actionIDs: {number};

  breakdown: (self: ServerArchetype) -> ();
  
}

local ServerArchetype = {}

export type ServerArchetype = ServerArchetypeProperties;

function ServerArchetype.new(properties: ServerArchetypeProperties): ServerArchetype

  return properties;
  
end

function ServerArchetype.get(archetypeID: number): ServerArchetype

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

return ServerArchetype;