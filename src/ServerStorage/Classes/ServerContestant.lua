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

export type Cause = {
  contestant: ServerContestant; 
  actionID: number?; 
  archetypeID: number?;
};

export type ContestantMethods = {
  disqualify: (self: ServerContestant) -> ();
  updateHealth: (self: ServerContestant, newHealth: number, cause: Cause?) -> ();
  toString: (self: ServerContestant) -> string;
}

export type ContestantEvents = {
  onDisqualified: RBXScriptSignal;
  onHealthUpdated: RBXScriptSignal<number, number, Cause?>;
}

local ServerContestant = {
  __index = {} :: ContestantMethods;
};

export type ServerContestant = typeof(setmetatable({}, ServerContestant)) & ContestantProperties & ContestantEvents & ContestantMethods;

local events: {[any]: {[string]: BindableEvent}} = {};
function ServerContestant.new(properties: ContestantProperties): ServerContestant

  local contestant = setmetatable(properties, ServerContestant) :: ServerContestant;

  -- Set up events.
  local eventNames = {"onDisqualified", "onHealthUpdated"};
  events[contestant] = {};
  for _, eventName in ipairs(eventNames) do

    events[contestant][eventName] = Instance.new("BindableEvent");
    (contestant :: {})[eventName] = events[contestant][eventName].Event;

  end

  return contestant;
  
end

function ServerContestant.__index:updateHealth(newHealth: number, cause: Cause?)

  local character = self.character;
  local humanoid = character and character:FindFirstChild("Humanoid") :: Humanoid;
  assert(humanoid, "No humanoid found.");

  local oldHealth = humanoid:GetAttribute("CurrentHealth");
  humanoid:SetAttribute("CurrentHealth", newHealth);

  events[self].onHealthUpdated:Fire(newHealth, oldHealth, cause);

end;

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