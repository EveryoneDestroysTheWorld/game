--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientAction = require(ReplicatedStorage.Client.Interfaces.IClientAction);

export type FireBeamClientAction = ClientAction.ClientAction<{
  updateTask: thread?;
  isCharging: boolean;
}>;

return {};