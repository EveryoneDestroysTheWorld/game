--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local DetonateDetachedLimbsClientAction = require(ReplicatedStorage.Client.Classes.Actions.DetonateDetachedLimbsClientAction);
local IDetonateDetachedLimbsServerAction = require(ServerStorage.Interfaces.IDetonateDetachedLimbsServerAction);
local IServerRound = require(ServerStorage.Interfaces.IServerRound);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);

local assertContestantIsNotActionLocked = require(ServerStorage.Modules.assertContestantIsNotActionLocked);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local removeDetachLimbBaseModifiers = require(ServerStorage.Modules.removeDetachLimbBaseModifiers);

type IServerContestant = IServerContestant.IServerContestant;
type IServerRound = IServerRound.IServerRound;
type IDetonateDetachedLimbsServerAction = IDetonateDetachedLimbsServerAction.IDetonateDetachedLimbsServerAction;

local DetonateDetachedLimbsServerAction = {
  id = DetonateDetachedLimbsClientAction.id;
  name = DetonateDetachedLimbsClientAction.name;
  description = DetonateDetachedLimbsClientAction.description;
};

function DetonateDetachedLimbsServerAction.new(contestant: IServerContestant, round: IServerRound): IDetonateDetachedLimbsServerAction

  local function activate(self: IDetonateDetachedLimbsServerAction)

    -- Verify that actions aren't locked.
    assertContestantIsNotActionLocked(contestant);
  
    -- Make sure the player has enough stamina.
    assert(contestant.currentStamina >= 20, "Contestant doesn't have enough stamina.");
    local detachedLimbs = ServerStorage.Functions.ActionFunctions:FindFirstChild(`{contestant.id}_GetDetachedLimbs`):Invoke();
    local didReduceStamina = false;
  
    for limbName, instance in detachedLimbs do
  
      -- Reduce stamina once.
      if not didReduceStamina then
  
        didReduceStamina = true;
        
        contestant:setCurrentStamina(math.max(contestant.currentStamina - 20, 0), {
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
          for _, possibleEnemyContestant in round:getContestants() do
  
            task.spawn(function()
  
              local possibleEnemyCharacter = possibleEnemyContestant:getCharacter();
              if possibleEnemyContestant ~= contestant and not table.find(hitContestants, possibleEnemyContestant) and possibleEnemyCharacter and basePart:IsDescendantOf(possibleEnemyCharacter) then
  
                table.insert(hitContestants, possibleEnemyContestant);
                possibleEnemyContestant:setCurrentHealth(possibleEnemyContestant.currentHealth - 15, {
                  contestantID = contestant.id;
                  actionID = DetonateDetachedLimbsServerAction.id;
                });
  
              end;
  
            end);
  
          end;
  
          local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability");
          if basePartCurrentDurability and typeof(basePartCurrentDurability) == "number" and basePartCurrentDurability > 0 then
  
            ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - 25, {
              contestantID = contestant.id;
              actionID = self.id;
            });
  
          end;
  
        end);
        explosion.Parent = workspace;
        instance:Destroy();
  
        local character = contestant:getCharacter();
        if character then
  
          -- Add the limb and HP back to the player.
          local humanoid = character:FindFirstChild("Humanoid");
          assert(humanoid and humanoid:IsA("Humanoid"), `Couldn't find {contestant.name}'s humanoid`);
          
          removeDetachLimbBaseModifiers(contestant);
  
        end;
  
      end);
  
    end;
  
  end;

  local function breakdown(self: IDetonateDetachedLimbsServerAction)

    if self.remoteFunction then
  
      self.remoteFunction:Destroy();
  
    end;
  
    if contestant.player then
  
      ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(contestant.player, self.id);
  
    end;
  
  end;

  local action: IDetonateDetachedLimbsServerAction = {
    attributes = {};
    contestantID = contestant.id;
    description = DetonateDetachedLimbsServerAction.description;
    id = DetonateDetachedLimbsServerAction.id;
    name = DetonateDetachedLimbsServerAction.name;
    activate = activate;
    breakdown = breakdown;
  };

  local player = contestant.player;
  if player then

    action.remoteFunction = createInventoryRemoteFunction(player, "Action", `{player.UserId}_{action.id}`, function()
    
      action:activate();

    end);

    ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

  end;
  
  return action;

end;

return DetonateDetachedLimbsServerAction;