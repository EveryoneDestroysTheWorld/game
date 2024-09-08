--!strict
-- Writer: Hati ---- Heavily modified edit of RocketFeet
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService")
local ServerContestant = require(script.Parent.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerAction = require(script.Parent.Parent.ServerAction);
type ServerAction = ServerAction.ServerAction;
local TakeFlightClientAction = require(ReplicatedStorage.Client.Classes.Actions.DKFlightClientAction);
local ServerRound = require(script.Parent.Parent.ServerRound);
type ServerRound = ServerRound.ServerRound;
local ServerStorage = game:GetService("ServerStorage");

local TakeFlightServerAction = {
  ID = TakeFlightClientAction.ID;
  name = TakeFlightClientAction.name;
  description = TakeFlightClientAction.description;
};

local function animateFlightStart(humanoid)
  
  local animationTracks = {};
  local flyAnimationRight = Instance.new("Animation");
  local flyAnimationLeft = Instance.new("Animation");
  flyAnimationRight.AnimationId = "rbxassetid://87777396509498";
  flyAnimationLeft.AnimationId = "rbxassetid://72026942510156";
  local animatorR = humanoid.Parent.WingProp.WingsPropRight:FindFirstChild("AnimationController");
  local animatorL = humanoid.Parent.WingProp.WingsPropLeft:FindFirstChild("AnimationController");
  animationTracks["Right"] = animatorR:LoadAnimation(flyAnimationRight);
  animationTracks["Right"]:Play(0,100,1.8);
  animationTracks["Left"] = animatorL:LoadAnimation(flyAnimationLeft);
  animationTracks["Left"]:Play(0,100,1.8);
  return animationTracks
end

local function flightStart(primaryPart)

  local linearVelocity = Instance.new("LinearVelocity");
  linearVelocity.VelocityConstraintMode = "Line"
  linearVelocity.LineDirection = Vector3.new(0, 1, 0);
  linearVelocity.LineVelocity = -5
  linearVelocity.MaxForce = math.huge;
  linearVelocity.Parent = primaryPart;
  linearVelocity.Attachment0 = primaryPart:FindFirstChild("RootAttachment") :: Attachment;

  task.wait(0.3)

  linearVelocity.LineVelocity = 50;

  local tween = TweenService:Create(linearVelocity, TweenInfo.new(1.0, Enum.EasingStyle.Sine), {LineVelocity = 0})
tween:Play()

  task.delay(0.8, function()
  
    linearVelocity:Destroy();

  end);



return
end




function TakeFlightServerAction.new(contestant: ServerContestant, round: ServerRound): ServerAction


  local action: ServerAction = nil;

  local function activate()

    if contestant.character then

      local humanoid = contestant.character:FindFirstChild("Humanoid");
      assert(humanoid and humanoid:IsA("Humanoid"), `Couldn't find {contestant.character}'s Humanoid`);

      if humanoid:GetAttribute("CurrentStamina") >= 10 then
        



        -- Activate double jump.
        local primaryPart = contestant.character.PrimaryPart;
        if humanoid:GetState() == Enum.HumanoidStateType.Freefall and primaryPart then
          local animationTracks = animateFlightStart(humanoid)
          flightStart(primaryPart)
 -- Reduce the player's stamina.
 humanoid:SetAttribute("CurrentStamina", humanoid:GetAttribute("CurrentStamina") - 10);
        end;

       

      end;
  
    end;

  end;

  local executeActionRemoteFunction: RemoteFunction? = nil;

  local function breakdown()

    if executeActionRemoteFunction then

      executeActionRemoteFunction:Destroy();

    end

    leftFootExplosivePart:Destroy();
    rightFootExplosivePart:Destroy();

  end;

  if contestant.character then

    -- Create the explosive attachments on both feet of the player.
    local humanoid = contestant.character:FindFirstChild("Humanoid");
    assert(humanoid and humanoid:IsA("Humanoid"), "Couldn't find contestant's humanoid");

    local isHumanoidR15 = humanoid.RigType == Enum.HumanoidRigType.R15;
    local leftFoot = contestant.character:FindFirstChild(if isHumanoidR15 then "LeftFoot" else "LeftLeg");
    local rightFoot = contestant.character:FindFirstChild(if isHumanoidR15 then "RightFoot" else "RightLeg");
    for _, footInfo in ipairs({{leftFoot, leftFootExplosivePart}, {rightFoot, rightFootExplosivePart}}) do

      local foot = footInfo[1];
      local explosivePart = footInfo[2];
      if foot and foot:IsA("BasePart") and explosivePart and explosivePart:IsA("BasePart") then

        local explosiveWeldConstraint = Instance.new("WeldConstraint");
        explosiveWeldConstraint.Part0 = explosivePart;
        explosiveWeldConstraint.Part1 = foot;
        explosiveWeldConstraint.Parent = explosivePart;

        explosivePart.Position = foot.CFrame.Position - (if not isHumanoidR15 then Vector3.new(0, foot.Size.Y / 2 + explosivePart.Size.Y / 2, 0) else Vector3.zero);
        explosivePart.Parent = contestant.character;

      end;
    
    end;

  end;

  action = ServerAction.new({
    name = TakeFlightServerAction.name;
    ID = TakeFlightServerAction.ID;
    description = TakeFlightServerAction.description;
    breakdown = breakdown;
    activate = activate;
  });

  if contestant.player then

    local remoteFunction = Instance.new("RemoteFunction");
    remoteFunction.Name = `{contestant.player.UserId}_{action.ID}`;
    remoteFunction.OnServerInvoke = function(player)

      if player == contestant.player then

        action:activate();

      else

        -- That's weird.
        error("Unauthorized.");

      end

    end;
    remoteFunction.Parent = ReplicatedStorage.Shared.Functions.ActionFunctions;
    executeActionRemoteFunction = remoteFunction;

  end

  return action;

end;




return TakeFlightServerAction;
