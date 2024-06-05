--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents a Action.
export type GameModeProperties = {
  
  -- The stage's unique ID.
  ID: number;
  
  name: string;

  description: string;
  
};

export type GameModeMethods<GameMode> = {
  start: (self: GameMode, stageModel: Model) -> ();
  breakdown: (self: GameMode) -> ();
  toString: (self: GameMode) -> string;
}

local GameMode = {
  __index = {} :: GameModeProperties;
};

export type GameMode = typeof(setmetatable({}, GameMode));

function GameMode.new(properties: GameModeProperties): GameMode

  return setmetatable(properties, GameMode);
  
end

return GameMode;