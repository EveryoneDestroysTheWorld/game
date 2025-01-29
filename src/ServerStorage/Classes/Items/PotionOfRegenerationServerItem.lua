--!strict
-- This module represents a Potion of Regeneration on the server side. 
-- 
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: InkyTheBlue (InkyTheBlue)
-- © 2024 – 2025 Beastslash

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ServerItem = require(script.Parent.Parent.ServerItem);
local PotionOfRegenerationClientItem = require(ReplicatedStorage.Client.Classes.Items.PotionOfRegenerationClientItem);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local HttpService = game:GetService("HttpService");
local ServerEffect = require(ServerStorage.Classes.ServerEffect);
local types = require(ServerStorage.Modules.types);

local PotionOfRegenerationServerItem = {
  id = PotionOfRegenerationClientItem.id;
  name = PotionOfRegenerationClientItem.name;
  description = PotionOfRegenerationClientItem.description;
};

function PotionOfRegenerationServerItem.new(): types.ServerItem

  local _specificItemID: string?;
  local contestant: types.ServerContestant;
  local remoteFunction: RemoteFunction?;

  local function activate(self: types.ServerItem)

    contestant:removeItem(self);

    local regenerationEffect = ServerEffect.get("Regeneration").new({
      contestant = contestant;
      rateSeconds = 1;
      maxRegenerations = 3;
    });
    contestant:addEffect(regenerationEffect);
    
  end;
  
  local function breakdown(self: types.ServerItem)

    if remoteFunction then

      remoteFunction:Destroy();

    end;

    if contestant.player then

      ReplicatedStorage.Shared.Functions.BreakdownItem:InvokeClient(contestant.player, self.id, _specificItemID);

    end;
    
  end;

  local function initialize(self: types.ServerItem, newContestant: types.ServerContestant)

    contestant = newContestant;

    if contestant.player then

      local specificItemID = HttpService:GenerateGUID(false);
      _specificItemID = specificItemID;
      remoteFunction = createInventoryRemoteFunction(contestant.player, specificItemID, function()
      
        self:activate();

      end);

      ReplicatedStorage.Shared.Functions.InitializeItem:InvokeClient(contestant.player, self.id, specificItemID);

    end;

  end;

  local item = ServerItem.new({
    id = PotionOfRegenerationServerItem.id;
    name = PotionOfRegenerationServerItem.name;
    description = PotionOfRegenerationServerItem.description;
    activate = activate;
    breakdown = breakdown;
    initialize = initialize;
  });
  
  return item;

end;

return PotionOfRegenerationServerItem;
