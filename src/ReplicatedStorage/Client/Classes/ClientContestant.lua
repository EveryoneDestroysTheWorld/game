local ReplicatedStorage = game:GetService("ReplicatedStorage");

local TurfWarContestantStatistics = require(ReplicatedStorage.Shared.TurfWarContestantStatistics);
type TurfWarContestantStatistics = TurfWarContestantStatistics.TurfWarContestantStatistics;

export type ClientContestantProperties = {
  
  id: number;

  archetypeID: string?;
  
  isDisqualified: boolean;

  player: Player?;

  character: Model?;

  name: string;

  isBot: boolean;

  teamID: number?;

  currentHealth: number?;

  baseHealth: number?;

  currentStamina: number?;

  baseStamina: number?;

  statistics: TurfWarContestantStatistics?;
  
}

export type Cause = {
  archetypeID: string;
  contestantID: number;
  actionID: string?;
}

export type ClientContestantMethods = {
}

export type ClientContestantEvents = {
  onDisqualified: RBXScriptSignal;
  onHealthUpdated: RBXScriptSignal;
  onStaminaUpdated: RBXScriptSignal;
  onArchetypeUpdated: RBXScriptSignal;
  onCharacterUpdated: RBXScriptSignal;
  onStatisticsUpdated: RBXScriptSignal;
}

local ClientContestant = {
  __index = {};
};

export type ClientContestant = typeof(setmetatable({}, ClientContestant)) & ClientContestantProperties & ClientContestantEvents & ClientContestantMethods;

local events: {[any]: {[string]: BindableEvent}} = {};
function ClientContestant.new(properties: ClientContestantProperties): ClientContestant

  local contestant = setmetatable(properties, ClientContestant) :: ClientContestant;

  -- Set up events.
  local eventNames = {"onDisqualified", "onHealthUpdated", "onStaminaUpdated", "onArchetypeUpdated", "onCharacterUpdated", "onStatisticsUpdated"};
  events[contestant] = {};
  for _, eventName in ipairs(eventNames) do

    events[contestant][eventName] = Instance.new("BindableEvent");
    (contestant :: {})[eventName] = events[contestant][eventName].Event;

  end

  ReplicatedStorage.Shared.Events.CharacterUpdated.OnClientEvent:Connect(function(contestantID: number, characterName: string?)

    if contestantID == contestant.id then

      local character = workspace:FindFirstChild(characterName);
      contestant.character = character;
      events[contestant].onCharacterUpdated:Fire(character);

    end;

  end);

  ReplicatedStorage.Shared.Events.ContestantArchetypeUpdated.OnClientEvent:Connect(function(contestantID: number, archetypeID: number)
  
    if contestantID == contestant.id then

      contestant.archetypeID = archetypeID;
      events[contestant].onArchetypeUpdated:Fire(archetypeID);

    end;
    
  end);

  ReplicatedStorage.Shared.Events.HealthUpdated.OnClientEvent:Connect(function(contestantID: number, newHealth: number, cause: Cause?)
  
    if contestantID == contestant.id then

      contestant.currentHealth = newHealth;
      events[contestant].onHealthUpdated:Fire(newHealth, cause);

    end;

  end);

  ReplicatedStorage.Shared.Events.StaminaUpdated.OnClientEvent:Connect(function(contestantID: number, newStamina: number, cause: Cause?)
  
    if contestantID == contestant.id then

      contestant.currentStamina = newStamina;
      events[contestant].onStaminaUpdated:Fire(newStamina, cause);

    end;

  end);

  ReplicatedStorage.Shared.Events.ContestantStatisticsUpdated.OnClientEvent:Connect(function(contestantID: number, newStats: TurfWarContestantStatistics, oldStats: TurfWarContestantStatistics?, cause: Cause?)
  
    if contestantID == contestant.id then

      contestant.statistics = newStats;
      events[contestant].onStatisticsUpdated:Fire(newStats, oldStats, cause);

    end;

  end);

  return contestant;
  
end

return ClientContestant;