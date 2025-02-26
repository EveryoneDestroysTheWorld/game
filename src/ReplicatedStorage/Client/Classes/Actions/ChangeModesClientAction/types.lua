--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientAction = require(ReplicatedStorage.Client.Interfaces.IClientAction);

export type BatterUpDemonMode = "Batter" | "Pitcher";

export type ChangeModesClientAction = ClientAction.ClientAction<{
  currentMode: BatterUpDemonMode;
}>;

return {};