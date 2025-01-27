--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local DetonateDetachedLimbsClientAction = require(ReplicatedStorage.Client.Classes.Actions.DetonateDetachedLimbsClientAction);
local types = require(ServerStorage.Classes.types);

local assertContestantIsNotActionLocked = require(ServerStorage.Modules.assertContestantIsNotActionLocked);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local removeDetachLimbBaseModifiers = require(ServerStorage.Modules.removeDetachLimbBaseModifiers);

local DetonateDetachedLimbsServerAction = {
  id = DetonateDetachedLimbsClientAction.id;
  name = DetonateDetachedLimbsClientAction.name;
  description = DetonateDetachedLimbsClientAction.description;
  __index = {} :: types.DetonateDetachedLimbsServerAction;
};

function DetonateDetachedLimbsServerAction.new(properties: types.ServerActionConstructorProperties): types.DetonateDetachedLimbsServerAction

  local overwrittenProperties = {
    name = DetonateDetachedLimbsServerAction.name;
    id = DetonateDetachedLimbsServerAction.id;
    description = DetonateDetachedLimbsServerAction.description;
    contestant = properties.contestant;
    round = properties.round;
  }

  local action = (setmetatable(overwrittenProperties, DetonateDetachedLimbsServerAction) :: any) :: types.DetonateDetachedLimbsServerAction;

  if action.contestant.player then

    action.remoteFunction = createInventoryRemoteFunction(action.contestant.player, "Action", `{action.contestant.player.UserId}_{action.id}`, function()
    
      action:activate();

    end);

  end;
  
  return action;

end;

function DetonateDetachedLimbsServerAction.__index:activate()

  -- Verify that actions aren't locked.
  assertContestantIsNotActionLocked(self.contestant);

  -- Make sure the player has enough stamina.
  assert(self.contestant.currentStamina >= 20, "Contestant doesn't have enough stamina.");

  local detachedLimbs = ServerStorage.Functions.ActionFunctions:FindFirstChild(`{self.contestant.id}_GetDetachedLimbs`):Invoke();
  local didReduceStamina = false;

  for limbName, instance in detachedLimbs do

    -- Reduce stamina once.
    if not didReduceStamina then

      didReduceStamina = true;
      
      self.contestant:updateStamina(math.max(self.contestant.currentStamina - 20, 0), {
        actionID = self.id;
      });

    end;

    -- Use task.spawn so that they all explode at the same time.
    task.spawn(function()
      
      -- Create an explosion at the limb's location.
      local explosion = Instance.new("Explosion");
      explosion.BlastPressure = 5000000;
      explosion.BlastRadius = 20;
      explosion.DestroyJointRadiusPercent = 0;
      explosion.Position = (if instance:IsA("Model") then instance.PrimaryPart else instance).CFrame.Position;
      local hitContestants = {};
      explosion.Hit:Connect(function(basePart)

        -- Damage any parts or contestants that get hit.
        for _, possibleEnemyContestant in ipairs(self.round.contestants) do

          task.spawn(function()

            local possibleEnemyCharacter = possibleEnemyContestant.character;
            if possibleEnemyContestant ~= self.contestant and not table.find(hitContestants, possibleEnemyContestant) and possibleEnemyCharacter and basePart:IsDescendantOf(possibleEnemyCharacter) then

              table.insert(hitContestants, possibleEnemyContestant);
              possibleEnemyContestant:updateHealth(possibleEnemyContestant.currentHealth - 15, {
                contestantID = self.contestant.id;
                actionID = DetonateDetachedLimbsServerAction.id;
              });

            end;

          end);

        end;

        local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability");
        if basePartCurrentDurability and typeof(basePartCurrentDurability) == "number" and basePartCurrentDurability > 0 then

          ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - 25, self.contestant);

        end;

      end);
      explosion.Parent = workspace;
      instance:Destroy();

      if self.contestant.character then

        
        -- Add the limb and HP back to the player.
        local humanoid = self.contestant.character:FindFirstChild("Humanoid");
        assert(humanoid and humanoid:IsA("Humanoid"), `Couldn't find {self.contestant.name}'s humanoid`);
        
        removeDetachLimbBaseModifiers(self.contestant);

      end;

    end);

  end;

end;

function DetonateDetachedLimbsServerAction.__index:breakdown()

  if self.remoteFunction then

    self.remoteFunction:Destroy();

  end;

end;

return DetonateDetachedLimbsServerAction;