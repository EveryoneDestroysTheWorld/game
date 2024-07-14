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
  
}

export type ClientContestantMethods = {
}

export type ClientContestantEvents = {
  onDisqualified: RBXScriptSignal;
  onHealthUpdated: RBXScriptSignal;
  onArchetypePrivatelyChosen: RBXScriptSignal;
  onArchetypeUpdated: RBXScriptSignal;
}

local ClientContestant = {
  __index = {};
};

export type ClientContestant = typeof(setmetatable({}, ClientContestant)) & ClientContestantProperties & ClientContestantEvents & ClientContestantMethods;

local events: {[any]: {[string]: BindableEvent}} = {};
function ClientContestant.new(properties: ClientContestantProperties): ClientContestant

  local contestant = setmetatable(properties, ClientContestant) :: ClientContestant;

  -- Set up events.
  local eventNames = {"onDisqualified", "onHealthUpdated", "onArchetypePrivatelyChosen", "onArchetypeUpdated"};
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

  ReplicatedStorage.Shared.Events.ContestantArchetypeUpdated.OnClientEvent:Connect(function(contestantID: number, archetypeID: number)
  
    if contestantID == contestant.ID then

      contestant.archetypeID = archetypeID;
      events[contestant].onArchetypeUpdated:Fire(archetypeID);

    end;
    
  end);

  return contestant;
  
end

return ClientContestant;