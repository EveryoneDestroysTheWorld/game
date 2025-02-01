--!strict

local HttpService = game:GetService("HttpService");
local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local function processRegularBall(action: types.HeresThePitchServerAction): ()

  local pitcher = action.contestant;
  assert(pitcher.character);
  
  -- Connect the ball to the player's hand and track who gets hit.
  -- TODO: Allow customization of hand.
  local throwingHand = pitcher.character:FindFirstChild("RightHand") or pitcher.character:FindFirstChild("LeftHand");
  assert(throwingHand and throwingHand:IsA("BasePart"), "Could not find RightHand or LeftHand.");
  
  local ball = script.Ball:Clone();
  ball.CFrame = throwingHand.CFrame;
  ball.CollisionGroup = action.collisionGroupName;
  ball.Name = `{ball.Name}-{HttpService:GenerateGUID(false)}`
  ball.Parent = workspace;

  local weld = Instance.new("WeldConstraint");
  weld.Part0 = ball;
  weld.Part1 = throwingHand;
  weld.Parent = ball;

  local victimHistory: {[number]: number} = {};
  ball.Touched:Connect(function(part: BasePart)

    if ball:GetNetworkOwner() and (not pitcher.character or not part:IsDescendantOf(pitcher.character)) then

      print(part.Name);
      ball:SetNetworkOwner();

    end;

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

  if pitcher.player and action.remoteFunction then

    -- Keep the server weld in the player's hand while the client processes it.
    -- This process is unsecure because it depends on the client, but it is a necessity 
    -- due to Roblox's limitations with network ownership.
    ball:SetNetworkOwner(pitcher.player);
    action.remoteFunction:InvokeClient(pitcher.player, "CopyWeld", ball.Name);
    weld:Destroy();
    action.remoteFunction:InvokeClient(pitcher.player, "Throw", ball.Name);

  else

    -- Play pitching animation.
    warn("NO ANIMATION")

    -- Launch the ball in the direction that the contestant faces.
    -- AlignPosition was under consideration, but ApplyImpulse allows for more control over the ball.
    -- In the future, we should consider using VectorForce to support more pitching styles.
    weld:Destroy();
    ball:ApplyImpulse(throwingHand.CFrame.LookVector * 5);

  end;

end;

return processRegularBall;