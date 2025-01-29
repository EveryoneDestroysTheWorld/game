--!strict
-- This module represents a Action.
-- 
-- Programmers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local ServerAction = {};

function ServerAction.get(actionID: string): types.ServerActionClass

  local instance = script.Parent.Actions:FindFirstChild(`{actionID}ServerAction`);
  if instance and instance:IsA("ModuleScript") then

    local effect = require(instance) :: any;
    return effect;

  end

  error(`Couldn't find action from ID {actionID}.`);

end;

return ServerAction;
