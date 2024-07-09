export type ClientContestantProperties = {
  
  ID: number;

  archetypeID: number;
  
  isDisqualified: boolean;

  player: Player?;

  character: Model?;

  teamID: number?;
  
}

export type ClientContestantMethods = {
}

export type ClientContestantEvents = {
  onDisqualified: RBXScriptSignal;
}

local ClientContestant = {
  __index = {};
};

export type ClientContestant = typeof(setmetatable({}, ClientContestant)) & ClientContestantProperties & ClientContestantEvents & ClientContestantMethods;

local events: {[any]: {[string]: BindableEvent}} = {};
function ClientContestant.new(properties: ClientContestantProperties): ClientContestant

  local contestant = setmetatable(properties, ClientContestant) :: ClientContestant;

  -- Set up events.
  local eventNames = {"onDisqualified", "onHealthUpdated"};
  events[contestant] = {};
  for _, eventName in ipairs(eventNames) do

    events[contestant][eventName] = Instance.new("BindableEvent");
    (contestant :: {})[eventName] = events[contestant][eventName].Event;

  end

  return contestant;
  
end

return ClientContestant;