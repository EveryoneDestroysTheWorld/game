--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ChangeBallTypeClientAction = require(ReplicatedStorage.Client.Classes.Actions.ChangeBallTypeClientAction);
local types = require(ServerStorage.Classes.types);

local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);

local ChangeBallTypeServerAction = {
  id = ChangeBallTypeClientAction.id;
  name = ChangeBallTypeClientAction.name;
  description = ChangeBallTypeClientAction.description;
  __index = {};
};

function ChangeBallTypeServerAction.new(properties: types.ServerActionConstructorProperties): types.ChangeBallTypeServerAction

  local overwrittenProperties = {
    name = ChangeBallTypeServerAction.name;
    id = ChangeBallTypeServerAction.id;
    description = ChangeBallTypeServerAction.description;
    contestant = properties.contestant;
  };

  local action = (setmetatable(overwrittenProperties, ChangeBallTypeServerAction) :: any) :: types.ChangeBallTypeServerAction;

  if action.contestant.player then
  
    local remoteFunction = createInventoryRemoteFunction(action.contestant.player, "Action", `{action.contestant.player.UserId}_{action.id}`, function()
    
      action:activate();

    end);

    action.remoteFunction = remoteFunction;

  end;

  return action;

end;

function ChangeBallTypeServerAction.__index:activate(): ()

  -- TODO: Change ball type.


end;

function ChangeBallTypeServerAction.__index:breakdown(): ()

  if self.remoteFunction then

    self.remoteFunction:Destroy();

  end;

end;

return ChangeBallTypeServerAction;