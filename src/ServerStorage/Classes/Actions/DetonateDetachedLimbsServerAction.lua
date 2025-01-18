--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerAction = require(script.Parent.Parent.ServerAction);
local DetonateDetachedLimbsClientAction = require(ReplicatedStorage.Client.Classes.Actions.DetonateDetachedLimbsClientAction);
local types = require(ServerStorage.Classes.types);
local assertContestantIsNotActionLocked = require(ServerStorage.Modules.assertContestantIsNotActionLocked);

local DetonateDetachedLimbsServerAction = {
  id = DetonateDetachedLimbsClientAction.id;
  name = DetonateDetachedLimbsClientAction.name;
  description = DetonateDetachedLimbsClientAction.description;
};

function DetonateDetachedLimbsServerAction.new(): types.ServerAction

  local contestant: types.ServerContestant = nil;
  local round: types.ServerRound = nil;
  local function activate(self: types.ServerAction)

    -- Verify that actions aren't locked.
    assertContestantIsNotActionLocked(contestant);

    -- Make sure the player has enough stamina.
    assert(contestant.currentStamina >= 20, "Contestant doesn't have enough stamina.");

    local detachedLimbs = ServerStorage.Functions.ActionFunctions:FindFirstChild(`{contestant.id}_GetDetachedLimbs`):Invoke(contestant);

    local didReduceStamina = false;

    for limbName, instance in detachedLimbs do

      -- Reduce stamina once.
      if not didReduceStamina then

        didReduceStamina = true;
        
        contestant:updateStamina(math.max(contestant.currentStamina - 20, 0), {
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
          for _, possibleEnemyContestant in ipairs(round.contestants) do

            task.spawn(function()

              local possibleEnemyCharacter = possibleEnemyContestant.character;
              if possibleEnemyContestant ~= contestant and not table.find(hitContestants, possibleEnemyContestant) and possibleEnemyCharacter and basePart:IsDescendantOf(possibleEnemyCharacter) then

                table.insert(hitContestants, possibleEnemyContestant);
                possibleEnemyContestant:updateHealth(possibleEnemyContestant.currentHealth - 15, {
                  contestantID = contestant.id;
                  actionID = DetonateDetachedLimbsServerAction.id;
                });

              end;

            end);

          end;

          local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability");
          if basePartCurrentDurability and typeof(basePartCurrentDurability) == "number" and basePartCurrentDurability > 0 then
  
            ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - 25, contestant);
  
          end;
  
        end);
        explosion.Parent = workspace;
        instance:Destroy();

        if contestant.character then

          
          -- Add the limb and HP back to the player.
          local humanoid = contestant.character:FindFirstChild("Humanoid");
          assert(humanoid and humanoid:IsA("Humanoid"), `Couldn't find {contestant.character.Name}'s humanoid`);

          humanoid.MaxHealth += 19;

        end;

      end);

    end;

  end;

  local remoteFunction: RemoteFunction?;
  local function breakdown()

    if remoteFunction then

      remoteFunction:Destroy();

    end;

  end;

  local function initialize(self: types.ServerAction, newContestant: types.ServerContestant, newRound: types.ServerRound)

    contestant = newContestant;
    round = newRound;

    if contestant.player then
    
      local actionRemoteFunction = Instance.new("RemoteFunction");
      actionRemoteFunction.Name = `{contestant.player.UserId}_{self.id}`;
      actionRemoteFunction.OnServerInvoke = function(player)
  
        if player == contestant.player then
  
          self:activate();
  
        else
  
          -- That's weird.
          error("Unauthorized.");
  
        end
  
      end;
      actionRemoteFunction.Parent = ReplicatedStorage.Shared.Functions.ActionFunctions;
      remoteFunction = actionRemoteFunction;
  
    end;

  end;

  return ServerAction.new({
    name = DetonateDetachedLimbsServerAction.name;
    id = DetonateDetachedLimbsServerAction.id;
    description = DetonateDetachedLimbsServerAction.description;
    breakdown = breakdown;
    activate = activate;
    initialize = initialize;
  });

end;

return DetonateDetachedLimbsServerAction;