--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents a Action.
export type GameModeProperties = {
  
  -- The stage's unique ID.
  ID: number;
  
  name: string;

  description: string;

  start: (self: GameMode) -> ();

  breakdown: (self: GameMode) -> ();

  toString: (self: GameMode) -> string;
  
};

local GameMode = {};

export type GameMode = GameModeProperties;

export type GameModeClass = GameModeProperties & {new: (...any) -> GameMode};

function GameMode.new(properties: GameModeProperties): GameMode

  return properties :: GameMode;
  
end

function GameMode.get(gameModeID: number): GameModeClass

  for _, instance in ipairs(script.Parent.GameModes:GetChildren()) do
  
    if instance:IsA("ModuleScript") then
  
      local gameMode = require(instance) :: any;
      if gameMode.ID == gameModeID then
  
        return gameMode;
  
      end;
  
    end
  
  end;

  error(`Couldn't find game mode from ID {gameModeID}.`);

end;

return GameMode;