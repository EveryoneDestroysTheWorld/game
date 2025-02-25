--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientActionTypes = require(ReplicatedStorage.Client.Classes.ClientAction.types);

export type StrikeOutSwipeClientAction = ClientActionTypes.ClientAction<{
  swingAnimation: AnimationTrack?;
  isCharging: boolean;
}>;

return {};