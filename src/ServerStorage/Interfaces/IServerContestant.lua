--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local IClientContestant = require(ReplicatedStorage.Client.Interfaces.IClientContestant);
local IServerArchetype = require(ServerStorage.Interfaces.IServerArchetype);
local IServerEffect = require(ServerStorage.Interfaces.IServerEffect);
local SharedTypes = require(ServerStorage.Modules.SharedTypes);

type Cause = SharedTypes.Cause;
type IClientContestant = IClientContestant.IClientContestant;
type IServerArchetype = IServerArchetype.IServerArchetype;
type IServerEffect = IServerEffect.IServerEffect;

export type BaseModifierType = "Health" | "Stamina";

export type BaseModifier = {
  delta: number;
  cause: Cause;
};

export type WalkSpeedWeight = {
  walkSpeed: number;
  weight: number;
};

export type IServerContestant = IServerContestantProperties & ServerContestantMethods;

export type IServerContestantProperties = {

  archetypeID: string?;

  currentStamina: number;

  walkSpeedWeights: {WalkSpeedWeight};

  roundID: string;

  ghostHighlight: Highlight?;

  characterRagdollClone: Model?;

  revivalProximityPrompt: ProximityPrompt?;

  -- The ID of the contestant. 
  -- If the contestant is a bot, this is a unique temporary ID assigned by the server. It will be an irrational number.
  -- If the contestant is a player, this is the same value as player.UserId. It will be an integer.
  id: number;

  -- The name of the contestant. This is here to easily reference bot names. 
  -- If the contestant is a player, this is the same value as player.DisplayName. To get the username, use player.Name.
  name: string;

  -- Is this contestant still a part of the game?
  isEliminated: boolean;

  isAutoEliminationEnabled: boolean;

  -- The player reference of the contestant. This should be nil if the contestant isn't a player.
  player: Player?;

  -- The team ID of the contestant. This will be nil if the game rules call for a free-for-all.
  teamID: number?;

  baseModifiers: {
    health: {BaseModifier};
    stamina: {BaseModifier};
  };

  currentHealth: number;

  baseHealth: number;

  baseStamina: number;

  attributes: {
    [string]: unknown;
  };

  tags: {string};
  
}

export type ServerContestantMethods = {
  addWalkSpeedWeight: (self: IServerContestant, weight: WalkSpeedWeight) -> ();
  addBaseModifier: (self: IServerContestant, modifierType: BaseModifierType, modifier: BaseModifier) -> ();
  eliminate: (self: IServerContestant, shouldCreateRagdoll: boolean) -> ();
  removeBaseModifier: (self: IServerContestant, modifierType: BaseModifierType, modifier: BaseModifier) -> ();
  removeWalkSpeedWeight: (self: IServerContestant, weight: WalkSpeedWeight) -> ();
  refreshWalkSpeed: (self: IServerContestant) -> ();
  addEffect: (self: IServerContestant, effect: IServerEffect) -> ();
  removeEffect: (self: IServerContestant, effect: IServerEffect) -> ();
  convertToClientContestant: (self: IServerContestant) -> IClientContestant;
  getEffects: (self: IServerContestant) -> {IServerEffect};
  getModifiedBaseValue: (self: IServerContestant, modifierType: BaseModifierType) -> number;
  setArchetype: (self: IServerContestant, archetype: IServerArchetype?) -> ();
  setCharacter: (self: IServerContestant, newCharacter: Model?) -> ();
  setCurrentHealth: (self: IServerContestant, newHealth: number, cause: Cause?) -> ();
  setCurrentStamina: (self: IServerContestant, newStamina: number, cause: Cause?) -> ();
  setBaseHealth: (self: IServerContestant, newHealth: number, cause: Cause?) -> ();
  setBaseStamina: (self: IServerContestant, newStamina: number, cause: Cause?) -> ();
  getArchetype: (self: IServerContestant) -> IServerArchetype?;
  getCharacter: (self: IServerContestant) -> Model?;
}

return {}