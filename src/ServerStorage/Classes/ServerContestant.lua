--!strict
-- This module represents a contestant.
-- 
-- Programmers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local HttpService = game:GetService("HttpService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local StarterPlayer = game:GetService("StarterPlayer");
local ServerStorage = game:GetService("ServerStorage");
local Profile = require(ServerStorage.Packages.Profile);
type Profile = Profile.Profile;
local TurfWarContestantStatistics = require(ReplicatedStorage.Shared.TurfWarContestantStatistics);
type TurfWarContestantStatistics = TurfWarContestantStatistics.TurfWarContestantStatistics;
type PatchableTurfWarContestantStatistics = TurfWarContestantStatistics.PatchableContestantTurfWarStatistics;
local types = require(ServerStorage.Modules.types);

local ServerContestant = {
  __index = {} :: types.ServerContestant;
};

local events: {[any]: {[string]: BindableEvent}} = {};
function ServerContestant.new(properties: types.ServerContestantConstructorProperties): types.ServerContestant

  local contestant = (setmetatable({}, ServerContestant) :: unknown) :: types.ServerContestant;
  contestant.baseHealth = 1000;
  contestant.currentHealth = contestant.baseHealth;
  contestant.baseStamina = 100;
  contestant.currentStamina = contestant.baseStamina;
  contestant.items = {};
  contestant.isDisqualified = false;
  contestant.attributes = {};
  contestant.tags = {};
  contestant.walkSpeedWeights = {};
  contestant.baseModifiers = {
    health = {};
    stamina = {};
  };
  contestant.effects = {};
  contestant.id = properties.id;
  contestant.name = properties.name;
  contestant.round = properties.round;

  -- Set up events.
  local eventNames = {"onDisqualified", "onHealthUpdated", "onStaminaUpdated", "onArchetypeUpdated", "onCharacterUpdated", "onInventoryUpdated", "onEffectsUpdated"};
  events[contestant] = {};
  for _, eventName in ipairs(eventNames) do

    events[contestant][eventName] = Instance.new("BindableEvent");
    contestant[eventName] = events[contestant][eventName].Event;

  end

  return contestant;
  
end

function ServerContestant.__index:getModifiedBaseValue(modifierType: types.BaseModifierType): number

  local modifiedBaseValue = if modifierType == "Health" then self.baseHealth else self.baseStamina;
  local modifiers: {types.BaseModifier} = if modifierType == "Health" then self.baseModifiers.health else self.baseModifiers.stamina;

  for _, modifier in modifiers do

    modifiedBaseValue += modifier.delta;

  end;

  return modifiedBaseValue;

end;

function ServerContestant.__index:addBaseModifier(modifierType: types.BaseModifierType, modifier: types.BaseModifier): ()

  local modifiers = if modifierType == "Health" then self.baseModifiers.health else self.baseModifiers.stamina;
  table.insert(modifiers, modifier);

end;

function ServerContestant.__index:removeBaseModifier(modifierType: types.BaseModifierType, modifier: types.BaseModifier): ()

  local modifiers = if modifierType == "Health" then self.baseModifiers.health else self.baseModifiers.stamina;
  local index = table.find(modifiers, modifier);
  if index then

    table.remove(modifiers, index);

  end;

end;

function ServerContestant.__index:getInventoryItemIDs(): {string}

  local itemIDs = {};

  for _, item in self.items do

    table.insert(itemIDs, item.id);

  end;

  return itemIDs;

end;

function ServerContestant.__index:refreshWalkSpeed(): ()

  local humanoid = if self.character then self.character:FindFirstChild("Humanoid") else nil;
  if humanoid and humanoid:IsA("Humanoid") then

    local totalWalkSpeed = StarterPlayer.CharacterWalkSpeed;
    local totalWeight = 1;

    if self.walkSpeedWeights[1] then

      totalWalkSpeed = 0;

      for _, properties in self.walkSpeedWeights do

        totalWalkSpeed += properties.walkSpeed * properties.weight;
        totalWeight += properties.weight;

      end;

    end;

    humanoid.WalkSpeed = totalWalkSpeed / totalWeight;

  end;

end;

function ServerContestant.__index:addWalkSpeedWeight(weight: types.WalkSpeedWeight): ()

  table.insert(self.walkSpeedWeights, weight);

  self:refreshWalkSpeed();

end;

function ServerContestant.__index:removeWalkSpeedWeight(weight: types.WalkSpeedWeight): ()

  local index = table.find(self.walkSpeedWeights, weight);
  if index then

    table.remove(self.walkSpeedWeights, index);

    self:refreshWalkSpeed();

  end;

end;

function ServerContestant.__index:addEffect(effect: types.ServerEffect): ()

  table.insert(self.effects, effect);

  if effect.activate then

    task.spawn(function()
    
      effect.activate(effect, self);

    end);

  end;

  events[self].onEffectsUpdated:Fire();

end;

function ServerContestant.__index:addItem(item: types.ServerItem): ()

  table.insert(self.items, item);
  events[self].onInventoryUpdated:Fire(self:getInventoryItemIDs());

end;

function ServerContestant.__index:removeItem(item: types.ServerItem): ()

  -- Iterating backwards because the indexes can change after running table.remove().
  for index = #self.items, 1, -1 do

    local possibleItem = self.items[index]
    if possibleItem == item then

      table.remove(self.items, index);
      task.spawn(function()

        possibleItem:breakdown();
      
      end);

    end;

  end;

  events[self].onInventoryUpdated:Fire(self:getInventoryItemIDs());

end;

function ServerContestant.__index:removeEffect(effect: types.ServerEffect): ()

  -- Iterating backwards because the indexes can change after running table.remove().
  for index = #self.effects, 1, -1 do

    local possibleEffect = self.effects[index]
    if possibleEffect == effect then

      coroutine.wrap(effect.breakdown)(effect);

      table.remove(self.effects, index);

    end;

  end;

  events[self].onEffectsUpdated:Fire();

end;

function ServerContestant.__index:updateInventory(newInventory: {types.ServerItem}): ()

  self.items = newInventory;

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
    characterName = if self.character then self.character.Name else nil;
    teamID = self.teamID;
    currentHealth = self.currentHealth;
    baseHealth = self:getModifiedBaseValue("Health");
    currentStamina = self.currentStamina;
    baseStamina = self:getModifiedBaseValue("Stamina");
    statistics = self.statistics;
  };

end;

function ServerContestant.__index:updateArchetypeID(newArchetypeID: string): ()

  self.archetypeID = newArchetypeID;
  events[self].onArchetypeUpdated:Fire(newArchetypeID);
  ReplicatedStorage.Shared.Events.ContestantArchetypeUpdated:FireAllClients(self.id, newArchetypeID);

end;

function ServerContestant.__index:updateHealth(newHealth: number, cause: types.Cause?): ()

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

function ServerContestant.__index:updateStamina(newStamina: number, cause: types.Cause?): ()

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

function ServerContestant.__index:mergeStatistics(newStatistics: PatchableTurfWarContestantStatistics, cause: types.Cause?): ()

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
  events[self].onCharacterUpdated:Fire();

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