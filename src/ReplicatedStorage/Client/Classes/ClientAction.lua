--!strict
-- This module represents an action on the client side. 
-- Client actions are intended to only capture real player actions, like mouse location and keybind presses.
-- Do not use a ClientAction to directly handle tasks that are more for the server, like updating scores or contestant health.
-- 
-- Programmers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local types = require(ReplicatedStorage.Client.Modules.types);

local ClientAction = {};

function ClientAction.get(actionID: string): types.ClientActionClass

  local instance = script.Parent.Actions:FindFirstChild(`{actionID}ClientAction`);
  if instance and instance:IsA("ModuleScript") then

    local action = require(instance) :: any;
    return action;

  end

  error(`Couldn't find action from ID {actionID}.`);

end;

return ClientAction;