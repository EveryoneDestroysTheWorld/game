--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerContestant = require(script.Parent.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerAction = require(script.Parent.Parent.ServerAction);
type ServerAction = ServerAction.ServerAction;
local DetonateDetachedLimbsClientAction = require(ReplicatedStorage.Client.Classes.Actions.DetonateDetachedLimbsClientAction);
local Round = require(script.Parent.Parent.Round);
type Round = Round.Round;

local DetonateDetachedLimbsServerAction = {
  ID = DetonateDetachedLimbsClientAction.ID;
  name = DetonateDetachedLimbsClientAction.name;
  description = DetonateDetachedLimbsClientAction.description;
};

function DetonateDetachedLimbsServerAction.new(contestant: ServerContestant, round: Round): ServerAction

  local function activate()

    for limbName, instance in pairs(ServerStorage.Functions.ActionFunctions:FindFirstChild(`{contestant.ID}_GetDetachedLimbs`):Invoke(contestant)) do

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
          -- Damage any parts or contestants that get hit.
          for _, possibleEnemyContestant in ipairs(round.contestants) do

            task.spawn(function()

              local possibleEnemyCharacter = possibleEnemyContestant.character;
              if possibleEnemyContestant ~= contestant and not table.find(hitContestants, possibleEnemyContestant) and possibleEnemyCharacter and basePart:IsDescendantOf(possibleEnemyCharacter) then

                table.insert(hitContestants, possibleEnemyContestant);
                local enemyHumanoid = possibleEnemyCharacter:FindFirstChild("Humanoid");
                if enemyHumanoid then

                  local newHealth = enemyHumanoid:GetAttribute("CurrentHealth") - 15;
                  possibleEnemyContestant:updateHealth(newHealth, {
                    contestant = contestant;
                    actionID = DetonateDetachedLimbsServerAction.ID;
                  });

                end;

              end;

            end);

          end;

          local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability");
          if basePartCurrentDurability and basePartCurrentDurability > 0 then
  
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

  local action = ServerAction.new({
    name = DetonateDetachedLimbsServerAction.name;
    ID = DetonateDetachedLimbsServerAction.ID;
    description = DetonateDetachedLimbsServerAction.description;
    breakdown = breakdown;
    activate = activate;
  });

  if contestant.player then
    
    local actionRemoteFunction = Instance.new("RemoteFunction");
    actionRemoteFunction.Name = `{contestant.player.UserId}_{action.ID}`;
    actionRemoteFunction.OnServerInvoke = function(player)

      if player == contestant.player then

        action:activate();

      else

        -- That's weird.
        error("Unauthorized.");

      end

    end;
    actionRemoteFunction.Parent = ReplicatedStorage.Shared.Functions.ActionFunctions;
    remoteFunction = actionRemoteFunction;

  end;

  return action;

end;

return DetonateDetachedLimbsServerAction;