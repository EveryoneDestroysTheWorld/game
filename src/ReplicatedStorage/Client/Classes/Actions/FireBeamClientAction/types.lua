--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientAction = require(ReplicatedStorage.Client.Interfaces.ClientAction);

export type FireBeamClientAction = ClientAction.ClientAction<{
  updateTask: thread?;
  isCharging: boolean;
}>;

return {};