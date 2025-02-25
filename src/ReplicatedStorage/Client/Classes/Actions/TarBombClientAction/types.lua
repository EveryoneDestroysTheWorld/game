--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientActionTypes = require(ReplicatedStorage.Client.Classes.ClientAction.types);

export type TarBombClientAction = ClientActionTypes.ClientAction<{
  isCharging: boolean;
  updateTask: thread?;
}>;

return {};