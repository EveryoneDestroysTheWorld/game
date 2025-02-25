--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientAction = require(ReplicatedStorage.Client.Interfaces.ClientAction);

export type ChangeBallTypeClientAction = ClientAction.ClientAction<{
  gui: ScreenGui?;
}>;

return {};