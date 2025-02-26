--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientEffect = require(ReplicatedStorage.Client.Interfaces.IClientEffect);
type ClientEffect = ClientEffect.ClientEffect;

export type ClientEffectClass<Effect = ClientEffect> = {
  name: string;
  id: string;
  description: string;
  new: (contestantID: number, uniqueEffectID: string) -> Effect;
}

return {};