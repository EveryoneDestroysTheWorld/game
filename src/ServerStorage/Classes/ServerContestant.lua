--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents an Archetype, which contains a list of powers.

local HttpService = game:GetService("HttpService");

export type ContestantProperties = {
  
  ID: number;

  archetypeID: number;
  
  isDisqualified: boolean;

  player: Player?;

  character: Model?;
  
}

export type ContestantMethods = {
  disqualify: (self: ServerContestant) -> ();
  toString: (self: ServerContestant) -> string;
}

export type ContestantEvents = {
  onDisqualified: RBXScriptSignal;
}

local ServerContestant = {
  __index = {} :: ContestantMethods;
};

export type ServerContestant = typeof(setmetatable({}, ServerContestant)) & ContestantProperties & ContestantEvents & ContestantMethods;

local events: {[any]: {[string]: BindableEvent}} = {};
function ServerContestant.new(properties: ContestantProperties): ServerContestant

  local contestant = setmetatable(properties, ServerContestant) :: ServerContestant;

  -- Set up events.
  local eventNames = {"onDisqualified"};
  events[contestant] = {};
  for _, eventName in ipairs(eventNames) do

    events[contestant][eventName] = Instance.new("BindableEvent");
    (contestant :: {})[eventName] = events[contestant][eventName].Event;

  end

  return contestant;
  
end

function ServerContestant.__index:disqualify()

  assert(not self.isDisqualified, "Contestant has already been disqualified.");

  self.isDisqualified = true;
  events[self].onDisqualified:Fire();

end;

function ServerContestant.__index:toString()

  return HttpService:JSONEncode({
    ID = self.ID;
    archetypeID = self.archetypeID;
  });

end;

return ServerContestant;