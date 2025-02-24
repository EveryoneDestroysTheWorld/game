--!strict
-- This module represents an action on the client side. 
-- Client actions are intended to only capture real player actions, like mouse location and keybind presses.
-- Do not use a ClientAction to directly handle tasks that are more for the server, like updating scores or contestant health.
-- 
-- Programmers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local BeastSlashClientAction = require(ReplicatedStorage.Client.Classes.Actions.BeastSlashClientAction);
local ChangeBallTypeClientAction = require(ReplicatedStorage.Client.Classes.Actions.ChangeBallTypeClientAction);
local ChangeModesClientAction = require(ReplicatedStorage.Client.Classes.Actions.ChangeModesClientAction);
local DetachLimbClientAction = require(ReplicatedStorage.Client.Classes.Actions.DetachLimbClientAction);
local DetonateDetachedLimbsClientAction = require(ReplicatedStorage.Client.Classes.Actions.DetonateDetachedLimbsClientAction);

local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local ClientAction = {};

function ClientAction.get(actionID: string): SharedTypes.ClientActionClass

  local actions = {
    BeastSlash = BeastSlashClientAction;
    ChangeBallType = ChangeBallTypeClientAction;
    ChangeModes = ChangeModesClientAction;
    DetachLimb = DetachLimbClientAction;
    DetonateDetachedLimbs = DetonateDetachedLimbsClientAction;
  };

  local action = actions[actionID];
  
  if not action then

    error(`{actionID} client action couldn't be found.`);

  end;

  return action;

end;

return ClientAction;