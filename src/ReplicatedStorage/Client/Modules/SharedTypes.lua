--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local TurfWarContestantStatistics = require(ReplicatedStorage.Shared.TurfWarContestantStatistics);
export type TurfWarContestantStatistics = TurfWarContestantStatistics.TurfWarContestantStatistics;

export type BallType = "Regular" | "Explosive" | "Electric" | "Poison";

export type ClientContestant = ClientContestantProperties & ClientContestantEvents & ClientContestantMethods;

export type ClientContestantConstructorProperties = ClientContestantProperties & {
  characterName: string?;
};

export type ClientContestantProperties = {
  
  id: number;

  archetypeID: string?;
  
  isDisqualified: boolean;

  player: Player?;

  character: Model?;

  name: string;

  isBot: boolean;

  teamID: number?;

  currentHealth: number?;

  baseHealth: number?;

  currentStamina: number?;

  baseStamina: number?;

  statistics: TurfWarContestantStatistics?;
  
}

export type Cause = {
  archetypeID: string;
  contestantID: number;
  actionID: string?;
}

export type ClientContestantMethods = {
}

export type ClientContestantEvents = {
  onDisqualified: RBXScriptSignal;
  onHealthUpdated: RBXScriptSignal;
  onStaminaUpdated: RBXScriptSignal;
  onArchetypeUpdated: RBXScriptSignal;
  onCharacterUpdated: RBXScriptSignal;
  onStatisticsUpdated: RBXScriptSignal;
}

export type ClientEffect<Properties = ClientEffectProperties, Methods = ClientEffectMethods> = Properties & Methods;

export type ClientEffectClass<ClientEffectConstructorProperties = any, ExtendedClientEffect = any> = ClientEffectProperties & {
  new: (...ClientEffectConstructorProperties) -> ExtendedClientEffect & ClientEffect
}

export type ClientEffectFactory = {
  get: (
    ((effectID: "Paralysis") -> ClientEffectClass<ParalysisClientEffectConstructorProperties, ParalysisClientEffect>)
    & ((effectID: string) -> ClientEffectClass)
  );
  random: () -> ClientEffectClass;
}

export type ClientEffectProperties = {
  name: string;
  id: string;
  description: string?;
}

export type ClientEffectMethods = {
  activate: ((self: any, ...any) -> ())?;
  deactivate: ((self: any, ...any) -> ())?;
}

export type ParalysisClientEffect = ClientEffect<ParalysisClientEffectProperties & ParalysisClientEffectMethods>;

export type ParalysisClientEffectProperties = {
  name: string;
  id: string;
  contestant: ClientContestant;
  uniqueID: string;
  events: {RBXScriptConnection};
  remoteFunction: RemoteFunction;
  frozenAnimations: {
    [AnimationTrack]: number;
  }
}

export type ParalysisClientEffectMethods = {
  activate: (self: ParalysisClientEffect) -> ();
  deactivate: (self: ParalysisClientEffect) -> ();
}

export type ParalysisClientEffectConstructorProperties = {
  contestant: ClientContestant;
  uniqueID: string;
  events: {RBXScriptConnection};
}

return {};