--!strict

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local calculateCharge = require(ServerStorage.Modules.calculateCharge);
local findContestantFromPart = require(ServerStorage.Modules.findContestantFromPart);

local function swingBat(action: types.StrikeOutSwipeServerAction, bat: Accessory): ()

  assert(action.startChargeTimeMilliseconds);
  local batHandle = bat:FindFirstChild("Handle");
  assert(batHandle and batHandle:IsA("BasePart"));
  
  -- Reduce the stamina.
  action.contestant:updateStamina(action.contestant.currentStamina - action.requiredStamina, {
    contestantID = action.contestant.id;
    actionID = action.id;
  });

  -- Calculate the damage required.
  local startTime = action.startChargeTimeMilliseconds;
  action.startChargeTimeMilliseconds = nil;

  local charge = calculateCharge(startTime, action.maxChargeDurationMilliseconds);

  -- Run the swipe animation. Players should run animations on their own client.
  local player = action.contestant.player;
  if player and action.remoteFunction then

    action.remoteFunction:InvokeClient(player);

  else
    
    local character = action.contestant.character;
    local humanoid = if character then character:FindFirstChild("Humanoid") else nil;
    local animator = if humanoid then humanoid:FindFirstChild("Animator") else nil;

    if animator and animator:IsA("Animator") then

      local swingAnimation = Instance.new("Animation");
      swingAnimation.AnimationId = `rbxassetid://123556732066116`;
      local currentAnimationTrack = animator:LoadAnimation(swingAnimation);
      currentAnimationTrack.Looped = false;
      currentAnimationTrack:Play(0, 1, 8);

    end;

  end;

  -- Damage hit contestants.
  if action.touchedEvent then

    action.touchedEvent:Disconnect();

  end;

  if action.touchedExpirationTask then

    task.cancel(action.touchedExpirationTask);
    
  end;

  local immuneContestantIDs = {}
  action.touchedEvent = batHandle.Touched:Connect(function(basePart)
  
    local victim = findContestantFromPart(action.contestant.round.contestants, basePart);
    if victim and victim.id ~= action.contestant.id and not table.find(immuneContestantIDs, victim.id) then

      table.insert(immuneContestantIDs, victim.id);

      victim:updateHealth(math.max(victim.currentHealth - action.maxDamage * charge, 0), {
        actionID = action.id;
        contestantID = action.contestant.id;
      });

    end;

  end);

  action.touchedExpirationTask = task.delay(action.touchedTimeLimitSeconds, function()
  
    if action.touchedEvent then

      action.touchedEvent:Disconnect();

    end;

  end);

end;

return swingBat;