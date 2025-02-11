--!strict
-- This module represents a Super Hammer on the server side. 
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 Beastslash

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local InsertService = game:GetService("InsertService");
local ServerStorage = game:GetService("ServerStorage");
local ServerItem = require(script.Parent.Parent.ServerItem);
local SuperHammerClientItem = require(ReplicatedStorage.Client.Classes.Items.SuperHammerClientItem);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local createInventoryRemoteEvent = require(ServerStorage.Modules.createInventoryRemoteEvent);
local ServerEffect = require(ServerStorage.Classes.ServerEffect);
local HttpService = game:GetService("HttpService");
local types = require(ServerStorage.Modules.types);

local SuperHammerServerItem = {
  id = SuperHammerClientItem.id;
  name = SuperHammerClientItem.name;
  description = SuperHammerClientItem.description;
};

export type Action = "Equip" | "Swing" | "Dequip";
export type Style = "Normal" | "Combo" | "Hyper";

function SuperHammerServerItem.new(): types.ServerItem

  local _contestant: types.ServerContestant? = nil;
  local _specificItemID: string? = nil;
  local _round: types.ServerRound? = nil;
  local _meshPart: MeshPart? = nil;
  local _remoteFunction: RemoteFunction? = nil;
  local _remoteEvent: RemoteEvent? = nil;
  local _chargeTime: number? = nil;
  local style: Style? = nil;
  local swipesLeft = 3;
  local comboCount = 0;
  local isLocked = false;

  local touchEvent: RBXScriptConnection?;
  local touchEventExpirationTask: thread?;
  local staminaReductionTask: thread?;
  local comboBreakingTask: thread?;
  local staminaRecoverySuppressionEffect: types.ServerEffect?;
  local animationTrack: AnimationTrack;
  local stunnedContestants: {[types.ServerContestant]: {AlignOrientation | AlignPosition}} = {};

  local function activate(self: types.ServerItem, action: Action): ()
    
    assert(style ~= "Hyper", "Hammer is in hyper mode! No other actions are allowed.");
    assert(_contestant, "This item must be assigned to a contestant.");

    if not style then

      local baseStamina = _contestant:getModifiedBaseValue("Stamina");
      style = if _contestant.currentStamina >= baseStamina then "Hyper" elseif _contestant.currentStamina / baseStamina >= 0.5 then "Combo" else "Normal";

    end;

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

      animationTrack:Stop(0.1);

    end;

    local shouldSwing = true;
    if not _meshPart then

      assert(not _meshPart, "Hammer is already equipped.");
      assert(_contestant and _contestant.character);

      shouldSwing = false;
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

    end;

    if (style == "Normal" and swipesLeft <= 0) or comboCount >= 10 then

      if isLocked then

        return;

      end;

      if comboBreakingTask then

        task.cancel(comboBreakingTask);
        comboBreakingTask = nil;

      end;

      self:breakdown();

    elseif style == "Hyper" :: any then

      assert(_meshPart);

      -- Make the contestant invincible for 10 seconds.
      local invincibilityEffect = ServerEffect.get("Invincibility").new({
        contestant = _contestant;
        expirationTimeMilliseconds = DateTime.now().UnixTimestampMillis + 10000;
      });

      local holdingHeavyItemEffect = ServerEffect.get("HoldingHeavyItem").new({
        contestant = _contestant;
      });

      _contestant:addEffect(invincibilityEffect);
      _contestant:addEffect(holdingHeavyItemEffect);

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
                    contestantID = _contestant.id;
                    itemID = self.id;
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

        _contestant:removeEffect(invincibilityEffect);
        _contestant:removeEffect(holdingHeavyItemEffect);

        touchEventExpirationTask = nil;

        animationTrack:Stop();

        self:breakdown();

      end);

    elseif shouldSwing then

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

        if comboBreakingTask then

          task.cancel(comboBreakingTask);
          comboBreakingTask = nil;
  
        end;

        -- Reduce the user's stamina.
        _contestant:updateStamina(_contestant.currentStamina - 10, {
          contestantID = _contestant.id,
          itemID = self.id
        });

        -- Swing the hammer.
        local maxChargeBonusMultiplier = 1.5;
        local secondsTarget = 3;
        local chargeTimeDifference = DateTime.now().UnixTimestampMillis - _chargeTime;
        local secondsPassed = chargeTimeDifference / 1000;
        local actualChargeBonusMultiplier = math.min(1 + (secondsPassed / secondsTarget) * (maxChargeBonusMultiplier - 1), maxChargeBonusMultiplier);
        local baseDamage = if style == "Normal" then 10 else 5;
        local actualDamage = baseDamage * actualChargeBonusMultiplier;

        _chargeTime = nil;

        local immuneContestants = {};
        local swipesLeftIfHit = swipesLeft - 1;
        
        local onEnemyHit = Instance.new("BindableEvent");
        onEnemyHit.Event:Once(function()
        
          if style == "Normal" then

            swipesLeft = swipesLeftIfHit;

          elseif style == "Combo" then

            comboCount += 1;

            if _remoteEvent and _contestant.player then

              _remoteEvent:FireClient(_contestant.player, "Combo", comboCount);

            end;

            if comboCount >= 10 then

              -- Fling the victims.
              for contestant, alignmentObjects in pairs(stunnedContestants) do

                if contestant ~= _contestant then

                  for _, alignmentObject in alignmentObjects do

                    alignmentObject:Destroy();

                  end;

                  local humanoidRootPart = if contestant.character then contestant.character:FindFirstChild("HumanoidRootPart") else nil;
                  local rootAttachment = if humanoidRootPart then humanoidRootPart:FindFirstChild("RootAttachment") else nil;
                  if humanoidRootPart and humanoidRootPart:IsA("BasePart") and rootAttachment and rootAttachment:IsA("Attachment") then

                    local linearVelocity = Instance.new("LinearVelocity");
                    linearVelocity.Attachment0 = rootAttachment;
                    linearVelocity.Parent = humanoidRootPart;
                    linearVelocity.VectorVelocity = (humanoidRootPart.Position - _meshPart.Position).Unit * 500;
                    linearVelocity.MaxForce = math.huge;
                    task.delay(1, function()
                    
                      linearVelocity:Destroy();

                    end);

                  end;
                  
                end;

              end;

              task.wait(0.5);
              self:breakdown();

            else 

              comboBreakingTask = task.delay(1.5, function()
              
                self:breakdown();

              end);

            end;

          end

        end);

        touchEvent = _meshPart.Touched:Connect(function(basePart)
        
          if _round then

            for _, possibleEnemyContestant in _round.contestants do

              task.spawn(function()
              
                local possibleEnemyCharacter = possibleEnemyContestant.character;
                if possibleEnemyContestant ~= _contestant and possibleEnemyCharacter and basePart:IsDescendantOf(possibleEnemyCharacter) and not table.find(immuneContestants, possibleEnemyContestant) then

                  onEnemyHit:Fire();

                  -- Remove a swipe.
                  if style == "Combo" then

                    if comboCount < 10 then

                      -- Freeze the user and the victim.
                      local function stunLockContestant(contestant: types.ServerContestant)

                        if not contestant.character then

                          return;

                        end;

                        local humanoid = contestant.character:FindFirstChild("Humanoid");
                        if humanoid and humanoid:IsA("Humanoid") then

                          humanoid.AutoRotate = false;

                        end;

                        local humanoidRootPart = contestant.character:FindFirstChild("HumanoidRootPart");
                        if not humanoidRootPart or not humanoidRootPart:IsA("BasePart") then

                          return;

                        end;

                        local attachment = humanoidRootPart:FindFirstChild("RootAttachment");
                        if not attachment or not attachment:IsA("Attachment") then 
                          
                          return;

                        end;

                        stunnedContestants[contestant] = stunnedContestants[contestant] or {};
                        if not humanoidRootPart:FindFirstChild("SuperHammerStunLockOrientation") then

                          local alignOrientation = Instance.new("AlignOrientation");
                          alignOrientation.Name = "SuperHammerStunLockOrientation";
                          alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment;
                          alignOrientation.CFrame = humanoidRootPart.CFrame;
                          alignOrientation.MaxTorque = math.huge;
                          alignOrientation.Attachment0 = attachment;
                          alignOrientation.Parent = humanoidRootPart;
                          table.insert(stunnedContestants[contestant], alignOrientation);

                        end;

                        if not humanoidRootPart:FindFirstChild("SuperHammerStunLockPosition") then

                          local alignPosition = Instance.new("AlignPosition");
                          alignPosition.Name = "SuperHammerStunLockPosition";
                          alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment;
                          alignPosition.Position = humanoidRootPart.Position;
                          alignPosition.MaxForce = math.huge;
                          alignPosition.Attachment0 = attachment;
                          alignPosition.Parent = humanoidRootPart;
                          table.insert(stunnedContestants[contestant], alignPosition);

                        end;

                      end;

                      stunLockContestant(_contestant);
                      stunLockContestant(possibleEnemyContestant);

                    end;

                  end;


                  -- Add immunity.
                  table.insert(immuneContestants, possibleEnemyContestant);

                  -- Take damage.
                  possibleEnemyContestant:updateHealth(possibleEnemyContestant.currentHealth - actualDamage, {
                    contestantID = _contestant.id;
                    itemID = self.id;
                  });

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
        swingAnimation.AnimationId = `rbxassetid://{if style == "Combo" then "134304304008463" else "138240382406912"}`;

        animationTrack = animator:LoadAnimation(swingAnimation);
        animationTrack.Priority = Enum.AnimationPriority.Action;
        animationTrack.Looped = false;
        animationTrack.Stopped:Once(function()
        
          if swipesLeft <= 0 and style == "Normal" then

            self:breakdown();

          end;

        end);

        animationTrack:Play(0.1, 1, 1.15);

        if style == "Combo" and _round then

          if comboCount == 9 then

            animationTrack:AdjustSpeed(0);
            animationTrack.TimePosition = animationTrack:GetTimeOfKeyframe("End");

          else

            animationTrack:GetMarkerReachedSignal("Impact"):Once(function()
            
              local shouldSkipToDrive = true;
              for _, part in _meshPart:GetTouchingParts() do

                for _, contestant in _round.contestants do

                  if contestant.id ~= _contestant.id and contestant.character and part:IsDescendantOf(contestant.character) then

                    shouldSkipToDrive = false;
                    break;

                  end;

                end;

                if shouldSkipToDrive then

                  animationTrack.TimePosition = animationTrack:GetTimeOfKeyframe("Drive");
                  break;

                end;

              end;
              
            end);
            
            if animationTrack.Length > 0 then

              animationTrack.TimePosition = animationTrack:GetTimeOfKeyframe("Release");

            end

          end;

        end;

      else

        -- Set the charge time.
        _chargeTime = DateTime.now().UnixTimestampMillis;

        -- Progressively lose stamina.
        staminaReductionTask = task.spawn(function()

          local effect = ServerEffect.get("StaminaRecoverySuppression").new();

          staminaRecoverySuppressionEffect = effect;

          _contestant:addEffect(effect);

          while _contestant.currentStamina > 10 and task.wait(0.1) do

            _contestant:updateStamina(_contestant.currentStamina - 1, {
              contestantID = _contestant.id,
              itemID = self.id
            });

          end;

          task.spawn(function()

            if _remoteEvent and _contestant.player then

              _remoteEvent:FireClient(_contestant.player, "Swing");

            end;

            self:activate();
          
          end);

        end);

        -- Run the charge animation.
        local chargeAnimation = Instance.new("Animation");
        chargeAnimation.AnimationId = `rbxassetid://{if comboCount == 9 then "100467112930853" else "134304304008463"}`;

        animationTrack = animator:LoadAnimation(chargeAnimation);
        animationTrack.Priority = Enum.AnimationPriority.Action;
        animationTrack.Looped = comboCount == 9;

        if comboCount ~= 9 then

          animationTrack:GetMarkerReachedSignal("Release"):Connect(function()
          
            animationTrack:AdjustSpeed(0);

          end);
        
        end;
        animationTrack:Play(0.1, 1, if comboCount == 9 then 9 else 1);

      end;

    end;
    
  end;
  
  local function breakdown(self: types.ServerItem)

    if animationTrack then

      animationTrack:Stop();

    end;

    for contestant, objects in pairs(stunnedContestants) do

      local humanoid = if contestant.character then contestant.character:FindFirstChild("Humanoid") else nil;
      if humanoid and humanoid:IsA("Humanoid") then

        humanoid.AutoRotate = true;

      end;

      for _, object in objects do

        object:Destroy();

      end;

    end;

    if _contestant and _contestant.player then

      ReplicatedStorage.Shared.Functions.BreakdownItem:InvokeClient(_contestant.player, self.id, _specificItemID);
      _contestant = nil;

    end;

    if _remoteFunction then

      _remoteFunction:Destroy();
      _remoteFunction = nil;

    end;

    if _remoteEvent then

      _remoteEvent:Destroy();
      _remoteEvent = nil;

    end;

    if touchEvent then

      touchEvent:Disconnect();
      touchEvent = nil;

    end;

    if touchEventExpirationTask then

      task.cancel(touchEventExpirationTask);
      touchEventExpirationTask = nil;

    end;

    if _meshPart then

      _meshPart.Anchored = true;
      _meshPart.CanCollide = false;

      local weld = _meshPart:FindFirstChild("AccessoryWeld");
      if weld then

        weld:Destroy();

      end;

      local attachment = _meshPart:FindFirstChild("RightGripAttachment");
      if attachment and attachment:IsA("Attachment") then

        local alignOrientation = Instance.new("AlignOrientation");
        alignOrientation.CFrame = CFrame.new();
        alignOrientation.Attachment0 = attachment;
        alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment;
        alignOrientation.MaxTorque = math.huge;
        alignOrientation.Parent = _meshPart;

        local alignPosition = Instance.new("AlignPosition");
        alignPosition.Attachment0 = attachment;
        alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment;
        alignPosition.Position = _meshPart.Position + Vector3.new(0, 5, 0);
        alignPosition.MaxForce = math.huge;
        alignPosition.Parent = _meshPart;
        
        _meshPart.Anchored = false;

        task.delay(0.3, function()

          alignOrientation:Destroy();
          alignPosition:Destroy();
        
        end);

      end;

      task.delay(2, function()
      
        if _meshPart then

          if _meshPart.Parent and _meshPart.Parent:IsA("Accessory") then

            _meshPart.Parent:Destroy();
    
          else
    
            _meshPart:Destroy();
    
          end;
    
          _meshPart = nil;

        end;

      end);

    end;
    
  end;

  local function initialize(self: types.ServerItem, contestant: types.ServerContestant, round: types.ServerRound)

    _contestant = contestant;
    _round = round;

    if contestant.player then

      local specificItemID = HttpService:GenerateGUID(false);
      _specificItemID = specificItemID;
      _remoteFunction = createInventoryRemoteFunction(contestant.player, "Item", specificItemID, function()
        
        self:activate();

      end);

      _remoteEvent = createInventoryRemoteEvent(contestant.player, "Item", specificItemID);

      ReplicatedStorage.Shared.Functions.InitializeItem:InvokeClient(contestant.player, self.id, specificItemID);

    end;

  end;

  local item = ServerItem.new({
    id = SuperHammerServerItem.id;
    name = SuperHammerServerItem.name;
    description = SuperHammerServerItem.description;
    activate = activate;
    breakdown = breakdown;
    initialize = initialize;
  });
  
  return item;

end;

return SuperHammerServerItem;
