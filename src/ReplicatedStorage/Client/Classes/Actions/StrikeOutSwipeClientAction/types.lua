--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientAction = require(ReplicatedStorage.Client.Interfaces.IClientAction);

export type StrikeOutSwipeClientAction = ClientAction.ClientAction<{
  swingAnimation: AnimationTrack?;
  isCharging: boolean;
}>;

return {};