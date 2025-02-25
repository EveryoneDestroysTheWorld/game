--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientActionTypes = require(ReplicatedStorage.Client.Classes.ClientAction.types);

export type FireBeamClientAction = ClientActionTypes.ClientAction<{
  updateTask: thread?;
  isCharging: boolean;
}>;

return {};