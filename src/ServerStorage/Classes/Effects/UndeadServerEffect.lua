--!strict
local ServerStorage = game:GetService("ServerStorage");
local ServerEffect = require(ServerStorage.Classes.ServerEffect);

local types = require(ServerStorage.Classes.types);

local UndeadServerEffect = {
  name = "Undead";
  id = script.Name:sub(1, script.Name:gsub("ServerEffect", ""):len());
  __index = {} :: types.UndeadServerEffect;
}

function UndeadServerEffect.new(properties: types.UndeadServerEffectConstructorProperties): types.UndeadServerEffect

  local effect: types.UndeadServerEffectProperties = {
    name = UndeadServerEffect.name;
    id = UndeadServerEffect.id;
    contestant = properties.contestant;
    events = {};
  };

  return (setmetatable(effect, UndeadServerEffect) :: unknown) :: types.UndeadServerEffect

end;

function UndeadServerEffect.__index:activate()

  -- Verify that we have the required instances.
  local character = self.contestant.character;
  assert(character, `Couldn't find {self.contestant.id}'s character.`);
  
  local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?;
  assert(humanoid and humanoid:IsA("Humanoid"), `Couldn't find {self.contestant.id}'s humanoid.`);

  -- Slow down the player.
  local walkSpeedWeight: types.WalkSpeedWeight = {
    walkSpeed = 12;
    weight = 1;
  }
  
  self.contestant:addWalkSpeedWeight(walkSpeedWeight);

  -- Make touching enemy contestants take 20 damage with 1 second of immunity.
  local immuneContestants = {};
  for _, instance in ipairs(character:GetChildren()) do

    if instance:IsA("BasePart") then

      self.events[instance] = instance.Touched:Connect(function(basePart)
        
        for _, possibleEnemyContestant in ipairs(self.contestant.round.contestants) do

          task.spawn(function()
          
            local possibleEnemyCharacter = possibleEnemyContestant.character;
            if possibleEnemyContestant ~= self.contestant and not table.find(immuneContestants, possibleEnemyContestant) and possibleEnemyCharacter and basePart:IsDescendantOf(possibleEnemyCharacter) then

              local enemyHumanoid = possibleEnemyCharacter:FindFirstChild("Humanoid");
              if enemyHumanoid then

                -- Add immunity, then remove it after a second.
                table.insert(immuneContestants, possibleEnemyContestant);
                task.delay(1, function()
                
                  table.remove(immuneContestants, table.find(immuneContestants, possibleEnemyContestant));

                end);

                possibleEnemyContestant:updateHealth(possibleEnemyContestant.currentHealth - 20, {
                  contestantID = self.contestant.id;
                  effectID = self.id
                });

              end;

            end;

          end);

        end;

      end);

    end;

  end;

end;

function UndeadServerEffect.__index:updateContestantStamina(newStamina: number, oldStamina: number): number

  return math.max(oldStamina, newStamina);

end;

function UndeadServerEffect.__index:updateContestantHealth(newHealth: number, oldHealth: number): number

  -- Add paralysis cooldown.
  for _, effect in self.contestant.effects do

    if effect.id == "Paralysis" then

      return oldHealth;

    end;

  end;

  -- If the player gets dealt 30 damage, stun them for 3 seconds.
  if newHealth <= -30 then

    local paralysisEffect = ServerEffect.get("Paralysis").new({
      contestant = self.contestant
    });
    self.contestant:addEffect(paralysisEffect);

    -- Restore the contestant after 3 seconds.
    task.delay(3, function()
    
      self.contestant:removeEffect(paralysisEffect);

    end);

    return 0;

  end;

  return newHealth;

end;

return UndeadServerEffect;