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

  local player = action.contestant.player;
  if player then
  
    action.remoteFunction = createInventoryRemoteFunction(player, "Action", `{player.UserId}_{action.id}`, function(mode: types.BatterUpDemonModes)
    
      action:activate(mode);

    end);

    ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

  end;

  return action;

end;

function ChangeModesServerAction.__index:activate(mode: types.BatterUpDemonModes): ()

  local allowedModes: {types.BatterUpDemonModes} = {"Pitcher", "Batter"};
  assert(mode and typeof(mode) == "string" and table.find(allowedModes, mode));
  self.contestant.attributes.archetypeMode = mode;

  ServerStorage.Events.ArchetypeModeChanged:Fire(self.contestant.id);
  
  if self.contestant.player then
    
    ReplicatedStorage.Shared.Events.ArchetypeModeChanged:FireClient(self.contestant.player);

  end

end;

function ChangeModesServerAction.__index:breakdown(): ()

  if self.remoteFunction then

    self.remoteFunction:Destroy();

  end;

  if self.contestant.player then

    ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(self.contestant.player, self.id);

  end;

end;

return ChangeModesServerAction;