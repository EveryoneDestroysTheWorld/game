--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents a Action.
export type GameModeProperties = {
  
  -- The stage's unique ID.
  ID: number;
  
  name: string;

  description: string;

  start: (self: GameMode, stageModel: Model) -> ();

  breakdown: (self: GameMode) -> ();

  toString: (self: GameMode) -> string;
  
};

local GameMode = {};

export type GameMode = GameModeProperties;

function GameMode.new(properties: GameModeProperties): GameMode

  return properties :: GameMode;
  
end

return GameMode;