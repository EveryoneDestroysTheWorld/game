--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientAction = require(ReplicatedStorage.Client.Interfaces.IClientAction);

export type DetachLimbClientAction = ClientAction.ClientAction<{
  gui: ScreenGui?;
}>;

return {};