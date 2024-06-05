--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents an Archetype, which contains a list of powers.

export type ContestantProperties = {
  
  player: Player?;

  character: Model?
  
}

local Contestant = {
  __index = {};
};

export type Contestant = typeof(setmetatable({} :: ContestantProperties, Contestant));

function Contestant.new(properties: ContestantProperties): Contestant

  return setmetatable(properties, Contestant);
  
end

return Contestant;