--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents an Archetype, which contains a list of powers.
local ServerContestant = require(script.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerAction = require(script.Parent.ServerAction);
type ServerAction = ServerAction.ServerAction;

export type ServerArchetypeProperties = {
  
  ID: number;
  
  name: string;

  description: string?;

  type: "Fighter" | "Defender" | "Destroyer" | "Supporter";

  actionIDs: {number};
  
}

export type ServerArchetypeMethods = {

  breakdown: (self: ServerArchetype) -> ();

  runAutoPilot: (self: ServerArchetype, actions: {ServerAction}) -> ();

}

local ServerArchetype = {}

export type ServerArchetype = ServerArchetypeProperties & ServerArchetypeMethods;

export type ServerArchetypeClass = ServerArchetypeProperties & {new: (...any) -> ServerArchetype};

function ServerArchetype.new(properties: ServerArchetypeProperties): ServerArchetype

  return properties :: ServerArchetype;
  
end

function ServerArchetype.get(archetypeID: number): ServerArchetypeClass

  for _, instance in ipairs(script.Parent.Archetypes:GetChildren()) do
  
    if instance:IsA("ModuleScript") then
  
      local archetype = require(instance) :: any;
      if archetype.ID == archetypeID then
  
        return archetype;
  
      end;
  
    end
  
  end;

  error(`Couldn't find archetype from ID {archetypeID}.`);

end;

function ServerArchetype.getAll(): {ServerArchetypeClass}

  local archetypes = {};
  
  for _, instance in ipairs(script.Parent.Archetypes:GetChildren()) do
  
    if instance:IsA("ModuleScript") then
  
      local archetype = require(instance) :: any;
      table.insert(archetypes, archetype);
  
    end
  
  end;

  return archetypes;

end;

return ServerArchetype;