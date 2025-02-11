--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local PhysicsService = game:GetService("PhysicsService");

local HeresThePitchClientAction = require(ReplicatedStorage.Client.Classes.Actions.HeresThePitchClientAction);
local types = require(ServerStorage.Modules.types);

local processBall = require(script.processBall);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);

local HeresThePitchServerAction = {
  id = HeresThePitchClientAction.id;
  name = HeresThePitchClientAction.name;
  description = HeresThePitchClientAction.description;
  __index = {
    name = HeresThePitchClientAction.name;
    id = HeresThePitchClientAction.id;
    description = HeresThePitchClientAction.description;
  } :: types.HeresThePitchServerAction;
};

function HeresThePitchServerAction.new(properties: types.ServerActionConstructorProperties): types.HeresThePitchServerAction

  local overwrittenProperties = {
    contestant = properties.contestant;
    collisionGroupName = `{properties.contestant.id}-{HeresThePitchServerAction.id}`;
    balls = {};
  };

  local action = (setmetatable(overwrittenProperties, HeresThePitchServerAction) :: any) :: types.HeresThePitchServerAction;

  action.contestant.attributes.ballType = action.contestant.attributes.ballType or "Regular";

  local shouldRegisterGroup = true;
  for _, collisionGroup in PhysicsService:GetRegisteredCollisionGroups() do

    if collisionGroup.name == action.collisionGroupName then

      shouldRegisterGroup = false;
      break;

    end;
  
  end

  if shouldRegisterGroup then

    PhysicsService:RegisterCollisionGroup(action.collisionGroupName);
    PhysicsService:CollisionGroupSetCollidable(action.collisionGroupName, `Contestant-{action.contestant.id}`, false);

  end;

  local player = action.contestant.player;
  if player then
  
    action.remoteFunction = createInventoryRemoteFunction(player, "Action", `{player.UserId}_{action.id}`, function(goalDestination: Vector3?)

      assert(not goalDestination or typeof(goalDestination) == "Vector3");
      return action:activate(goalDestination);

    end);

    ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

  end;

  return action;

end;

export type PitchingFunction = (action: types.HeresThePitchServerAction, coordinates: Vector3) -> string?;

function HeresThePitchServerAction.__index:activate(coordinates: Vector3): string?

  assert(self.contestant.attributes.archetypeMode == "Pitcher", "Contestant must be in pitcher mode to use this action.");

  return processBall(self, coordinates);

end;

function HeresThePitchServerAction.__index:breakdown(): ()

  if self.remoteFunction then

    self.remoteFunction:Destroy();

  end;

  if self.contestant.player then

    ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(self.contestant.player, self.id);

  end;

  PhysicsService:UnregisterCollisionGroup(self.collisionGroupName);

end;

return HeresThePitchServerAction;