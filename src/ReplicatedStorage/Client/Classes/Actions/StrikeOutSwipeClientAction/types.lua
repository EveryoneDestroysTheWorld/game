--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientAction = require(ReplicatedStorage.Client.Interfaces.ClientAction);

export type StrikeOutSwipeClientAction = ClientAction.ClientAction<{
  swingAnimation: AnimationTrack?;
  isCharging: boolean;
}>;

return {};