--!strict
-- This module represents a Potion of Regeneration on the server side. 
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: InkyTheBlue (InkyTheBlue)
-- © 2024 Beastslash

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerContestant = require(script.Parent.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerItem = require(script.Parent.Parent.ServerItem);
type ServerItem = ServerItem.ServerItem;
local PotionOfRegenerationClientItem = require(ReplicatedStorage.Client.Classes.Items.PotionOfRegenerationClientItem);
local ServerRound = require(script.Parent.Parent.ServerRound);
type ServerRound = ServerRound.ServerRound;

local PotionOfRegenerationServerItem = {
  ID = PotionOfRegenerationClientItem.ID;
  name = PotionOfRegenerationClientItem.name;
  description = PotionOfRegenerationClientItem.description;
};

function PotionOfRegenerationServerItem.new(contestant: ServerContestant, round: ServerRound): ServerItem

  local function activate(self: ServerItem)
    
    
  end;
  
  local function breakdown()
    
  end;

  local item = ServerItem.new({
    ID = PotionOfRegenerationServerItem.ID;
    name = PotionOfRegenerationServerItem.name;
    description = PotionOfRegenerationServerItem.description;
    activate = activate;
    breakdown = breakdown;
  });
  
  return item;

end;

return PotionOfRegenerationServerItem;
