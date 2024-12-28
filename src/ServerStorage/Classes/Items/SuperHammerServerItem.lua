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
type Mode = SuperHammerClientItem.Mode;
local ServerRound = require(script.Parent.Parent.ServerRound);
type ServerRound = ServerRound.ServerRound;
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);

local SuperHammerServerItem = {
  ID = SuperHammerClientItem.ID;
  name = SuperHammerClientItem.name;
  description = SuperHammerClientItem.description;
};

function SuperHammerServerItem.new(): ServerItem

  local _contestant: ServerContestant? = nil;
  local _round: ServerRound? = nil;
  local _mode: Mode = "Dequipped";
  local _meshPart: MeshPart? = nil;
  local _remoteFunction: RemoteFunction? = nil;
  local _itemNumber: number? = nil;
  local _chargeTime: number? = nil;

  local touchEvent: RBXScriptConnection?;
  local touchEventExpirationTask: thread?;

  local function activate(self: ServerItem, mode: Mode): ()
    
    assert(_contestant, "This item must be assigned to a contestant.");

    if mode == "Equipped" then

      assert(_contestant and _contestant.character and _meshPart);

      -- Attach the hammer to the player's right hand.
      local humanoid: Instance? = _contestant.character:FindFirstChild("Humanoid");
      assert(humanoid and humanoid:IsA("Humanoid"));

      local attachment = Instance.new("Attachment");
      attachment.Name = "RightGripAttachment";
      attachment.CFrame = CFrame.new(0, -2.9, 0);
      attachment.Parent = _meshPart;

      local accessory = Instance.new("Accessory");
      accessory.Name = "Super Hammer";

      _meshPart.Name = "Handle";
      _meshPart.Parent = accessory;
      _mode = mode;

      humanoid:AddAccessory(accessory);

      -- TODO: Run the equip animation.

    elseif mode == "Dequipped" then

      assert(_meshPart);

      _meshPart.CanCollide = false;
      _meshPart.Transparency = 1;

      -- TODO: Run the de-equip animation.

    elseif mode == "Swing" then

      assert(_contestant.currentStamina >= 10, "The player's stamina must be 10 or greater.");
      assert(_meshPart, "The hammer must be equipped before the player swings.");

      _mode = mode;

      -- Reduce the user's stamina.
      _contestant:updateStamina(_contestant.currentStamina - 10, {
        contestant = _contestant,
        itemID = self.ID
      });

      -- Swing the hammer.
      local maxChargeBonusMultiplier = 1.2;
      local maxChargeSeconds = 3;
      local actualChargeBonusMultiplier = (if _chargeTime then math.min((os.time() - _chargeTime) / maxChargeSeconds, maxChargeBonusMultiplier) else 1);
      local baseDamage = 10;
      -- local actualDamage = baseDamage * actualChargeBonusMultiplier;
      local actualDamage = baseDamage;

      _chargeTime = nil;

      -- 
      if touchEvent then

        touchEvent:Disconnect();
        touchEvent = nil;

      end;

      if touchEventExpirationTask then

        task.cancel(touchEventExpirationTask);
        touchEventExpirationTask = nil;

      end;

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

      -- TODO: Play the swing animation.

    elseif mode == "Charge" then

      _mode = mode;
      _chargeTime = os.time();

      -- TODO: Play the charge animation.
      
    else

      warn(`Unknown mode selected: {mode}`);

    end;
    
  end;
  
  local function breakdown(self: ServerItem)

    if _contestant and _contestant.player then

      ReplicatedStorage.Shared.Functions.BreakdownItem:InvokeClient(_contestant.player, self.ID);

    end;

    if _meshPart then

      if _meshPart.Parent and _meshPart.Parent:IsA("Accessory") then

        _meshPart.Parent:Destroy();

      else

        _meshPart:Destroy();

      end;

      _meshPart = nil;

    end;
    
  end;

  local function initialize(self: ServerItem, contestant: ServerContestant, round: ServerRound)

    _contestant = contestant;
    _round = round;
    local meshPart = InsertService:CreateMeshPartAsync("rbxassetid://95860572822356", Enum.CollisionFidelity.Default, Enum.RenderFidelity.Automatic);
    meshPart:SetAttribute("Durability", 100);
    _meshPart = meshPart;

    if contestant.player then

      _remoteFunction, _itemNumber = createInventoryRemoteFunction(contestant.player, self.ID, function(mode: unknown)
      
        assert(mode == "Dequipped" or mode == "Equipped" or mode == "Swing" or mode == "Charge");
        self:activate(mode);

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
