--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents an Archetype, which contains a list of powers.

local HttpService = game:GetService("HttpService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
local ServerItem = require(script.Parent.ServerItem);
type ServerItem = ServerItem.ServerItem;
local Profile = require(ServerStorage.Packages.Profile);
type Profile = Profile.Profile;
local Cause = require(ServerStorage.Types["Cause.types"]);
type Cause = Cause.Cause;
local ServerEffect = require(script.Parent.ServerEffect);
type ServerEffect = ServerEffect.ServerEffect;
local TurfWarContestantStatistics = require(ReplicatedStorage.Shared.TurfWarContestantStatistics);
type TurfWarContestantStatistics = TurfWarContestantStatistics.TurfWarContestantStatistics;
type PatchableTurfWarContestantStatistics = TurfWarContestantStatistics.PatchableContestantTurfWarStatistics;

export type ContestantProperties = {
  
  -- This could be nil if the server hasn't assigned an archetype to the contestant yet.
  archetypeID: string?;

  -- The character reference of the contestant. This is here to easily reference characters of bot contestants.
  -- If the contestant is a player, this is the same value as player.Character.
  character: Model?;

  currentStamina: number;

  effects: {ServerEffect};

  -- The ID of the contestant. 
  -- If the contestant is a bot, this is a unique temporary ID assigned by the server. It will be an irrational number.
  -- If the contestant is a player, this is the same value as player.UserId. It will be an integer.
  id: number;

  -- The name of the contestant. This is here to easily reference bot names. 
  -- If the contestant is a player, this is the same value as player.DisplayName. To get the username, use player.Name.
  name: string;

  -- Is this contestant created by the server?
  isBot: boolean;

  -- Is this contestant still a part of the game?
  isDisqualified: boolean;

  -- The player reference of the contestant. This should be nil if the contestant isn't a player.
  player: Player?;

  -- The profile of the contestant. This should be nil if the contestant isn't a player.
  profile: Profile?;

  -- The team ID of the contestant. This will be nil if the game rules call for a free-for-all.
  teamID: number?;

  inventory: {ServerItem};

  currentHealth: number;

  baseHealth: number;

  baseStamina: number;

  statistics: TurfWarContestantStatistics?;
  
}

export type ContestantMethods = {
  addItemToInventory: (self: ServerContestant, item: ServerItem) -> ();
  removeItemFromInventory: (self: ServerContestant, item: ServerItem) -> ();
  addEffect: (self: ServerContestant, effect: ServerEffect) -> ();
  removeEffect: (self: ServerContestant, effect: ServerEffect) -> ();
  convertToClient: (self: ServerContestant) -> {any};
  disqualify: (self: ServerContestant) -> ();
  getInventoryItemIDs: (self: ServerContestant) -> {string};
  updateArchetypeID: (self: ServerContestant, newArchetypeID: string) -> ();
  updateCharacter: (self: ServerContestant, newCharacter: Model?) -> ();
  updateInventory: (self: ServerContestant, newInventory: {ServerItem}) -> ();
  updateHealth: (self: ServerContestant, newHealth: number, cause: Cause?) -> ();
  updateStamina: (self: ServerContestant, newStamina: number, cause: Cause?) -> ();
  mergeStatistics: (self: ServerContestant, newStatistics: PatchableTurfWarContestantStatistics, cause: Cause?) -> ();
  toString: (self: ServerContestant) -> string;
}

export type ContestantEvents = {
  onDisqualified: RBXScriptSignal;
  onArchetypeUpdated: RBXScriptSignal;
  onHealthUpdated: RBXScriptSignal<number, number, Cause?>;
  onStaminaUpdated: RBXScriptSignal<number, number, Cause?>;
  onInventoryUpdated: RBXScriptSignal<{number}>;
  onEffectsUpdated: RBXScriptSignal<{ServerEffect}>;
}

local ServerContestant = {
  __index = {} :: ContestantMethods;
};

export type ServerContestant = ContestantProperties & ContestantEvents & ContestantMethods;

local events: {[any]: {[string]: BindableEvent}} = {};
function ServerContestant.new(properties: ContestantProperties): ServerContestant

  local contestant = setmetatable(properties, ServerContestant);

  -- Set up events.
  local eventNames = {"onDisqualified", "onHealthUpdated", "onStaminaUpdated", "onArchetypeUpdated", "onCharacterUpdated", "onInventoryUpdated", "onEffectsUpdated"};
  events[contestant] = {};
  for _, eventName in ipairs(eventNames) do

    events[contestant][eventName] = Instance.new("BindableEvent");
    contestant[eventName] = events[contestant][eventName].Event;

  end

  return contestant :: any;
  
end

function ServerContestant.__index:getInventoryItemIDs(): {string}

  local itemIDs = {};

  for _, item in self.inventory do

    table.insert(itemIDs, item.id);

  end;

  return itemIDs;

end;

function ServerContestant.__index:addEffect(effect: ServerEffect): ()

  table.insert(self.effects, effect);
  events[self].onEffectsUpdated:Fire(self.effects);

end;

function ServerContestant.__index:addItemToInventory(item: ServerItem): ()

  table.insert(self.inventory, item);
  events[self].onInventoryUpdated:Fire(self:getInventoryItemIDs());

end;

function ServerContestant.__index:removeItemFromInventory(item: ServerItem): ()

  -- Iterating backwards because the indexes can change after running table.remove().
  for index = #self.inventory, 1, -1 do

    local possibleItem = self.inventory[index]
    if possibleItem == item then

      table.remove(self.inventory, index);
      task.spawn(function()

        possibleItem:breakdown();
      
      end);

    end;

  end;

  events[self].onInventoryUpdated:Fire(self:getInventoryItemIDs());

end;

function ServerContestant.__index:removeEffect(effect: ServerEffect): ()

  -- Iterating backwards because the indexes can change after running table.remove().
  for index = #self.effects, 1, -1 do

    local possibleEffect = self.effects[index]
    if possibleEffect == effect then

      table.remove(self.effects, index);

    end;

  end;

  events[self].onEffectsUpdated:Fire(self.effects);

end;

function ServerContestant.__index:updateInventory(newInventory: {ServerItem}): ()

  self.inventory = newInventory;

  -- Only share the IDs to the client. Sharing a server class is unnecessary.
  events[self].onInventoryUpdated:Fire(self:getInventoryItemIDs());

end;

function ServerContestant.__index:convertToClient(): {any}

  return {
    id = self.id;
    archetypeID = self.archetypeID;
    isDisqualified = self.isDisqualified;
    player = self.player;
    name = self.name;
    isBot = self.isBot;
    character = self.character;
    teamID = self.teamID;
    currentHealth = self.currentHealth;
    baseHealth = self.baseHealth;
    currentStamina = self.currentStamina;
    baseStamina = self.baseStamina;
    statistics = self.statistics;
  };

end;

function ServerContestant.__index:updateArchetypeID(newArchetypeID: string): ()

  self.archetypeID = newArchetypeID;
  events[self].onArchetypeUpdated:Fire(newArchetypeID);
  ReplicatedStorage.Shared.Events.ContestantArchetypeUpdated:FireAllClients(self.id, newArchetypeID);

end;

function ServerContestant.__index:updateHealth(newHealth: number, cause: Cause?): ()

  local oldHealth = self.currentHealth;

  for _, effect in self.effects do

    if effect.updateContestantHealth then

      newHealth = effect.updateContestantHealth(effect, newHealth, oldHealth, cause);

    end;

  end;

  self.currentHealth = newHealth;

  ReplicatedStorage.Shared.Events.HealthUpdated:FireAllClients(self.id, newHealth, cause);

  events[self].onHealthUpdated:Fire(newHealth, oldHealth, cause);

end;

function ServerContestant.__index:updateStamina(newStamina: number, cause: Cause?): ()

  local oldStamina = self.currentStamina;

  for _, effect in self.effects do

    if effect.updateContestantStamina then

      newStamina = effect.updateContestantStamina(effect, newStamina, oldStamina, cause);

    end;

  end;

  self.currentStamina = newStamina;

  ReplicatedStorage.Shared.Events.StaminaUpdated:FireAllClients(self.id, newStamina, cause);
  
  events[self].onStaminaUpdated:Fire(newStamina, oldStamina, cause);

end;

function ServerContestant.__index:mergeStatistics(newStatistics: PatchableTurfWarContestantStatistics, cause: Cause?): ()

  local oldStats = self.statistics;
  if oldStats then

    for key, value in newStatistics do

      oldStats[key] = value;

    end;

    self.statistics = oldStats;

  else

    self.statistics = newStatistics :: TurfWarContestantStatistics;
  
  end;

  ReplicatedStorage.Shared.Events.ContestantStatisticsUpdated:FireAllClients(self.id, self.statistics, oldStats, cause);

end;

function ServerContestant.__index:updateCharacter(newCharacter: Model?): ()

  self.character = newCharacter;
  ReplicatedStorage.Shared.Events.CharacterUpdated:FireAllClients(self.id, if newCharacter then newCharacter.Name else nil);
  events[self].onCharacterUpdated:Fire(newCharacter);

end;

function ServerContestant.__index:disqualify()

  assert(not self.isDisqualified, "Contestant has already been disqualified.");

  self.isDisqualified = true;
  events[self].onDisqualified:Fire();

end;

function ServerContestant.__index:toString()

  return HttpService:JSONEncode({
    id = self.id;
    archetypeID = self.archetypeID;
  });

end;

return ServerContestant;