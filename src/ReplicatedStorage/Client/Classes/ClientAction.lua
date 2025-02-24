--!strict
-- This module represents an action on the client side. 
-- Client actions are intended to only capture real player actions, like mouse location and keybind presses.
-- Do not use a ClientAction to directly handle tasks that are more for the server, like updating scores or contestant health.
-- 
-- Programmers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Actions = ReplicatedStorage.Client.Classes.Actions;
local BeastSlashClientAction = require(Actions.BeastSlashClientAction);
local ChangeBallTypeClientAction = require(Actions.ChangeBallTypeClientAction);
local ChangeModesClientAction = require(Actions.ChangeModesClientAction);
local DetachLimbClientAction = require(Actions.DetachLimbClientAction);
local DetonateDetachedLimbsClientAction = require(Actions.DetonateDetachedLimbsClientAction);
local DiveBombClientAction = require(Actions.DiveBombClientAction);
local ExplosivePunchClientAction = require(Actions.ExplosivePunchClientAction);

local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local ClientAction = {};

function ClientAction.get(actionID: string): SharedTypes.ClientActionClass

  local actions = {
    BeastSlash = BeastSlashClientAction;
    ChangeBallType = ChangeBallTypeClientAction;
    ChangeModes = ChangeModesClientAction;
    DetachLimb = DetachLimbClientAction;
    DetonateDetachedLimbs = DetonateDetachedLimbsClientAction;
    DiveBomb = DiveBombClientAction;
    ExplosivePunch = ExplosivePunchClientAction;
  };

  local action = actions[actionID];
  
  if not action then

    error(`{actionID} client action couldn't be found.`);

  end;

  return action;

end;

return ClientAction;