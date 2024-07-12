--!strict
-- Profile.lua
-- Written by Christian "Sudobeast" Toney
-- This module is a class that represents a player profile.

local DataStoreService = game:GetService("DataStoreService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local DataStore = {
  PlayerMetadata = DataStoreService:GetDataStore("PlayerMetadata");
  Inventory = DataStoreService:GetDataStore("Inventory");
}
local Players = game:GetService("Players");
local HttpService = game:GetService("HttpService");
local Stage = require(script.Parent.Stage);

type ProfileProperties = {
  
  -- [Properties]
  -- The player's ID.
  ID: number;

  timeFirstPlayed: number;

  timeLastPlayed: number;
  
}

local Profile = {
  __index = {};
};

export type Profile = typeof(setmetatable({}, {__index = Profile.__index})) & ProfileProperties;

-- Returns a new Player object.
function Profile.new(properties: {[string]: any}): Profile
  
  local player = {
    ID = properties.ID;
    timeFirstPlayed = properties.timeFirstPlayed;
    timeLastPlayed = properties.timeLastPlayed;
  };
  setmetatable(player, {__index = Profile.__index});

  return player :: any;
  
end

-- Returns a Player object based on the ID.
function Profile.fromID(playerID: number, createIfNotFound: boolean?): Profile
  
  local playerData = DataStore.PlayerMetadata:GetAsync(playerID);
  if not playerData and createIfNotFound then

    local playTime = DateTime.now().UnixTimestampMillis;
    playerData = HttpService:JSONEncode({
      ID = playerID;
      timeFirstPlayed = playTime;
      timeLastPlayed = playTime;
    });
    DataStore.PlayerMetadata:SetAsync(playerID, playerData, {playerID});

  end;
  assert(playerData, `Player {playerID} not found.`);
  
  return Profile.new(HttpService:JSONDecode(playerData));
  
end

-- Deletes all player data.
function Profile.__index:delete(): ()

end;

-- Creates a stage on behalf of the player.
function Profile.__index:createStage(): Stage.Stage

  local timeCreated = DateTime.now().UnixTimestampMillis;
  local stage = Stage.new({
    name = "Unnamed Stage";
    timeUpdated = timeCreated;
    timeCreated = timeCreated;
    description = "";
    isPublished = false;
    permissionOverrides = {};
    members = {
      {
        ID = self.ID;
        role = "Admin";
      }
    };
  });

  stage:updateMetadata(HttpService:JSONDecode(stage:toString()));

  -- Add this stage to the player's inventory.
  local stageInventoryKeyList = DataStore.Inventory:ListKeysAsync(`{self.ID}/stages`);
  while not stageInventoryKeyList.IsFinished do

    stageInventoryKeyList:AdvanceToNextPageAsync();

  end;
  local latestKeys = stageInventoryKeyList:GetCurrentPage();
  local latestKey = (latestKeys[#latestKeys] or {KeyName = `{self.ID}/stages/1`}).KeyName;
  DataStore.Inventory:UpdateAsync(latestKey, function(encodedStageIDs)
    
    local stageIDs = HttpService:JSONDecode(encodedStageIDs or "{}");
    table.insert(stageIDs, stage.ID);
    return HttpService:JSONEncode(stageIDs);

  end);

  -- Notify the player if they're here.
  local player = Players:GetPlayerByUserId(self.ID);
  if player then

    ReplicatedStorage.Shared.Events.StageAdded:FireClient(player, stage);

  end;
  
  return stage;

end;

-- Returns a list of archetype IDs.
function Profile.__index:getArchetypeIDs(): {number}

  local archetypeIDs = {};
  local keyList = DataStore.Inventory:ListKeysAsync(`{self.ID}/archetypes`);
  repeat

    local keys = keyList:GetCurrentPage();
    for _, key in ipairs(keys) do

      local archetypeIDListEncoded = DataStore.Inventory:GetAsync(key.KeyName);
      local archetypeIDList = HttpService:JSONDecode(archetypeIDListEncoded);
      for _, archetypeID in ipairs(archetypeIDList) do

        table.insert(archetypeIDs, archetypeID);
        
      end;
  
    end;

    if not keyList.IsFinished then

      keyList:AdvanceToNextPageAsync();

    end;

  until keyList.IsFinished;

  return archetypeIDs;

end;

-- Returns a list of the player's stages. Removes stage IDs that cannot be found.
function Profile.__index:getStages(): {Stage.Stage}

  local stages = {};
  local keyList = DataStore.Inventory:ListKeysAsync(`{self.ID}/stages`);
  repeat

    local keys = keyList:GetCurrentPage();
    local stageIDsToRemove = {};
    for _, key in ipairs(keys) do

      local stageListEncoded = DataStore.Inventory:GetAsync(key.KeyName);
      local stageList = HttpService:JSONDecode(stageListEncoded);
      for _, stageID in ipairs(stageList) do
  
        local success, message = pcall(function()

          table.insert(stages, Stage.fromID(stageID));

        end);
        
        if not success then

          if message:find("doesn't exist yet.") then

            stageIDsToRemove[key.KeyName] = stageIDsToRemove[key.KeyName] or {};
            table.insert(stageIDsToRemove[key.KeyName], stageID);

          else

            warn(message);

          end;
  
        end;
  
      end;
  
    end;

    for keyName, stageIDs in pairs(stageIDsToRemove) do

      DataStore.Inventory:UpdateAsync(keyName, function(encodedStageIDs)
      
        local decodedStageIDs = HttpService:JSONDecode(encodedStageIDs);
        for _, stageID in ipairs(stageIDs) do

          local indexToRemove = table.find(decodedStageIDs, stageID);
          if indexToRemove then
          
            table.remove(decodedStageIDs, indexToRemove);

          end;

        end;
        
        return HttpService:JSONEncode(decodedStageIDs);

      end);

      print(`Removed the following stage IDs because they don't exist: {HttpService:JSONEncode(stageIDs)}`);

    end;

    if not keyList.IsFinished then

      keyList:AdvanceToNextPageAsync();

    end;

  until keyList.IsFinished;

  return stages;

end;

return Profile;