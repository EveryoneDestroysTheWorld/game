--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ChangeBallTypeClientAction = require(ReplicatedStorage.Client.Classes.Actions.ChangeBallTypeClientAction);
local types = require(ServerStorage.Modules.types);

local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);

local ChangeBallTypeServerAction = {
  id = ChangeBallTypeClientAction.id;
  name = ChangeBallTypeClientAction.name;
  description = ChangeBallTypeClientAction.description;
  __index = {
    name = ChangeBallTypeClientAction.name;
    id = ChangeBallTypeClientAction.id;
    description = ChangeBallTypeClientAction.description;
  } :: types.ChangeBallTypeServerAction;
};

function ChangeBallTypeServerAction.new(properties: types.ServerActionConstructorProperties): types.ChangeBallTypeServerAction

  local overwrittenProperties = {
    contestant = properties.contestant;
  };

  local action = (setmetatable(overwrittenProperties, ChangeBallTypeServerAction) :: any) :: types.ChangeBallTypeServerAction;

  if action.contestant.player then
  
    action.remoteFunction = createInventoryRemoteFunction(action.contestant.player, "Action", `{action.contestant.player.UserId}_{action.id}`, function()
    
      action:activate();

    end);

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