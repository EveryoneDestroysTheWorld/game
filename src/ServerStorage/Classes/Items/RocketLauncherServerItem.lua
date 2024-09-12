--!strict
-- This module represents a Rocket Launcher on the server side. 
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 Beastslash

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerContestant = require(script.Parent.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerItem = require(script.Parent.Parent.ServerItem);
type ServerItem = ServerItem.ServerItem;
local RocketLauncherClientItem = require(ReplicatedStorage.Client.Classes.Items.RocketLauncherClientItem);
local ServerRound = require(script.Parent.Parent.ServerRound);
type ServerRound = ServerRound.ServerRound;

local RocketLauncherServerItem = {
  ID = RocketLauncherClientItem.ID;
  name = RocketLauncherClientItem.name;
  description = RocketLauncherClientItem.description;
};

function RocketLauncherServerItem.new(contestant: ServerContestant, round: ServerRound): ServerItem

  local function activate(self: ServerItem)
    
    
  end;
  
  local function breakdown(self: ServerItem)
    
    if contestant.player then

      ReplicatedStorage.Shared.Functions.BreakdownItem:InvokeClient(contestant.player, self.ID);

    end;

  end;

  local function initialize(self: ServerItem, newContestant: ServerContestant)

    contestant = newContestant;

    if contestant.player then

      ReplicatedStorage.Shared.Functions.InitializeItem:InvokeClient(contestant.player, self.ID);

    end;

  end;

  local item = ServerItem.new({
    ID = RocketLauncherServerItem.ID;
    name = RocketLauncherServerItem.name;
    description = RocketLauncherServerItem.description;
    activate = activate;
    breakdown = breakdown;
    initialize = initialize;
  });
  
  return item;

end;

return RocketLauncherServerItem;
