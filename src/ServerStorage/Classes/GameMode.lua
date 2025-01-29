--!strict
-- This class represents a game mode on the server side.
--
-- Programmers: Christian Toney (Christian_Toney)

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local GameMode = {};

function GameMode.new(properties: types.GameModeProperties): types.GameMode

  return properties :: types.GameMode;
  
end

function GameMode.get(gameModeID: string): types.GameModeClass

  for _, instance in ipairs(script.Parent.GameModes:GetChildren()) do
  
    if instance:IsA("ModuleScript") then
  
      local gameMode = require(instance) :: any;
      if gameMode.id == gameModeID then
  
        return gameMode;
  
      end;
  
    end
  
  end;

  error(`Couldn't find game mode from ID {gameModeID}.`);

end;

return GameMode;