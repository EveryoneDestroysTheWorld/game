--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientEffect = require(ReplicatedStorage.Client.Interfaces.IClientEffect);

export type ParalysisClientEffect = ClientEffect.ClientEffect<ParalysisClientEffectAttributes>;

export type ParalysisClientEffectAttributes = {
  events: {RBXScriptConnection};
  frozenAnimations: {
    [AnimationTrack]: number;
  }
}

export type ParalysisClientEffectConstructorProperties = {
  contestant: number;
  uniqueID: string;
  events: {RBXScriptConnection};
}

return {};