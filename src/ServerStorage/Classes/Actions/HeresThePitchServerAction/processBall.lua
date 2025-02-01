--!strict

local HttpService = game:GetService("HttpService");
local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local removeExcessiveBalls = require(script.Parent.removeExcessiveBalls);

local function processBall(action: types.HeresThePitchServerAction, goalDestination: Vector3?): ()

  -- Verify that a ball type has been defined.
  local allowedBallTypes: {types.BallType} = {"Explosive", "Electric", "Poison", "Regular"};
  local ballType: types.BallType? = action.contestant.attributes.ballType :: types.BallType?;
  assert(ballType and typeof(ballType) == "string" and table.find(allowedBallTypes, ballType));

  local ballName = `{ballType}Ball`;
  local ballFolder = script.Parent.Balls:FindFirstChild(ballName);
  assert(ballFolder, `Couldn't find {ballName} in Balls folder.`);

  local pitcher = action.contestant;
  assert(pitcher.character, `Couldn't find the pitcher's character. Are they dead?`);

  -- Connect the ball to the player's hand and track who gets hit.
  -- TODO: Allow customization of hand.
  local throwingHand = pitcher.character:FindFirstChild("RightHand") or pitcher.character:FindFirstChild("LeftHand");
  assert(throwingHand and throwingHand:IsA("BasePart"), "Could not find RightHand or LeftHand.");

  local animationBall: Model = ballFolder.Ball:Clone();
  animationBall.Name = `{animationBall.Name}-{HttpService:GenerateGUID(false)}`

  local ballMesh = animationBall:FindFirstChild("Mesh");
  assert(ballMesh and ballMesh:IsA("BasePart"));
  ballMesh.CFrame = throwingHand.CFrame;
  ballMesh.CollisionGroup = action.collisionGroupName;
  animationBall.Parent = workspace;

  local weld = Instance.new("WeldConstraint");
  weld.Part0 = ballMesh;
  weld.Part1 = throwingHand;
  weld.Parent = ballMesh;

  if pitcher.player and action.remoteFunction then

    -- Keep the server weld in the player's hand while the client processes it.
    ballMesh:SetNetworkOwner(pitcher.player);
    action.remoteFunction:InvokeClient(pitcher.player, animationBall.Name);

  else

    -- Play pitching animation.
    warn("NO ANIMATION")

  end;

  -- Two different balls are required because of Roblox's limitations on network ownership.
  -- This method minimizes the delay when throwing the ball. 
  -- It also helps keep the game secure because the ball is owned by the server.
  local ballCFrame = ballMesh.CFrame;
  animationBall:Destroy();

  removeExcessiveBalls(action);

  local realBall: Model = ballFolder.Ball:Clone();
  ballMesh = realBall:FindFirstChild("Mesh");
  ballMesh.CFrame = ballCFrame;
  ballMesh.CollisionGroup = action.collisionGroupName;
  realBall.Parent = workspace;
  ballMesh:SetNetworkOwner();
  table.insert(action.balls, realBall);

  local hitbox = realBall:FindFirstChild("Hitbox");
  if hitbox and hitbox:IsA("BasePart") then

    hitbox.CollisionGroup = action.collisionGroupName;

  end;
  
  local direction = throwingHand.CFrame.LookVector * 5;
  if goalDestination then

    local originalDirection = goalDestination - throwingHand.CFrame.Position;
    local maxDistance = 180;
    direction = if originalDirection.Magnitude == 0 then Vector3.zero else originalDirection.Unit * math.min(originalDirection.Magnitude, maxDistance);

  end;
  
  -- TODO: Use charge to reduce duration.
  local duration = math.log(1.001 + direction.Magnitude * 0.01);
  local force = direction / duration + Vector3.new(0, workspace.Gravity * duration * 0.5, 0);
  ballMesh:ApplyImpulse(force * ballMesh.AssemblyMass);
  
  local actionScript = ballFolder:FindFirstChild("onTouched");
  assert(actionScript and actionScript:IsA("ModuleScript"), `Couldn't find "onTouched" ModuleScript in {ballFolder.Name} folder.`);

  local onTouched = require(actionScript) :: (action: types.HeresThePitchServerAction, ball: Model, part: BasePart) -> ();
  assert(typeof(onTouched) == "function", "onTouched script must be a function.");

  ballMesh.Touched:Connect(function(part: BasePart)

    if not action.contestant.character or not part:IsDescendantOf(action.contestant.character) then

      local trail = realBall:FindFirstChild("Trail");
      if trail then

        trail:Destroy();

      end;

    end;

    onTouched(action, realBall, part);

  end);

end;

return processBall;