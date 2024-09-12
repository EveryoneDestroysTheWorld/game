--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerArchetype = require(script.Parent.Parent.ServerArchetype);
local ServerContestant = require(script.Parent.Parent.ServerContestant);
local UndeadConciousnessClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.UndeadConciousnessClientArchetype);
local ServerRound = require(script.Parent.Parent.ServerRound);
local ServerAction = require(script.Parent.Parent.ServerAction);
local ServerItem = require(script.Parent.Parent.ServerItem);
type ServerRound = ServerRound.ServerRound;
type ServerContestant = ServerContestant.ServerContestant;
type ServerArchetype = ServerArchetype.ServerArchetype;
type ServerAction = ServerAction.ServerAction;

local UndeadConciousnessServerArchetype = {
  ID = UndeadConciousnessClientArchetype.ID;
  name = UndeadConciousnessClientArchetype.name;
  description = UndeadConciousnessClientArchetype.description;
  actionIDs = UndeadConciousnessClientArchetype.actionIDs;
  type = UndeadConciousnessClientArchetype.type;
};

function UndeadConciousnessServerArchetype.new(): ServerArchetype

  local contestant: ServerContestant;
  local round: ServerRound;
  local isContestantStunned = false;
  local breakdownEventList: {
    [BasePart]: RBXScriptConnection;
    healthUpdateEvent: RBXScriptConnection?;
    contestantTouchEvent: RBXScriptConnection?;
  } = {};

  local function breakdown(self: ServerArchetype)

    for _, event in pairs(breakdownEventList) do

      event:Disconnect();

    end;

  end;

  local function runAutoPilot(self: ServerArchetype, actions: {ServerAction})

    -- Make sure the contestant has a character.
    local character = contestant.character
    assert(character, "Character not found");

    repeat

      

    until task.wait() and round.timeEnded;

  end;

  local function initialize(self: ServerArchetype, newContestant: ServerContestant, newRound: ServerRound)

    contestant = newContestant;
    round = newRound;

    local isOffenseActivated = false;

    local function activateOffense()

      if isOffenseActivated then

        return;

      end;

      isOffenseActivated = true;

      -- Verify that we have the required instances.
      local character = contestant.character;
      assert(character, `Couldn't find {contestant.ID}'s character.`);
      
      local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?;
      assert(humanoid and humanoid:IsA("Humanoid"), `Couldn't find {contestant.ID}'s humanoid.`);
  
      -- Slow down the player.
      humanoid.WalkSpeed = 12;
  
      -- Allow the player to revive disqualified allies and give them this archetype.
      for _, possibleAllyContestant in ipairs(round.contestants) do
  
        -- To be implemented when teams are implemented.
        possibleAllyContestant.onDisqualified:Connect(function()
        
          
  
        end);
  
      end;
  
      -- If the player gets dealt 30 damage, stun them for 3 seconds.
      if breakdownEventList.healthUpdateEvent then
  
        breakdownEventList.healthUpdateEvent:Disconnect();
  
      end;
  
      local damageCounter = 0;
      breakdownEventList.healthUpdateEvent = contestant.onHealthUpdated:Connect(function(newHealth, oldHealth)
      
        -- Stun the contestant if the total damage taken is at least 30.
        local delta = newHealth - oldHealth;
        if not isContestantStunned and delta < 0 then
  
          damageCounter += delta;
          if damageCounter >= 30 then
  
            isContestantStunned = true;
            damageCounter = 0;
            humanoid.WalkSpeed = 0;
  
            -- Restore the contestant after 3 seconds.
            task.delay(3, function()
            
              humanoid.WalkSpeed = 12;
              isContestantStunned = false;
  
            end);
  
          end;
  
        end;
  
      end);
  
      -- Make touching enemy contestants take 20 damage with 1 second of immunity.
      if breakdownEventList.contestantTouchEvent then
  
        breakdownEventList.contestantTouchEvent:Disconnect();
  
      end;
  
      local immuneContestants = {};
      for _, instance in ipairs(character:GetChildren()) do
  
        if instance:IsA("BasePart") then
  
          breakdownEventList[instance] = instance.Touched:Connect(function(basePart)
            
            for _, possibleEnemyContestant in ipairs(round.contestants) do
  
              task.spawn(function()
              
                local possibleEnemyCharacter = possibleEnemyContestant.character;
                if possibleEnemyContestant ~= contestant and not table.find(immuneContestants, possibleEnemyContestant) and possibleEnemyCharacter and basePart:IsDescendantOf(possibleEnemyCharacter) then
  
                  local enemyHumanoid = possibleEnemyCharacter:FindFirstChild("Humanoid");
                  if enemyHumanoid then
  
                    -- Add immunity, then remove it after a second.
                    table.insert(immuneContestants, possibleEnemyContestant);
                    task.delay(1, function()
                    
                      table.remove(immuneContestants, table.find(immuneContestants, possibleEnemyContestant));
  
                    end);
  
                    possibleEnemyContestant:updateHealth(possibleEnemyContestant.currentHealth - 20, {
                      contestant = contestant;
                      archetypeID = UndeadConciousnessServerArchetype.ID;
                    });
  
                  end;
  
                end;
  
              end);
  
            end;
  
          end);
  
        end;
  
      end;

    end;

    contestant.onHealthUpdated:Connect(function()
    
      if contestant.currentHealth <= 0 then

        if contestant.character then

          local ragdollModel = contestant.character:Clone();
          ragdollModel.Parent = workspace;

        end;

        activateOffense();

      end;

    end);

    -- Give the player a random item. 
    local randomItem = ServerItem.random();
    contestant:addItemToInventory(randomItem);

    if contestant.player then

      ReplicatedStorage.Shared.Functions.InitializeArchetype:InvokeClient(contestant.player, self.ID);

    end;

  end;

  return ServerArchetype.new({
    ID = UndeadConciousnessServerArchetype.ID;
    name = UndeadConciousnessServerArchetype.name;
    description = UndeadConciousnessServerArchetype.description;
    actionIDs = UndeadConciousnessServerArchetype.actionIDs;
    type = UndeadConciousnessServerArchetype.type;
    breakdown = breakdown;
    runAutoPilot = runAutoPilot;
    initialize = initialize;
  });

end;

return UndeadConciousnessServerArchetype;