--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientAction = require(ReplicatedStorage.Client.Interfaces.IClientAction);

type ClientAction = ClientAction.ClientAction;

export type ClientActionClass<Action = ClientAction> = {

  -- The ID of the action. Keep this unique.
  id: string;

  -- The name of the action.
  name: string;

  -- The Roblox asset link to the action's icon image.
  iconImage: string;

  -- The description of the action.
  description: string;

  new: (contestantID: number) -> Action

}

return {};