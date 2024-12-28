--!strict
-- This module represents a Potion of Regeneration on the server side. 
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: InkyTheBlue (InkyTheBlue)
-- © 2024 Beastslash

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ServerContestant = require(script.Parent.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerItem = require(script.Parent.Parent.ServerItem);
type ServerItem = ServerItem.ServerItem;
local PotionOfRegenerationClientItem = require(ReplicatedStorage.Client.Classes.Items.PotionOfRegenerationClientItem);
local ServerRound = require(script.Parent.Parent.ServerRound);
type ServerRound = ServerRound.ServerRound;
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);

local PotionOfRegenerationServerItem = {
  ID = PotionOfRegenerationClientItem.ID;
  name = PotionOfRegenerationClientItem.name;
  description = PotionOfRegenerationClientItem.description;
};

function PotionOfRegenerationServerItem.new(): ServerItem

  local contestant: ServerContestant;
  local shouldHeal = true;
  local remoteFunction: RemoteFunction?;
  local itemNumber: number = 1;

  local function activate(self: ServerItem)

    for currentSecond = 1, 3 do

      task.wait(1);

      if shouldHeal then

        contestant:updateHealth(math.min(contestant.baseHealth, contestant.currentHealth + 10));

      end;

    end;
    
    contestant:removeItemFromInventory(self);
    
  end;
  
  local function breakdown(self: ServerItem)

    shouldHeal = false;

    if contestant.player then

      ReplicatedStorage.Shared.Functions.BreakdownItem:InvokeClient(contestant.player, self.ID, itemNumber);

    end;

    if remoteFunction then

      remoteFunction:Destroy();

    end;
    
  end;

  local function initialize(self: ServerItem, newContestant: ServerContestant)

    contestant = newContestant;

    if contestant.player then

      remoteFunction, itemNumber = createInventoryRemoteFunction(contestant.player, self.ID, function()
      
        self:activate();

      end);

      ReplicatedStorage.Shared.Functions.InitializeItem:InvokeClient(contestant.player, self.ID, itemNumber);

    end;

  end;

  local item = ServerItem.new({
    ID = PotionOfRegenerationServerItem.ID;
    name = PotionOfRegenerationServerItem.name;
    description = PotionOfRegenerationServerItem.description;
    activate = activate;
    breakdown = breakdown;
    initialize = initialize;
  });
  
  return item;

end;

return PotionOfRegenerationServerItem;
