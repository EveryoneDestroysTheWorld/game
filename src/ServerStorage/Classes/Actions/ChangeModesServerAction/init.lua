--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ChangeModesClientAction = require(ReplicatedStorage.Client.Classes.Actions.ChangeModesClientAction);
local types = require(ServerStorage.Modules.types);

local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);

local ChangeModesServerAction = {
  id = ChangeModesClientAction.id;
  name = ChangeModesClientAction.name;
  description = ChangeModesClientAction.description;
  __index = {
    name = ChangeModesClientAction.name;
    id = ChangeModesClientAction.id;
    description = ChangeModesClientAction.description;
  } :: types.ChangeModesServerAction;
};

function ChangeModesServerAction.new(properties: types.ServerActionConstructorProperties): types.ChangeModesServerAction

  local overwrittenProperties = {
    contestant = properties.contestant;
  };

  local action = (setmetatable(overwrittenProperties, ChangeModesServerAction) :: any) :: types.ChangeModesServerAction;

  if action.contestant.player then
  
    action.remoteFunction = createInventoryRemoteFunction(action.contestant.player, "Action", `{action.contestant.player.UserId}_{action.id}`, function(mode: types.BatterUpDemonModes)
    
      action:activate(mode);

    end);

  end;

  return action;

end;

function ChangeModesServerAction.__index:activate(mode: types.BatterUpDemonModes): ()

  local allowedModes: {types.BatterUpDemonModes} = {"Pitcher", "Batter"};
  assert(mode and typeof(mode) == "string" and table.find(allowedModes, mode));
  self.contestant.attributes.actionMode = mode;

end;

function ChangeModesServerAction.__index:breakdown(): ()

  if self.remoteFunction then

    self.remoteFunction:Destroy();

  end;

end;

return ChangeModesServerAction;