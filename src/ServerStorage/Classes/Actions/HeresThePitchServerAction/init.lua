--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local PhysicsService = game:GetService("PhysicsService");

local HeresThePitchClientAction = require(ReplicatedStorage.Client.Classes.Actions.HeresThePitchClientAction);
local types = require(ServerStorage.Modules.types);

local processRegularBall = require(script.processRegularBall);
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
    playerBalls = {};
  };

  local action = (setmetatable(overwrittenProperties, HeresThePitchServerAction) :: any) :: types.HeresThePitchServerAction;

  if action.contestant.player then
  
    action.remoteFunction = createInventoryRemoteFunction(action.contestant.player, "Action", `{action.contestant.player.UserId}_{action.id}`, function(goalDestination: Vector3?)

      assert(not goalDestination or typeof(goalDestination) == "Vector3");
      return action:activate(goalDestination);

    end);

  end;

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

  return action;

end;

export type PitchingFunction = (action: types.HeresThePitchServerAction, coordinates: Vector3) -> string?;

function HeresThePitchServerAction.__index:activate(coordinates: Vector3): string?

  -- Verify that a ball type has been defined.
  local allowedBallTypes: {types.BallType} = {"Explosive", "Electric", "Poison", "Regular"};
  local ballType: types.BallType? = self.contestant.attributes.ballType :: types.BallType?;
  assert(ballType and typeof(ballType) == "string" and table.find(allowedBallTypes, ballType));

  local processingFunctions: {[types.BallType]: PitchingFunction} = {
    Regular = processRegularBall;
  };

  local preparePitch = processingFunctions[ballType];
  assert(preparePitch);

  return preparePitch(self, coordinates);

end;

function HeresThePitchServerAction.__index:breakdown(): ()

  if self.remoteFunction then

    self.remoteFunction:Destroy();

  end;

  PhysicsService:UnregisterCollisionGroup(self.collisionGroupName);

end;

return HeresThePitchServerAction;