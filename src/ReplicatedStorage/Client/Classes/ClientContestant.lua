local ReplicatedStorage = game:GetService("ReplicatedStorage");

export type ClientContestantProperties = {
  
  ID: number;

  archetypeID: number?;
  
  isDisqualified: boolean;

  player: Player?;

  character: Model?;

  name: string;

  isBot: boolean;

  teamID: number?;

  currentHealth: number?;

  baseHealth: number?;

  currentStamina: number?;

  baseStamina: number?
  
}

export type Cause = {
  archetypeID: number;
  contestantID: number;
  actionID: number?;
}

export type ClientContestantMethods = {
}

export type ClientContestantEvents = {
  onDisqualified: RBXScriptSignal;
  onHealthUpdated: RBXScriptSignal;
  onStaminaUpdated: RBXScriptSignal;
  onArchetypePrivatelyChosen: RBXScriptSignal;
  onArchetypeUpdated: RBXScriptSignal;
  onCharacterUpdated: RBXScriptSignal;
}

local ClientContestant = {
  __index = {};
};

export type ClientContestant = typeof(setmetatable({}, ClientContestant)) & ClientContestantProperties & ClientContestantEvents & ClientContestantMethods;

local events: {[any]: {[string]: BindableEvent}} = {};
function ClientContestant.new(properties: ClientContestantProperties): ClientContestant

  local contestant = setmetatable(properties, ClientContestant) :: ClientContestant;

  -- Set up events.
  local eventNames = {"onDisqualified", "onHealthUpdated", "onStaminaUpdated", "onArchetypePrivatelyChosen", "onArchetypeUpdated", "onCharacterUpdated"};
  events[contestant] = {};
  for _, eventName in ipairs(eventNames) do

    events[contestant][eventName] = Instance.new("BindableEvent");
    (contestant :: {})[eventName] = events[contestant][eventName].Event;

  end

  ReplicatedStorage.Shared.Events.ArchetypePrivatelyChosen.OnClientEvent:Connect(function(contestantID: number, archetypeID: number)
  
    if contestantID == contestant.ID then

      contestant.archetypeID = archetypeID;
      events[contestant].onArchetypePrivatelyChosen:Fire(archetypeID);

    end;
    
  end);

  ReplicatedStorage.Shared.Events.CharacterUpdated.OnClientEvent:Connect(function(contestantID: number, characterName: string?)

    if contestantID == contestant.ID then

      local character = workspace:FindFirstChild(characterName);
      contestant.character = character;
      events[contestant].onCharacterUpdated:Fire(character);

    end;

  end);

  ReplicatedStorage.Shared.Events.ContestantArchetypeUpdated.OnClientEvent:Connect(function(contestantID: number, archetypeID: number)
  
    if contestantID == contestant.ID then

      contestant.archetypeID = archetypeID;
      events[contestant].onArchetypeUpdated:Fire(archetypeID);

    end;
    
  end);

  ReplicatedStorage.Shared.Events.HealthUpdated.OnClientEvent:Connect(function(contestantID: number, newHealth: number, cause: Cause?)
  
    if contestantID == contestant.ID then

      contestant.currentHealth = newHealth;
      events[contestant].onHealthUpdated:Fire(newHealth, cause);

    end;

  end);

  ReplicatedStorage.Shared.Events.StaminaUpdated.OnClientEvent:Connect(function(contestantID: number, newStamina: number, cause: Cause?)
  
    if contestantID == contestant.ID then

      contestant.currentStamina = newStamina;
      events[contestant].onStaminaUpdated:Fire(newStamina, cause);

    end;

  end);

  return contestant;
  
end

return ClientContestant;