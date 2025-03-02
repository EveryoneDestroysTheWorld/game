--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local PhysicsService = game:GetService("PhysicsService");
local HttpService = game:GetService("HttpService");

local ElectricBall = require(script.Balls.ElectricBall);
local ExplosiveBall = require(script.Balls.ExplosiveBall);
local PoisonBall = require(script.Balls.PoisonBall);
local RegularBall = require(script.Balls.ElectricBall);
local HeresThePitchClientAction = require(ReplicatedStorage.Client.Classes.Actions.HeresThePitchClientAction);
local IHeresThePitchServerAction = require(ServerStorage.Interfaces.IHeresThePitchServerAction);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);
local IServerRound = require(ServerStorage.Interfaces.IServerRound);
local SharedTypes = require(ServerStorage.Modules.SharedTypes);

local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);

type BallType = SharedTypes.BallType;
type IHeresThePitchServerAction = IHeresThePitchServerAction.IHeresThePitchServerAction;
type IServerContestant = IServerContestant.IServerContestant;
type IServerRound = IServerRound.IServerRound;

local HeresThePitchServerAction = {
  id = HeresThePitchClientAction.id;
  name = HeresThePitchClientAction.name;
  description = HeresThePitchClientAction.description;
};

function HeresThePitchServerAction.new(contestant: IServerContestant, round: IServerRound): IHeresThePitchServerAction

  local collisionGroupName = `{contestant.id}-{HeresThePitchServerAction.id}`;
  local balls: {Model} = {};

  local function activate(self: IHeresThePitchServerAction, destination: Vector3?): ()

    assert(contestant.attributes.archetypeMode == "Pitcher", "Contestant must be in pitcher mode to use this action.");
  
    -- Verify that a ball type has been defined.
    local ballMap = {
      Explosive = ExplosiveBall;
      Electric = ElectricBall;
      Poison = PoisonBall;
      Regular = RegularBall;
    };
    local ballType: BallType? = contestant.attributes.ballType :: BallType?;
    local PitchableBall = ballMap[ballType];
    assert(PitchableBall, `Couldn't find ball type {ballType}.`);

    assert(contestant.character, `Couldn't find the pitcher's character. Are they dead?`);

    -- Connect the ball to the player's hand and track who gets hit.
    -- TODO: Allow customization of hand.
    local throwingHand = contestant.character:FindFirstChild("RightHand") or contestant.character:FindFirstChild("LeftHand");
    assert(throwingHand and throwingHand:IsA("BasePart"), "Could not find RightHand or LeftHand.");

    local ball = PitchableBall.new();
    local animationBall: Model = ball.model:Clone();
    animationBall.Name = `{animationBall.Name}-{HttpService:GenerateGUID(false)}`

    local ballMesh = animationBall:FindFirstChild("Mesh");
    assert(ballMesh and ballMesh:IsA("BasePart"));
    ballMesh.CFrame = throwingHand.CFrame;
    ballMesh.CollisionGroup = collisionGroupName;
    animationBall.Parent = workspace;

    local weld = Instance.new("WeldConstraint");
    weld.Part0 = ballMesh;
    weld.Part1 = throwingHand;
    weld.Parent = ballMesh;

    if contestant.player and self.remoteFunction then

      -- Keep the server weld in the player's hand while the client processes it.
      ballMesh:SetNetworkOwner(contestant.player);
      self.remoteFunction:InvokeClient(contestant.player, animationBall.Name);

    else

      -- Play pitching animation.
      warn("NO ANIMATION")

    end;

    -- Two different balls are required because of Roblox's limitations on network ownership.
    -- This method minimizes the delay when throwing the ball. 
    -- It also helps keep the game secure because the ball is owned by the server.
    local ballCFrame = ballMesh.CFrame;
    animationBall:Destroy();

    local function removeExcessiveBalls()

      local maximumBalls = 10;
      while #balls + 1 > maximumBalls do

        balls[1]:Destroy();
        table.remove(balls, 1);

      end;

    end;
    
    removeExcessiveBalls();

    local realBall: Model = ball.model;
    ballMesh = realBall:FindFirstChild("Mesh");
    ballMesh.CFrame = ballCFrame;
    ballMesh.CollisionGroup = collisionGroupName;
    realBall.Parent = workspace;
    ballMesh:SetNetworkOwner();
    table.insert(balls, realBall);

    realBall.Destroying:Once(function()
      
      for index = #balls, 1, -1 do
        
        if ball.Parent == nil then

          table.remove(balls, index);

        end;

      end;

    end);

    local hitbox = realBall:FindFirstChild("Hitbox");
    if hitbox and hitbox:IsA("BasePart") then

      hitbox.CollisionGroup = collisionGroupName;

    end;
    
    local direction = throwingHand.CFrame.LookVector * 5;
    if destination then

      local originalDirection = destination - throwingHand.CFrame.Position;
      local maxDistance = 180;
      direction = if originalDirection.Magnitude == 0 then Vector3.zero else originalDirection.Unit * math.min(originalDirection.Magnitude, maxDistance);

    end;
    
    -- TODO: Use charge to reduce duration.
    local duration = math.log(1.001 + direction.Magnitude * 0.01);
    local force = direction / duration + Vector3.new(0, workspace.Gravity * duration * 0.5, 0);
    ballMesh:ApplyImpulse(force * ballMesh.AssemblyMass);
    ball:activate(contestant, round:getContestants(), self.id);
  
  end;
  
  local function breakdown(self: IHeresThePitchServerAction)

    if self.remoteFunction then
  
      self.remoteFunction:Destroy();
  
    end;
  
    if contestant.player then
  
      ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(contestant.player, self.id);
  
    end;

    for _, ball in balls do

      ball:Destroy();

    end;
  
    PhysicsService:UnregisterCollisionGroup(collisionGroupName);
  
  end;

  local action: IHeresThePitchServerAction = {
    attributes = {};
    contestantID = contestant.id;
    description = HeresThePitchServerAction.description;
    id = HeresThePitchServerAction.id;
    name = HeresThePitchServerAction.name;
    activate = activate;
    breakdown = breakdown;
  }

  contestant.attributes.ballType = contestant.attributes.ballType or "Regular";

  local shouldRegisterGroup = true;
  for _, collisionGroup in PhysicsService:GetRegisteredCollisionGroups() do

    if collisionGroup.name == collisionGroupName then

      shouldRegisterGroup = false;
      break;

    end;
  
  end

  if shouldRegisterGroup then

    PhysicsService:RegisterCollisionGroup(collisionGroupName);
    PhysicsService:CollisionGroupSetCollidable(collisionGroupName, `Contestant-{contestant.id}`, false);

  end;

  local player = contestant.player;
  if player then
  
    action.remoteFunction = createInventoryRemoteFunction(player, "Action", `{player.UserId}_{action.id}`, function(destination: Vector3?)

      assert(not destination or typeof(destination) == "Vector3");
      return action:activate(destination);

    end);

    ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

  end;

  return action;

end;

return HeresThePitchServerAction;