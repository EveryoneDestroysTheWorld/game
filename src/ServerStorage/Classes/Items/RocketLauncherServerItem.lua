--!strict
-- This module represents a Rocket Launcher on the server side. 
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 Beastslash

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerItem = require(script.Parent.Parent.ServerItem);
local RocketLauncherClientItem = require(ReplicatedStorage.Client.Classes.Items.RocketLauncherClientItem);
local HttpService = game:GetService("HttpService");
local ServerStorage = game:GetService("ServerStorage");
local ServerEffect = require(ServerStorage.Classes.ServerEffect);
local types = require(ServerStorage.Modules.types);

local RocketLauncherServerItem = {
  id = RocketLauncherClientItem.id;
  name = RocketLauncherClientItem.name;
  description = RocketLauncherClientItem.description;
};

function RocketLauncherServerItem.new(contestant: types.ServerContestant, round: types.ServerRound): types.ServerItem

  local _specificItemID;
  local isEquipped = false;
  local effect = ServerEffect.get("HoldingHeavyItem").new({
    contestant = contestant;
  });

  local function activate(self: types.ServerItem)
    
    if not isEquipped then

      -- Lock archetypes and actions.
      isEquipped = true;

      contestant:addEffect(effect);

    end;
    
  end;
  
  local function breakdown(self: types.ServerItem)
    
    if contestant.player then

      ReplicatedStorage.Shared.Functions.BreakdownItem:InvokeClient(contestant.player, self.id, _specificItemID);

    end;

    contestant:removeEffect(effect);

  end;

  local function initialize(self: types.ServerItem, newContestant: types.ServerContestant)

    contestant = newContestant;

    local specificItemID = HttpService:GenerateGUID(false);
    _specificItemID = specificItemID;

    if contestant.player then

      ReplicatedStorage.Shared.Functions.InitializeItem:InvokeClient(contestant.player, self.id, specificItemID);

    end;

  end;

  local item = ServerItem.new({
    id = RocketLauncherServerItem.id;
    name = RocketLauncherServerItem.name;
    description = RocketLauncherServerItem.description;
    activate = activate;
    breakdown = breakdown;
    initialize = initialize;
  });
  
  return item;

end;

return RocketLauncherServerItem;
