--!strict
-- This module represents a contestant.
-- 
-- Programmers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local StarterPlayer = game:GetService("StarterPlayer");
local ServerStorage = game:GetService("ServerStorage");

local IClientContestant = require(ReplicatedStorage.Client.Interfaces.IClientContestant);
local IServerArchetype = require(ServerStorage.Interfaces.IServerArchetype);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);
local IServerEffect = require(ServerStorage.Interfaces.IServerEffect);
local IServerRound = require(ServerStorage.Interfaces.IServerRound);
local SharedTypes = require(ServerStorage.Modules.SharedTypes);
local TurfWarContestantStatistics = require(ReplicatedStorage.Shared.TurfWarContestantStatistics);

type Cause = SharedTypes.Cause;
type IClientContestant = IClientContestant.IClientContestant;
type IServerArchetype = IServerArchetype.IServerArchetype;
type IServerContestant = IServerContestant.IServerContestant;
type IServerContestantProperties = IServerContestant.IServerContestantProperties;
type IServerEffect = IServerEffect.IServerEffect;
type IServerRound = IServerRound.IServerRound;
type TurfWarContestantStatistics = TurfWarContestantStatistics.TurfWarContestantStatistics;
type PatchableTurfWarContestantStatistics = TurfWarContestantStatistics.PatchableTurfWarContestantStatistics;

local ServerContestant = {};

