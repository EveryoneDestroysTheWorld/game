--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);
local IServerRound = require(ServerStorage.Interfaces.IServerRound);
local IStrikeOutSwipeServerAction = require(ServerStorage.Interfaces.IStrikeOutSwipeServerAction);
local RagdollService = require(ServerStorage.Modules.RagdollService);
local StrikeOutSwipeClientAction = require(ReplicatedStorage.Client.Classes.Actions.StrikeOutSwipeClientAction);

local calculateCharge = require(ServerStorage.Modules.calculateCharge);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local createInventoryRemoteEvent = require(ServerStorage.Modules.createInventoryRemoteEvent);
local findContestantFromPart = require(ServerStorage.Modules.findContestantFromPart);

type IStrikeOutSwipeServerAction = IStrikeOutSwipeServerAction.IStrikeOutSwipeServerAction;
type IServerContestant = IServerContestant.IServerContestant;
type IServerRound = IServerRound.IServerRound;

local StrikeOutSwipeServerAction = {
  id = StrikeOutSwipeClientAction.id;
  name = StrikeOutSwipeClientAction.name;
  description = StrikeOutSwipeClientAction.description;
};

function StrikeOutSwipeServerAction.new(contestant: IServerContestant, round: IServerRound): IStrikeOutSwipeServerAction

  local startChargeTimeMilliseconds: number?;
  local maxChargeDurationMilliseconds = 1000;
  local baseDamage = 12;
  local maxBonusDamage = 10;
  local requiredStamina = 5;
  local touchedTimeLimitSeconds = 0.8;
  local swingAnimationTrack;
  local touchedEvent;
  local touchedExpirationTask;

  local function activate(self: IStrikeOutSwipeServerAction, shouldCharge: boolean)

    assert(contestant.attributes.archetypeMode == "Batter", "Contestant must be in batter mode to use this action.");
    assert(contestant.currentStamina >= requiredStamina, "Insufficient stamina.");

    local function playSwingAnimation(): ()

      local player = contestant.player;
      if player and self.remoteFunction then
    
        self.remoteFunction:InvokeClient(player, shouldCharge);
    
      else
        
        local character = contestant.character;
        local humanoid = if character then character:FindFirstChild("Humanoid") else nil;
        local animator = if humanoid then humanoid:FindFirstChild("Animator") else nil;
    
        if animator and animator:IsA("Animator") then
    
          if swingAnimationTrack then
    
            swingAnimationTrack:Stop(0);
    
          end;
    
          local swingAnimation = Instance.new("Animation");
          swingAnimation.AnimationId = `rbxassetid://123556732066116`;
          local currentAnimationTrack = animator:LoadAnimation(swingAnimation);
          currentAnimationTrack.Looped = false;
          currentAnimationTrack:Play(if shouldCharge then 1 else 0, 1, if shouldCharge then 0 else 8);
          swingAnimationTrack = currentAnimationTrack;
    
        end;
    
      end;
    
    end;
    
    if shouldCharge then

      --[[
        Charges the contestant's bat before they swing it. The longer the charge, the bigger the WHAM!
      ]]
      local function chargeSwing(): ()

        local originalChargeTime = DateTime.now().UnixTimestampMillis;
        startChargeTimeMilliseconds = originalChargeTime;

        playSwingAnimation();

        task.spawn(function()
        
          while task.wait(0.05) and startChargeTimeMilliseconds == originalChargeTime do

            local player = contestant.player;
            if contestant.currentStamina <= requiredStamina then

              -- Let the player know to stop charging.
              if self.remoteEvent and player then

                self.remoteEvent:FireClient(player);

              end;

              self:activate(false);
              break;

            else

              contestant:setCurrentStamina(contestant.currentStamina - 1, {
                actionID = self.id;
                contestantID = contestant.id;
              });

            end;

          end;

        end);

      end;

      chargeSwing()

    else

      local function swingBat(): ()

        local character = contestant.character;
        local bat = if character then character:FindFirstChild("Bat") else nil;
        assert(bat and bat:IsA("Accessory"), "The contestant's bat is missing.");
        assert(startChargeTimeMilliseconds);
        local batHandle = bat:FindFirstChild("Handle");
        assert(batHandle and batHandle:IsA("BasePart"));
        
        -- Reduce the stamina.
        contestant:setCurrentStamina(contestant.currentStamina - requiredStamina, {
          contestantID = contestant.id;
          actionID = self.id;
        });

        -- Calculate the damage required.
        local startTime = startChargeTimeMilliseconds;
        startChargeTimeMilliseconds = nil;

        local charge = calculateCharge(startTime, maxChargeDurationMilliseconds);

        -- Run the swipe animation. Players should run animations on their own client.
        playSwingAnimation();

        -- Damage hit contestants.
        if touchedEvent then

          touchedEvent:Disconnect();

        end;

        if touchedExpirationTask then

          task.cancel(touchedExpirationTask);
          
        end;

        local immuneContestantIDs = {}
        touchedEvent = batHandle.Touched:Connect(function(basePart)
        
          local victim = findContestantFromPart(round:getContestants(), basePart);
          if victim and victim.id ~= contestant.id and not table.find(immuneContestantIDs, victim.id) then

            table.insert(immuneContestantIDs, victim.id);

            victim:updateHealth(math.max(victim.currentHealth - baseDamage - maxBonusDamage * charge, 0), {
              actionID = self.id;
              contestantID = contestant.id;
            });

            local character = victim.character;
            if character and not RagdollService.ragdolls[character] then

              local ragdollKey = `{contestant.id}-{self.id}`;
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

        touchedExpirationTask = task.delay(touchedTimeLimitSeconds, function()
        
          if touchedEvent then

            touchedEvent:Disconnect();

          end;

        end);

      end;

      swingBat();

    end;

  end;

  local function breakdown(self: IStrikeOutSwipeServerAction)

    if self.remoteFunction then

      self.remoteFunction:Destroy();
  
    end;
  
    if self.remoteEvent then
  
      self.remoteEvent:Destroy();
  
    end;
  
    if contestant.player then
  
      ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(contestant.player, self.id);
  
    end;

  end;

  local action: IStrikeOutSwipeServerAction = {
    attributes = {};
    contestantID = contestant.id;
    description = StrikeOutSwipeServerAction.description;
    id = StrikeOutSwipeServerAction.id;
    name = StrikeOutSwipeServerAction.name;
    activate = activate;
    breakdown = breakdown;
  }

  local player = contestant.player;
  if player then
  
    local remoteID = `{player.UserId}_{action.id}`;
    action.remoteFunction = createInventoryRemoteFunction(player, "Action", remoteID, function(shouldCharge: boolean)
    
      action:activate(shouldCharge);

    end);

    action.remoteEvent = createInventoryRemoteEvent(player, "Action", remoteID);

    ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

  end;

  return action;

end;

return StrikeOutSwipeServerAction;