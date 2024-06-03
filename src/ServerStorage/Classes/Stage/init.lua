--!strict
-- Stage.lua
-- Written by Christian "Sudobeast" Toney
-- This module is a class that represents a stage.
-- NOTE TO DEVELOPERS: This is a Roblox package, so remember to update it.

local DataStoreService = game:GetService("DataStoreService");
local DataStore = {
  StageMetadata = DataStoreService:GetDataStore("StageMetadata");
  StageBuildData = DataStoreService:GetDataStore("StageBuildData");
  PublishedStages = DataStoreService:GetOrderedDataStore("PublishedStages");
};
local ServerScriptService = game:GetService("ServerScriptService");
local HttpService = game:GetService("HttpService");

type PermissionOverride = {
  ["stage.delete"]: boolean?;
  ["stage.save"]: boolean?;
};

type StageMemberObject = {
  ID: number;
  role: "Admin";
};

type StageProperties = {
  
  -- The stage's unique ID.
  ID: string?;
  
  -- A list of stage overrides.
  permissionOverrides: {PermissionOverride};
  
  -- The stage's name.
  name: string;
  
  -- Time in seconds when the stage was created.
  timeCreated: number;
  
  --Time in seconds when the stage was last updated.
  timeUpdated: number;
  
  -- The stage's description.
  description: string?;

  -- The stage's description.
  isPublished: boolean;

  -- The stage's members.
  members: {StageMemberObject};
  
}

type UpdatableStageProperties = {
  ID: string?;
  permissionOverrides: {PermissionOverride}?;
  name: string?;
  timeCreated: number?;
  timeUpdated: number?;
  description: string?;
  isPublished: boolean?;
  members: {StageMemberObject}?;
}

type StageMethods = {
  updateBuildData: (self: Stage, newData: {string}) -> ();
  updateMetadata: (self: Stage, newData: UpdatableStageProperties) -> ();
  delete: (self: Stage) -> ();
  download: (self: Stage) -> Model;
  publish: (self: Stage) -> ();
  unpublish: (self: Stage) -> ();
  verifyID: (self: Stage) -> ();
  getBuildData: (self: Stage) -> StageBuildData;
  toString: (self: Stage) -> string;
}

type StageEvents = {
  -- Fires when the stage metadata is updated.
  onMetadataUpdate: RBXScriptSignal;
  
  -- Fires when the build data is completely updated.
  onBuildDataUpdate: RBXScriptSignal;
  
  -- Fires when the build data is partially updated. 
  onBuildDataUpdateProgressChanged: RBXScriptSignal;

  onStageBuildDataDownloadProgressChanged: RBXScriptSignal;
  
  -- Fires when the stage is deleted.
  onDelete: RBXScriptSignal;
}

local Stage = {
  __index = {} :: StageMethods;
};

export type Stage = typeof(setmetatable({}, {__index = Stage.__index})) & StageProperties & StageMethods & StageEvents;

export type StageBuildDataItem = {
  type: string; 
  properties: {[string]: any};
  attributes: {[string]: any};
};

export type StageBuildData = {{StageBuildDataItem}};

local events = {};

-- Returns a new Stage object.
function Stage.new(properties: StageProperties): Stage
  
  local stage = properties;

  for _, eventName in ipairs({"onMetadataUpdate", "onBuildDataUpdate", "onBuildDataUpdateProgressChanged", "onDelete", "onStageBuildDataDownloadProgressChanged"}) do

    events[eventName] = Instance.new("BindableEvent");
    stage[eventName] = events[eventName].Event;

  end

  setmetatable(stage, {__index = Stage.__index});
  
  return stage :: any;
  
end

