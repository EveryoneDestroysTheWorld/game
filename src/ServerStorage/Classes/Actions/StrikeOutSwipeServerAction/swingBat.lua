--!strict

local ServerStorage = game:GetService("ServerStorage");

local RagdollService = require(ServerStorage.Modules.RagdollService);
local types = require(ServerStorage.Modules.types);

local calculateCharge = require(ServerStorage.Modules.calculateCharge);
local findContestantFromPart = require(ServerStorage.Modules.findContestantFromPart);
local playSwingAnimation = require(script.Parent.playSwingAnimation);

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
  playSwingAnimation(action, false);

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

      victim:updateHealth(math.max(victim.currentHealth - action.baseDamage - action.maxBonusDamage * charge, 0), {
        actionID = action.id;
        contestantID = action.contestant.id;
      });

      local character = victim.character;
      if character and not RagdollService.ragdolls[character] then

        local ragdollKey = `{action.contestant.id}-{action.id}`;
        RagdollService:ragdollCharacter(character, ragdollKey);

        task.delay(0.5, function()
        
          RagdollService:restoreCharacter(character, ragdollKey);

        end);

        local primaryPart = character.PrimaryPart;
        if primaryPart then

          local force = primaryPart.CFrame:VectorToObjectSpace(primaryPart.Position - batHandle.Position) * 100;
          primaryPart:ApplyImpulse(force);

        end;

      end;

    end;

  end);

  action.touchedExpirationTask = task.delay(action.touchedTimeLimitSeconds, function()
  
    if action.touchedEvent then

      action.touchedEvent:Disconnect();

    end;

  end);

end;

return swingBat;