--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientAction = require(ReplicatedStorage.Client.Interfaces.ClientAction);

export type BatterUpDemonMode = "Batter" | "Pitcher";

export type ChangeModesClientAction = ClientAction.ClientAction<{
  currentMode: BatterUpDemonMode;
}>;

return {};