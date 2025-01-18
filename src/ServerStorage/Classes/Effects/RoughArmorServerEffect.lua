--!strict

local ServerStorage = game:GetService("ServerStorage");
local HttpService = game:GetService("HttpService");

local types = require(ServerStorage.Classes.types);

local RoughArmorServerEffect = {
  name = "Rough Armor";
  id = script.Name:sub(1, script.Name:gsub("ServerEffect", ""):len());
  __index = {} :: types.RoughArmorServerEffect;
}

function RoughArmorServerEffect.new(properties: types.RoughArmorServerEffectConstructorProperties): types.RoughArmorServerEffect

  local effect: types.RoughArmorServerEffectProperties = {
    name = RoughArmorServerEffect.name;
    id = RoughArmorServerEffect.id;
    uniqueID = HttpService:GenerateGUID(false);
    contestant = properties.contestant;
    events = {};
  };

  return (setmetatable(effect, RoughArmorServerEffect) :: unknown) :: types.RoughArmorServerEffect

end;

function RoughArmorServerEffect.__index:activate()
  
  if self.contestant.character then

    local immuneContestants = {};
    for _, instance in ipairs(self.contestant.character:GetChildren()) do

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
                  task.delay(0.5, function()
                  
                    table.remove(immuneContestants, table.find(immuneContestants, possibleEnemyContestant));

                  end);

                  possibleEnemyContestant:updateHealth(possibleEnemyContestant.currentHealth - 2, {
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

end;

function RoughArmorServerEffect.__index:deactivate()

  for _, event in self.events do

    event:Disconnect();

  end;

end;

return RoughArmorServerEffect;