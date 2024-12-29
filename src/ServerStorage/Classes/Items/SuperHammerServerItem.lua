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

local SuperHammerServerItem = {
  ID = SuperHammerClientItem.ID;
  name = SuperHammerClientItem.name;
  description = SuperHammerClientItem.description;
};

export type Action = "Equip" | "Swing" | "Dequip";
export type Style = "Normal" | "Combo" | "Hyper";

function SuperHammerServerItem.new(): ServerItem

  local _contestant: ServerContestant? = nil;
  local _round: ServerRound? = nil;
  local _meshPart: MeshPart? = nil;
  local _remoteFunction: RemoteFunction? = nil;
  local _itemNumber: number? = nil;
  local _chargeTime: number? = nil;
  local style: Style = "Normal";

  local touchEvent: RBXScriptConnection?;
  local touchEventExpirationTask: thread?;

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

    if action == "Equip" then

      assert(not _meshPart, "Hammer is already equipped.");
      assert(_contestant and _contestant.character);

      -- Attach the hammer to the player's right hand.
      local humanoid: Instance? = _contestant.character:FindFirstChild("Humanoid");
      assert(humanoid and humanoid:IsA("Humanoid"));

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
          contestant = _contestant,
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
                    print(actualDamage);
                    possibleEnemyContestant:updateHealth(possibleEnemyContestant.currentHealth - actualDamage, {
                      contestant = _contestant;
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

      else

        -- TODO: Progressly lose stamina and auto-activate if stamina reaches 10 or less.
        _chargeTime = DateTime.now().UnixTimestampMillis;

      end;
      
    else

      warn(`Unknown action selected: {action}`);

    end;

    if _meshPart and _contestant.baseStamina >= 100 then

      -- Enable hyper mode.
      style = "Hyper";

      -- Add the animations.
      local animation = Instance.new("Animation");
      animation.AnimationId = "rbxassetid://107190738789069";
      
      local animationTrack = animator:LoadAnimation(animation);
      animationTrack.Looped = true;
      animationTrack.Priority = Enum.AnimationPriority.Core;
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
                    contestant = _contestant;
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

        touchEventExpirationTask = nil;

        animationTrack:Stop();

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

      _remoteFunction, _itemNumber = createInventoryRemoteFunction(contestant.player, self.ID, function(isActivation: unknown)
      
        assert(typeof(isActivation) == "boolean");
        
        local action: Action = if isActivation then (if _meshPart then "Swing" else "Equip") else "Dequip";
        self:activate(action);

      end);

      ReplicatedStorage.Shared.Functions.InitializeItem:InvokeClient(contestant.player, self.ID, _itemNumber);

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
