--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local types = require(ReplicatedStorage.Client.Modules.types);

local ClientContestant = {
  __index = {};
};

local events: {[any]: {[string]: BindableEvent}} = {};
function ClientContestant.new(properties: types.ClientContestantConstructorProperties): types.ClientContestant

  if properties.characterName then

    properties.character = workspace:FindFirstChild(properties.characterName);
    properties.characterName = nil;

  end;


  local contestant = (setmetatable(properties, ClientContestant) :: unknown) :: types.ClientContestant;

  -- Set up events.
  local eventNames = {"onDisqualified", "onHealthUpdated", "onStaminaUpdated", "onArchetypeUpdated", "onCharacterUpdated", "onStatisticsUpdated"};
  events[contestant] = {};
  for _, eventName in ipairs(eventNames) do

    events[contestant][eventName] = Instance.new("BindableEvent");
    (contestant :: {})[eventName] = events[contestant][eventName].Event;

  end

  ReplicatedStorage.Shared.Events.CharacterUpdated.OnClientEvent:Connect(function(contestantID: number, characterName: string?)

    if contestantID == contestant.id and characterName then

      local character = workspace:FindFirstChild(characterName);
      contestant.character = character;
      events[contestant].onCharacterUpdated:Fire(character);

    end;

  end);

  ReplicatedStorage.Shared.Events.ContestantArchetypeUpdated.OnClientEvent:Connect(function(contestantID: number, archetypeID: string)
  
    if contestantID == contestant.id then

      contestant.archetypeID = archetypeID;
      events[contestant].onArchetypeUpdated:Fire(archetypeID);

    end;
    
  end);

  ReplicatedStorage.Shared.Events.HealthUpdated.OnClientEvent:Connect(function(contestantID: number, newHealth: number, cause: types.Cause?)
  
    if contestantID == contestant.id then

      contestant.currentHealth = newHealth;
      events[contestant].onHealthUpdated:Fire(newHealth, cause);

    end;

  end);

  ReplicatedStorage.Shared.Events.StaminaUpdated.OnClientEvent:Connect(function(contestantID: number, newStamina: number, cause: types.Cause?)
  
    if contestantID == contestant.id then

      contestant.currentStamina = newStamina;
      events[contestant].onStaminaUpdated:Fire(newStamina, cause);

    end;

  end);

  ReplicatedStorage.Shared.Events.ContestantStatisticsUpdated.OnClientEvent:Connect(function(contestantID: number, newStats: types.TurfWarContestantStatistics, oldStats: types.TurfWarContestantStatistics?, cause: types.Cause?)
  
    if contestantID == contestant.id then

      contestant.statistics = newStats;
      events[contestant].onStatisticsUpdated:Fire(newStats, oldStats, cause);

    end;

  end);

  return contestant;
  
end

return ClientContestant;