function ServerContestant.new(properties: IServerContestantProperties): IServerContestant

  local archetype: IServerArchetype? = nil;
  local character: Model? = nil;
  local effects: {IServerEffect} = {};

  local function addBaseModifier(self: IServerContestant, modifierType: IServerContestant.BaseModifierType, modifier: IServerContestant.BaseModifier): ()

    local modifiers = if modifierType == "Health" then self.baseModifiers.health else self.baseModifiers.stamina;
    table.insert(modifiers, modifier);
  
  end;

  local function addEffect(self: IServerContestant, effect: IServerEffect): ()

    table.insert(effects, effect);
  
    if effect.activate then
  
      task.spawn(function()
      
        effect.activate(effect, self);
  
      end);
  
    end;
  
  end;

  local function addWalkSpeedWeight(self: IServerContestant, weight: IServerContestant.WalkSpeedWeight): ()

    table.insert(self.walkSpeedWeights, weight);
  
    self:refreshWalkSpeed();
  
  end;

  local function convertToClientContestant(self: IServerContestant): IClientContestant

    local contestant: IClientContestant = {
      id = self.id;
      archetypeID = self.archetypeID;
      isEliminated = self.isEliminated;
      player = self.player;
      characterName = if character then character.Name else nil;
      name = self.name;
      teamID = self.teamID;
      currentHealth = self.currentHealth;
      baseHealth = self:getModifiedBaseValue("Health");
      currentStamina = self.currentHealth;
      baseStamina = self:getModifiedBaseValue("Stamina");
    }

    return contestant;

  end;

  local function eliminate(self: IServerContestant, shouldCreateRagdoll: boolean)

    assert(not self.isEliminated, "Contestant has already been eliminated.");
  
    self.isEliminated = true;
  
  end;

  local function removeEffect(self: IServerContestant, effect: IServerEffect): ()

    -- Iterating backwards because the indexes can change after running table.remove().
    for index = #effects, 1, -1 do
  
      local possibleEffect = effects[index]
      if possibleEffect == effect then
  
        coroutine.wrap(effect.breakdown)(effect);
  
        table.remove(effects, index);
  
      end;
  
    end;
  
  end

  local function getArchetype(self: IServerContestant): IServerArchetype?

    return archetype;

  end;

  local function getCharacter(self: IServerContestant): Model?

    return character;

  end;

  local function getEffects(self: IServerContestant): {IServerEffect}

    return effects;

  end;

  local function getModifiedBaseValue(self: IServerContestant, modifierType: IServerContestant.BaseModifierType): number

    local modifiedBaseValue = if modifierType == "Health" then self.baseHealth else self.baseStamina;
    local modifiers: {IServerContestant.BaseModifier} = if modifierType == "Health" then self.baseModifiers.health else self.baseModifiers.stamina;
  
    for _, modifier in modifiers do
  
      modifiedBaseValue += modifier.delta;
  
    end;
  
    return modifiedBaseValue;
  
  end

  local function refreshWalkSpeed(self: IServerContestant): ()

    local humanoid = if character then character:FindFirstChild("Humanoid") else nil;
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

  local function removeBaseModifier(self: IServerContestant, modifierType: IServerContestant.BaseModifierType, modifier: IServerContestant.BaseModifier): ()

    local modifiers = if modifierType == "Health" then self.baseModifiers.health else self.baseModifiers.stamina;
    local index = table.find(modifiers, modifier);
    if index then
  
      table.remove(modifiers, index);
  
    end;
  
  end;

  local function removeWalkSpeedWeight(self: IServerContestant, weight: IServerContestant.WalkSpeedWeight): ()

    local index = table.find(self.walkSpeedWeights, weight);
    if index then
  
      table.remove(self.walkSpeedWeights, index);
  
      self:refreshWalkSpeed();
  
    end;
  
  end;

  local function setArchetype(self: IServerContestant, newArchetype: IServerArchetype?): ()

    archetype = newArchetype;
    
    local archetypeID = if newArchetype then newArchetype.id else nil;
    ReplicatedStorage.Shared.Events.ContestantArchetypeUpdated:FireAllClients(self.id, archetypeID);
  
  end

  local function setBaseHealth(self: IServerContestant, newValue: number, cause: Cause?): ()
  
    self.baseHealth = newValue;
  
  end;

  local function setBaseStamina(self: IServerContestant, newValue: number, cause: Cause?): ()
  
    self.baseStamina = newValue;
  
  end;

  local function setCharacter(self: IServerContestant, newCharacter: Model?): ()

    character = newCharacter;
    ReplicatedStorage.Shared.Events.CharacterUpdated:FireAllClients(self.id, if newCharacter then newCharacter.Name else nil);
  
  end;

  local function setCurrentHealth(self: IServerContestant, newValue: number, cause: Cause?): ()

    for _, effect in effects do
  
      if effect.updateContestantHealth then
  
        newValue = effect.updateContestantHealth(effect, newValue, self.currentHealth, cause);
  
      end;
  
    end;
  
    self.currentHealth = newValue;
  
    ReplicatedStorage.Shared.Events.HealthUpdated:FireAllClients(self.id, newValue, cause);
  
  end;

  local function setCurrentStamina(self: IServerContestant, newValue: number, cause: Cause?): ()
  
    for _, effect in effects do
  
      if effect.updateContestantStamina then
  
        newValue = effect.updateContestantStamina(effect, newValue, self.currentStamina, cause);
  
      end;
  
    end;
  
    self.currentStamina = newValue;
  
    ReplicatedStorage.Shared.Events.StaminaUpdated:FireAllClients(self.id, newValue, cause);
  
  end;

  local baseHealth = 1000;
  local baseStamina = 1000;
  local contestant: IServerContestant = {
    baseHealth = baseHealth;
    currentHealth = baseHealth;
    baseStamina = baseStamina;
    currentStamina = baseStamina;
    isEliminated = false;
    isAutoEliminationEnabled = true;
    attributes = {};
    tags = {};
    walkSpeedWeights = {};
    baseModifiers = {
      health = {};
      stamina = {};
    };
    effects = {};
    id = properties.id;
    name = properties.name;
    roundID = properties.roundID;
    addBaseModifier = addBaseModifier;
    addEffect = addEffect;
    addWalkSpeedWeight = addWalkSpeedWeight;
    convertToClientContestant = convertToClientContestant;
    eliminate = eliminate;
    getArchetype = getArchetype;
    getCharacter = getCharacter;
    getEffects = getEffects;
    getModifiedBaseValue = getModifiedBaseValue;
    refreshWalkSpeed = refreshWalkSpeed;
    removeBaseModifier = removeBaseModifier;
    removeEffect = removeEffect;
    removeWalkSpeedWeight = removeWalkSpeedWeight;
    setArchetype = setArchetype;
    setBaseHealth = setBaseHealth;
    setBaseStamina = setBaseStamina;
    setCharacter = setCharacter;
    setCurrentHealth = setCurrentHealth;
    setCurrentStamina = setCurrentStamina;
  };

  return contestant;
  
end


return ServerContestant;