--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local TurfWarContestantStatistics = require(ReplicatedStorage.Shared.TurfWarContestantStatistics);
export type TurfWarContestantStatistics = TurfWarContestantStatistics.TurfWarContestantStatistics;

export type BallType = "Regular" | "Explosive" | "Electric" | "Poison";

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

return {};