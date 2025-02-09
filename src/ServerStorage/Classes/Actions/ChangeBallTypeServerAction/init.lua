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

  local player = action.contestant.player;
  if player then
  
    action.remoteFunction = createInventoryRemoteFunction(player, "Action", `{player.UserId}_{action.id}`, function(ballType: types.BallType)
    
      action:activate(ballType);

    end);

    ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

  end;

  action.contestant.attributes.ballType = action.contestant.attributes.ballType or "Regular";

  return action;

end;

function ChangeBallTypeServerAction.__index:activate(ballType: types.BallType): ()

  local allowedBallTypes: {types.BallType} = {"Explosive", "Electric", "Poison", "Regular"};
  assert(ballType and typeof(ballType) == "string" and table.find(allowedBallTypes, ballType));
  self.contestant.attributes.ballType = ballType;

end;

function ChangeBallTypeServerAction.__index:breakdown(): ()

  if self.remoteFunction then

    self.remoteFunction:Destroy();

  end;

  if self.contestant.player then

    ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(self.contestant.player, self.id);

  end;

end;

return ChangeBallTypeServerAction;