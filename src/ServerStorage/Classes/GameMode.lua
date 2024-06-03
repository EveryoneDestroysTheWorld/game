--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents a Action.
export type GameModeProperties<T = {}, S = {
  [number]: {
    [string]: number;
  };
}> = {
  
  -- The stage's unique ID.
  ID: number;
  
  name: string;

  description: string;

  stats: S;
  
} & T;

export type GameModeMethods<T> = {
  start: (self: T, stageModel: Model) -> ();
  breakdown: (self: T) -> ();
  toString: (self: T) -> string;
}

local GameMode = {
  __index = {};
};

export type GameMode<T, S> = typeof(setmetatable({}, {__index = GameMode.__index})) & T & GameModeMethods<T>;

function GameMode.new<T, S>(properties: GameModeProperties<T, S>): GameMode<T, S>

  return setmetatable(properties :: {}, {__index = GameMode.__index}) :: GameMode<T, S>;
  
end

return GameMode;