--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientAction = require(ReplicatedStorage.Client.Interfaces.IClientAction);

export type TarBombClientAction = ClientAction.ClientAction<{
  isCharging: boolean;
  updateTask: thread?;
}>;

return {};