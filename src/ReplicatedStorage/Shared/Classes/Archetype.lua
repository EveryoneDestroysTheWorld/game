--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents an Archetype, which contains a list of powers.
local Power = require(script.Parent.Power);

type Power = Power.Power;

export type Archetype = {
  
  -- The stage's unique ID.
  ID: string;
  
  name: string;

  description: string?;

  powers: {Power};
  
}

return {};