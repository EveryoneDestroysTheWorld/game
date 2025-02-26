--!strict
-- This module represents a Action.
-- 
-- Programmers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local ServerAction: types.ServerActionFactory = {} :: types.ServerActionFactory;

function ServerAction.get(actionID: string): types.ServerActionClass

  local instance = script.Parent.Actions:FindFirstChild(`{actionID}ServerAction`);
  if instance and instance:IsA("ModuleScript") then

    local action = require(instance) :: any;
    return action;

  end

  error(`Couldn't find action from ID {actionID}.`);

end;

return ServerAction;