-- Returns a random Stage object from the published stages list.
function Stage.random(): Stage

  -- Get a random published ID.
  local dataStorePages = DataStore.PublishedStages:GetSortedAsync(true, 100);
  local publishedIDArrayList = {};
  repeat 

    local currentPage = dataStorePages:GetCurrentPage();
    table.insert(publishedIDArrayList, currentPage);

    if not dataStorePages.IsFinished then

      dataStorePages:AdvanceToNextPageAsync();

    end;

  until dataStorePages.IsFinished;

  -- Pick a random page.
  local publishedIDArray = publishedIDArrayList[math.random(1, #publishedIDArrayList)];
  
  -- Pick a random stage ID.
  local selectedStageID = publishedIDArray[math.random(1, #publishedIDArray)].key;

  -- Return the stage.
  return Stage.fromID(selectedStageID);

end;

-- Returns a new Stage object based on an ID.
function Stage.fromID(id: string): Stage
  
  local encodedStageData = DataStoreService:GetDataStore("StageMetadata"):GetAsync(id);
  assert(encodedStageData, `Stage {id} doesn't exist yet.`);
  
  local stageData = HttpService:JSONDecode(encodedStageData);
  stageData.ID = id;
  
  return Stage.new(stageData);
  
end

-- Verifies that this stage has an ID. If it doesn't, then it finds and adds one.
function Stage.__index:verifyID(): ()
  
  while not self.ID do

    -- Generate a stage ID.
    local possibleID = HttpService:GenerateGUID();
    local canGetStage = pcall(function() Stage.fromID(possibleID) end);
    if not canGetStage then 

      self.ID = possibleID;

    end;
    
  end;
  
end

-- Edits the stage's build data.
function Stage.__index:updateBuildData(newBuildData: {string}): ()
  
  self:verifyID();

  for index, chunk in ipairs(newBuildData) do

    DataStore.StageBuildData:SetAsync(`{self.ID}/{index}`, chunk);
    events.onBuildDataUpdateProgressChanged:Fire(index, #newBuildData);

  end
  events.onBuildDataUpdate:Fire();

end

-- Edits the stage's metadata.
function Stage.__index:updateMetadata(newData: UpdatableStageProperties): ()

  self:verifyID();

  DataStore.StageMetadata:UpdateAsync(self.ID, function(encodedOldMetadata)
  
    local newMetadata = HttpService:JSONDecode(encodedOldMetadata or "{}");
    for key, value in pairs(newData) do

      newMetadata[key] = value;

    end;

    return HttpService:JSONEncode(newMetadata);

  end);

  for key, value in pairs(newData) do

    (self :: {})[key] = value;

  end;
  
  events.onMetadataUpdate:Fire(newData);
  
end

-- Irrecoverably deletes the stage, including its build data.
-- This also unpublishes the stage if it is published.
-- This method does not remove the stage from members' inventories because it may take a longer time.
-- Instead, the stage will be automatically deleted from the members' inventories as the Stage Maker cannot find them. (See Player.__index:getStages())
function Stage.__index:delete(): ()
  
  -- Remove the stage from the published stages list if possible.
  if self.isPublished then

    self:unpublish();

  end;

  -- Delete build data.
  local keyList = DataStore.StageBuildData:ListKeysAsync(self.ID);
  repeat

    local keys = keyList:GetCurrentPage();
    for _, key in ipairs(keys) do

      DataStore.StageBuildData:RemoveAsync(key.KeyName);
  
    end;

    if not keyList.IsFinished then

      keyList:AdvanceToNextPageAsync();

    end;

  until keyList.IsFinished;
  
  -- Delete metadata.
  DataStore.StageMetadata:RemoveAsync(self.ID);

  -- Tell the player.
  print(`Stage {self.ID} has been successfully deleted.`);
  events.onDelete:Fire();
  
end

function Stage.__index:download(): Model

  local stageModel = Instance.new("Model");
  local buildData = self:getBuildData();

  -- Calculate the total parts.
  local totalParts = 0;
  for _, page in ipairs(buildData) do

    for _, instance in ipairs(page) do

      totalParts += 1;

    end;

  end;

  -- Add the parts to the stage model.
  local partsAudited = 0;
  for _, page in ipairs(buildData) do

    for _, instanceData in ipairs(page) do

      local instance = Instance.new(instanceData.type) :: any;
      instance.Anchored = true;
      local function setEnum(enum, property, value)

        for _, enumItem in ipairs(enum:GetEnumItems()) do

          if enumItem.Value == value then
            
            instance[property] = enumItem;

          end;

        end;  

      end;

      for property, value in pairs(instanceData.properties) do

        local enumProperties = {
          Material = Enum.Material;
          Shape = Enum.PartType;
          BackSurface = Enum.SurfaceType;
          BottomSurface = Enum.SurfaceType;
          FrontSurface = Enum.SurfaceType;
          LeftSurface = Enum.SurfaceType;
          RightSurface = Enum.SurfaceType;
          TopSurface = Enum.SurfaceType;
        }

        if property == "Color" then

          instance[property] = Color3.fromHex(value);

        elseif ({Size = 1; Position = 1; Orientation = 1})[property] then

          instance[property] = Vector3.new(value.X, value.Y, value.Z);

        elseif enumProperties[property] then

          setEnum(enumProperties[property], property, value);

        elseif ({Transparency = 1; Reflectance = 1; Name = 1; CastShadow = 1; Anchored = 1; CanCollide = 1;})[property] then

          instance[property] = value;

        else

          warn(`Unknown property: {property}`);

        end;

      end;

      for attribute, value in pairs(instanceData.attributes) do

        instance:SetAttribute(attribute, value);

      end;

      instance.Parent = stageModel;

      partsAudited += 1;
      events.onStageBuildDataDownloadProgressChanged:Fire(partsAudited, totalParts);

    end;

  end;

  return stageModel;

end;

-- Adds this stage's build data to the published stage index.
function Stage.__index:publish(): ()

  -- Verify that this stage isn't already published.
  assert(not self.isPublished, "This stage is already published.");

  -- Save the stage if this is the current stage.
  if ServerScriptService.StageSaveScript.GetCurrentStage:Invoke() == self then

    ServerScriptService.StageSaveScript.SaveStage:Invoke();

  end;

  -- Add this stage to the published stages list.
  DataStore.PublishedStages:SetAsync(self.ID, DateTime.now().UnixTimestampMillis);

  -- Mark this stage has published.
  self:updateMetadata({isPublished = true});

  print(`Successfully published Stage {self.ID}.`);

end;

-- Removes this stage from the published stage index.
function Stage.__index:unpublish(): ()

  -- Verify that this stage is published.
  assert(self.isPublished, "This stage is already unpublished.");

  -- Remove this stage from the published stages list.
  DataStore.PublishedStages:RemoveAsync(self.ID);

  -- Mark this stage has unpublished.
  self:updateMetadata({isPublished = false});

  print(`Successfully unpublished Stage {self.ID}.`);

end;

-- Returns this stage's build data.
function Stage.__index:getBuildData(): StageBuildData

  local keyList = DataStore.StageBuildData:ListKeysAsync(self.ID);
  local buildDataEncoded = {};
  repeat

    local keys = keyList:GetCurrentPage();
    for _, key in ipairs(keys) do

      table.insert(buildDataEncoded, HttpService:JSONDecode(DataStore.StageBuildData:GetAsync(key.KeyName)));
  
    end;

    if not keyList.IsFinished then

      keyList:AdvanceToNextPageAsync();

    end;

  until keyList.IsFinished;

  return buildDataEncoded;

end;

function Stage.__index:toString(): string

  local properties = {"ID", "permissionOverrides", "name", "timeCreated", "timeUpdated", "description", "isPublished", "members"}
  local encodedData = {};
  for _, property in ipairs(properties) do

    encodedData[property] = (self :: {})[property];

  end;

  return HttpService:JSONEncode(encodedData);

end;

return Stage;