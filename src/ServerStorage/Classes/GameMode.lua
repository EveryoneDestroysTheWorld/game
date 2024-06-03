--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents a Action.
export type GameModeProperties<T = {}> = {
  
  -- The stage's unique ID.
  ID: number;
  
  name: string;

  description: string;
  
} & T;

export type GameModeMethods<T> = {
  start: (self: T, stageModel: Model) -> ();
  breakdown: (self: T) -> ();
}

local GameMode = {
  __index = {};
};

export type GameMode<T> = typeof(setmetatable({}, {__index = GameMode.__index})) & GameModeProperties<T> & GameModeMethods<T>;

function GameMode.new<T>(properties: GameModeProperties<T>): GameMode<T>

  local action = properties;

  return setmetatable(action :: {}, {__index = GameMode.__index}) :: GameMode<T>;
  
end

return GameMode;