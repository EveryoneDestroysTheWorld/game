--!strict

local HttpService = game:GetService("HttpService");
local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local function processRegularBall(action: types.HeresThePitchServerAction, goalDestination: Vector3?): ()

  local pitcher = action.contestant;
  assert(pitcher.character);
  
  -- Connect the ball to the player's hand and track who gets hit.
  -- TODO: Allow customization of hand.
  local throwingHand = pitcher.character:FindFirstChild("RightHand") or pitcher.character:FindFirstChild("LeftHand");
  assert(throwingHand and throwingHand:IsA("BasePart"), "Could not find RightHand or LeftHand.");
  
  local animationBall = script.Ball:Clone();
  animationBall.CFrame = throwingHand.CFrame;
  animationBall.CollisionGroup = action.collisionGroupName;
  animationBall.Name = `{animationBall.Name}-{HttpService:GenerateGUID(false)}`
  animationBall.Parent = workspace;

  local weld = Instance.new("WeldConstraint");
  weld.Part0 = animationBall;
  weld.Part1 = throwingHand;
  weld.Parent = animationBall;

  if pitcher.player and action.remoteFunction then

    -- Keep the server weld in the player's hand while the client processes it.
    animationBall:SetNetworkOwner(pitcher.player);
    action.remoteFunction:InvokeClient(pitcher.player, animationBall.Name);

  else

    -- Play pitching animation.
    warn("NO ANIMATION")

  end;

  -- Two different balls are required because of Roblox's limitations on network ownership.
  -- This method minimizes the delay when throwing the ball. 
  -- It also helps keep the game secure because the ball is owned by the server.
  local ballCFrame = animationBall.CFrame;
  animationBall:Destroy();

  local realBall = script.Ball:Clone();
  realBall.CFrame = ballCFrame;
  realBall.CollisionGroup = action.collisionGroupName;
  realBall.Parent = workspace;
  
  local direction = throwingHand.CFrame.LookVector * 5;
  if goalDestination then

    local originalDirection = goalDestination - throwingHand.CFrame.Position;
    local maxDistance = 180;
    direction = if originalDirection.Magnitude == 0 then Vector3.zero else originalDirection.Unit * math.min(originalDirection.Magnitude, maxDistance);

  end;
  
  -- TODO: Use charge to reduce duration.
  local duration = math.log(1.001 + direction.Magnitude * 0.01);
  local force = direction / duration + Vector3.new(0, workspace.Gravity * duration * 0.5, 0);
  realBall:ApplyImpulse(force * realBall.AssemblyMass);
  realBall:SetNetworkOwner();
  
  local victimHistory: {[number]: number} = {};
  realBall.Touched:Connect(function(part: BasePart)

    if not action.contestant.character or not part:IsDescendantOf(action.contestant.character) then

      local trail = realBall:FindFirstChild("Trail");
      if trail then

        trail:Destroy();

      end;

    end;

    -- TODO: Verify that the ball is moving fast.
    local possibleContestantModel = part:FindFirstAncestorOfClass("Model");
    local didFindValidModel = possibleContestantModel and possibleContestantModel ~= action.contestant.character;
    if didFindValidModel then

      for _, contestant in action.contestant.round.contestants do

        if contestant.character == possibleContestantModel then

          local latestValidHitTime = victimHistory[contestant.id];
          local currentHitTime = os.time();
          local duplicateVictimCooldownSeconds = 3;
          if latestValidHitTime and currentHitTime >= latestValidHitTime + duplicateVictimCooldownSeconds then
  
            victimHistory[contestant.id] = nil;
  
          end;
  
          if not victimHistory[contestant.id] then

            victimHistory[contestant.id] = currentHitTime;
  
            contestant:updateHealth(math.max(contestant.currentHealth - 20, 0), {
              contestantID = action.contestant.id;
              actionID = action.id;
            });
            
          end;
  
          break;
  
        end;
  
      end;

    end;

  end);

end;

return processRegularBall;