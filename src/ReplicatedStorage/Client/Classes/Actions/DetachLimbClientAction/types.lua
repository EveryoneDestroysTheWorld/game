--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientAction = require(ReplicatedStorage.Client.Interfaces.ClientAction);

export type DetachLimbClientAction = ClientAction.ClientAction<{
  gui: ScreenGui?;
}>;

return {};