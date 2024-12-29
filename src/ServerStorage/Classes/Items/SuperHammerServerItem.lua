--!strict
-- This module represents a Super Hammer on the server side. 
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 Beastslash

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local InsertService = game:GetService("InsertService");
local ServerStorage = game:GetService("ServerStorage");
local ServerContestant = require(script.Parent.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerItem = require(script.Parent.Parent.ServerItem);
type ServerItem = ServerItem.ServerItem;
local SuperHammerClientItem = require(ReplicatedStorage.Client.Classes.Items.SuperHammerClientItem);
local ServerRound = require(script.Parent.Parent.ServerRound);
type ServerRound = ServerRound.ServerRound;
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local createInventoryRemoteEvent = require(ServerStorage.Modules.createInventoryRemoteEvent);
local Effect = require(script.Parent.Parent.Effect);
type Effect = Effect.Effect;
local HttpService = game:GetService("HttpService");

local SuperHammerServerItem = {
  ID = SuperHammerClientItem.ID;
  name = SuperHammerClientItem.name;
  description = SuperHammerClientItem.description;
};

export type Action = "Equip" | "Swing" | "Dequip";
export type Style = "Normal" | "Combo" | "Hyper";

function SuperHammerServerItem.new(): ServerItem

  local _contestant: ServerContestant? = nil;
  local _specificItemID: string? = nil;
  local _round: ServerRound? = nil;
  local _meshPart: MeshPart? = nil;
  local _remoteFunction: RemoteFunction? = nil;
  local _remoteEvent: RemoteEvent? = nil;
  local _chargeTime: number? = nil;
  local style: Style = "Normal";

  local touchEvent: RBXScriptConnection?;
  local touchEventExpirationTask: thread?;
  local staminaReductionTask: thread?;
  local staminaRecoverySuppressionEffect: Effect?;
  local animationTrack: AnimationTrack;

  local function removeMeshPart()

    if _meshPart then

      if _meshPart.Parent and _meshPart.Parent:IsA("Accessory") then

        _meshPart.Parent:Destroy();

      else

        _meshPart:Destroy();

      end;

      _meshPart = nil;

    end;

  end;

  local function activate(self: ServerItem, action: Action): ()
    
    assert(_contestant, "This item must be assigned to a contestant.");
    assert(style ~= "Hyper", "Hammer is in hyper mode! No other actions are allowed.");

    local character = _contestant.character;
    assert(character, "The contestant must have a character.");

    local humanoid = character:FindFirstChild("Humanoid");
    assert(humanoid and humanoid:IsA("Humanoid"), "Character must have a Humanoid.");

    local animator = humanoid:FindFirstChild("Animator");
    assert(animator and animator:IsA("Animator"), "Humanoid must have an Animator.");

    if staminaReductionTask then

      if coroutine.status(staminaReductionTask) ~= "normal" then

        coroutine.close(staminaReductionTask);

      end;

      staminaReductionTask = nil;

    end;

    if staminaRecoverySuppressionEffect then

      _contestant:removeEffect(staminaRecoverySuppressionEffect);

    end;

    if animationTrack then

      animationTrack:Stop(0);

    end;

    if action == "Equip" then

      assert(not _meshPart, "Hammer is already equipped.");
      assert(_contestant and _contestant.character);

      local meshPart = InsertService:CreateMeshPartAsync("rbxassetid://95860572822356", Enum.CollisionFidelity.Default, Enum.RenderFidelity.Automatic);
      meshPart:SetAttribute("Durability", 100);
      meshPart.Name = "Handle";
      _meshPart = meshPart;

      local attachment = Instance.new("Attachment");
      attachment.Name = "RightGripAttachment";
      attachment.CFrame = CFrame.new(0, -2.9, 0);
      attachment.Parent = meshPart;

      local accessory = Instance.new("Accessory");
      accessory.Name = "Super Hammer";

      meshPart.Parent = accessory;

      humanoid:AddAccessory(accessory);

      -- TODO: Run the equip animation.

    elseif action == "Dequip" then

      assert(_meshPart, "Hammer is already dequipped.");

      -- TODO: Run the de-equip animation.

      -- Remove the hammer after the animation.
      removeMeshPart();

    elseif action == "Swing" then

      assert(_contestant.currentStamina >= 10, "The player's stamina must be 10 or greater.");
      assert(_meshPart, "The hammer must be equipped before the player swings.");

      if touchEvent then

        touchEvent:Disconnect();
        touchEvent = nil;

      end;

      if touchEventExpirationTask then

        task.cancel(touchEventExpirationTask);
        touchEventExpirationTask = nil;

      end;

      if _chargeTime then

        -- Reduce the user's stamina.
        _contestant:updateStamina(_contestant.currentStamina - 10, {
          contestantID = _contestant.ID,
          itemID = self.ID
        });

        -- Swing the hammer.
        local maxChargeBonusMultiplier = 1.5;
        local secondsTarget = 3;
        local secondsPassed = (DateTime.now().UnixTimestampMillis - _chargeTime) / 1000;
        local actualChargeBonusMultiplier = math.min(1 + (secondsPassed / secondsTarget) * (maxChargeBonusMultiplier - 1), maxChargeBonusMultiplier);
        local baseDamage = 10;
        local actualDamage = baseDamage * actualChargeBonusMultiplier;

        _chargeTime = nil;

        local immuneContestants = {};
        touchEvent = _meshPart.Touched:Connect(function(basePart)
        
          if _round then

            for _, possibleEnemyContestant in _round.contestants do

              task.spawn(function()
              
                local possibleEnemyCharacter = possibleEnemyContestant.character;
                if possibleEnemyContestant ~= _contestant and not table.find(immuneContestants, possibleEnemyContestant) and possibleEnemyCharacter and basePart:IsDescendantOf(possibleEnemyCharacter) then

                  local enemyHumanoid = possibleEnemyCharacter:FindFirstChild("Humanoid");
                  if enemyHumanoid then

                    -- Add immunity.
                    table.insert(immuneContestants, possibleEnemyContestant);

                    -- Take damage.
                    possibleEnemyContestant:updateHealth(possibleEnemyContestant.currentHealth - actualDamage, {
                      contestantID = _contestant.ID;
                      itemID = self.ID;
                    });

                  end;

                end;

              end);

            end;

          end;

        end);

        touchEventExpirationTask = task.delay(0.5, function()
        
          if touchEvent then

            touchEvent:Disconnect();

          end;

          touchEventExpirationTask = nil;

        end);

        -- Run the swing animation.
        local swingAnimation = Instance.new("Animation");
        swingAnimation.AnimationId = "rbxassetid://138240382406912";

        animationTrack = animator:LoadAnimation(swingAnimation);
        animationTrack.Priority = Enum.AnimationPriority.Action;
        animationTrack.Looped = false;
        animationTrack:Play();

      else

        -- Set the charge time.
        _chargeTime = DateTime.now().UnixTimestampMillis;

        -- Progressively lose stamina.
        staminaReductionTask = task.spawn(function()

          local effect = {
            name = "Stamina recovery suppression",
            id = "StaminaRecoverySuppression"
          }

          staminaRecoverySuppressionEffect = effect;

          _contestant:addEffect(effect);

          while _contestant.currentStamina > 10 and task.wait(0.1) do

            _contestant:updateStamina(_contestant.currentStamina - 1, {
              contestantID = _contestant.ID,
              itemID = self.ID
            });

          end;

          task.spawn(function()

            if _remoteEvent and _contestant.player then

              _remoteEvent:FireClient(_contestant.player);

            end;

            activate(self, action);
          
          end);

        end);

        -- Run the charge animation.
        local chargeAnimation = Instance.new("Animation");
        chargeAnimation.AnimationId = "rbxassetid://94520926777504";

        animationTrack = animator:LoadAnimation(chargeAnimation);
        animationTrack.Priority = Enum.AnimationPriority.Action;
        animationTrack.Looped = false;
        animationTrack:GetMarkerReachedSignal("FreezeFrame"):Connect(function()
        
          animationTrack:AdjustSpeed(0);

        end);
        animationTrack:Play();

      end;
      
    else

      warn(`Unknown action selected: {action}`);

    end;

    if _meshPart and _contestant.currentStamina >= 100 then

      -- Enable hyper mode.
      style = "Hyper";

      -- Make the contestant invincible for 10 seconds.
      local expirationTime = DateTime.now().UnixTimestampMillis + 10000;
      local effect: Effect = {
        name = "Invincibility",
        id = "Invincibility",
        expirationTimeMilliseconds = expirationTime,
        onBeforeHealthChange = function(newHealth, oldHealth)

          return if newHealth > oldHealth then newHealth else oldHealth;

        end
      };

      _contestant:addEffect(effect);

      -- Add the animations.
      local animation = Instance.new("Animation");
      animation.AnimationId = "rbxassetid://107190738789069";
      
      animationTrack = animator:LoadAnimation(animation);
      animationTrack.Looped = true;
      animationTrack.Priority = Enum.AnimationPriority.Action;
      animationTrack:Play(0, 1, 2);

      local immuneContestants = {};
      touchEvent = _meshPart.Touched:Connect(function(basePart)
        
        if _round then

          for _, possibleEnemyContestant in _round.contestants do

            task.spawn(function()
            
              local possibleEnemyCharacter = possibleEnemyContestant.character;
              if possibleEnemyContestant ~= _contestant and not table.find(immuneContestants, possibleEnemyContestant) and possibleEnemyCharacter and basePart:IsDescendantOf(possibleEnemyCharacter) then

                local enemyHumanoid = possibleEnemyCharacter:FindFirstChild("Humanoid");
                if enemyHumanoid then

                  -- Add immunity.
                  table.insert(immuneContestants, possibleEnemyContestant);
                  task.delay(0.25, function()
                  
                    table.remove(immuneContestants, table.find(immuneContestants, possibleEnemyContestant));

                  end);

                  -- Take damage.
                  possibleEnemyContestant:updateHealth(possibleEnemyContestant.currentHealth - 10, {
                    contestantID = _contestant.ID;
                    itemID = self.ID;
                  });

                end;

              end;

            end);

          end;

        end;

      end);

      touchEventExpirationTask = task.delay(10, function()
      
        if touchEvent then

          touchEvent:Disconnect();

        end;

        _contestant:removeEffect(effect);

        touchEventExpirationTask = nil;

        animationTrack:Stop();

        -- TODO: Dequip the hammer.

      end);

    end;
    
  end;
  
  local function breakdown(self: ServerItem)

    if _contestant and _contestant.player then

      ReplicatedStorage.Shared.Functions.BreakdownItem:InvokeClient(_contestant.player, self.ID);

    end;

    removeMeshPart();
    
  end;

  local function initialize(self: ServerItem, contestant: ServerContestant, round: ServerRound)

    _contestant = contestant;
    _round = round;

    if contestant.player then

      local specificItemID = HttpService:GenerateGUID(false);
      _remoteFunction = createInventoryRemoteFunction(contestant.player, specificItemID, function(isActivation)
      
        assert(typeof(isActivation) == "boolean");
        
        local action: Action = if isActivation then (if _meshPart then "Swing" else "Equip") else "Dequip";
        self:activate(action);

      end);

      _remoteEvent = createInventoryRemoteEvent(contestant.player, specificItemID);

      ReplicatedStorage.Shared.Functions.InitializeItem:InvokeClient(contestant.player, self.ID, specificItemID);

    end;

  end;

  local item = ServerItem.new({
    ID = SuperHammerServerItem.ID;
    name = SuperHammerServerItem.name;
    description = SuperHammerServerItem.description;
    activate = activate;
    breakdown = breakdown;
    initialize = initialize;
  });
  
  return item;

end;

return SuperHammerServerItem;
