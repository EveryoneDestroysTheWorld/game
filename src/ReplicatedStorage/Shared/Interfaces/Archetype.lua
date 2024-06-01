--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents an Archetype, which contains a list of powers.
local Action = require(script.Parent.Parent.Classes.Action);

export type Archetype = {
  
  -- The stage's unique ID.
  ID: number;
  
  name: string;

  description: string?;

  type: "Fighter" | "Defender" | "Destroyer" | "Supporter";

  powers: {typeof(setmetatable({}, Action))};
  
}

return {};