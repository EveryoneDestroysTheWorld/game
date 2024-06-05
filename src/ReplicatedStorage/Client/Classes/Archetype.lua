--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents an Archetype, which contains a list of powers.

export type ArchetypeProperties = {
  
  ID: number;
  
  name: string;

  description: string?;

  type: "Fighter" | "Defender" | "Destroyer" | "Supporter";

  actionIDs: {number};

  breakdown: (self: Archetype) -> ();
  
}

local Archetype = {}

export type Archetype = ArchetypeProperties;

function Archetype.new(properties: ArchetypeProperties): Archetype

  return properties;
  
end

function Archetype.get(archetypeID: number): Archetype

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

return Archetype;