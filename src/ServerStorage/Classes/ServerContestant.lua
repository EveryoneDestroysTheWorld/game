--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents an Archetype, which contains a list of powers.

local HttpService = game:GetService("HttpService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
local Profile = require(ServerStorage.Classes.Profile);
type Profile = Profile.Profile;

export type ContestantProperties = {
  
  -- The ID of the contestant. 
  -- If the contestant is a bot, this is a unique temporary ID assigned by the server. It will be an irrational number.
  -- If the contestant is a player, this is the same value as player.UserId. It will be an integer.
  ID: number;

  -- This could be nil if the server hasn't assigned an archetype to the contestant yet.
  archetypeID: number?;

  -- The name of the contestant. This is here to easily reference bot names. 
  -- If the contestant is a player, this is the same value as player.DisplayName. To get the username, use player.Name.
  name: string;

  -- Is this contestant created by the server?
  isBot: boolean;

  -- Is this contestant still a part of the game?
  isDisqualified: boolean;

  -- The profile of the contestant. This should be nil if the contestant isn't a player.
  profile: Profile?;

  -- The player reference of the contestant. This should be nil if the contestant isn't a player.
  player: Player?;

  -- The character reference of the contestant. This is here to easily reference characters of bot contestants.
  -- If the contestant is a player, this is the same value as player.Character.
  character: Model?;

  -- The team ID of the contestant. This will be nil if the game rules call for a free-for-all.
  teamID: number?;
  
}

export type Cause = {
  contestant: ServerContestant; 
  actionID: number?; 
  archetypeID: number?;
};

export type ContestantMethods = {
  convertToClient: (self: ServerContestant) -> {any};
  disqualify: (self: ServerContestant) -> ();
  updateArchetypeID: (self: ServerContestant, newArchetypeID: number) -> ();
  updateHealth: (self: ServerContestant, newHealth: number, cause: Cause?) -> ();
  toString: (self: ServerContestant) -> string;
}

export type ContestantEvents = {
  onDisqualified: RBXScriptSignal;
  onArchetypeUpdated: RBXScriptSignal;
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
  local eventNames = {"onDisqualified", "onHealthUpdated", "onArchetypeUpdated"};
  events[contestant] = {};
  for _, eventName in ipairs(eventNames) do

    events[contestant][eventName] = Instance.new("BindableEvent");
    (contestant :: {})[eventName] = events[contestant][eventName].Event;

  end

  return contestant;
  
end

function ServerContestant.__index:convertToClient(): {any}

  return {
    ID = self.ID;
    archetypeID = self.archetypeID;
    isDisqualified = self.isDisqualified;
    player = self.player;
    name = self.name;
    isBot = self.isBot;
    character = self.character;
    teamID = self.teamID;
  };

end;

function ServerContestant.__index:updateArchetypeID(newArchetypeID: number): ()

  self.archetypeID = newArchetypeID;
  events[self].onArchetypeUpdated:Fire(newArchetypeID);
  ReplicatedStorage.Shared.Events.ContestantArchetypeUpdated:FireAllClients(self.ID, newArchetypeID);

end;

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