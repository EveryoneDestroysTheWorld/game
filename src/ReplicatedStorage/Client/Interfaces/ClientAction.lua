--!strict

export type ClientAction<Attributes = {}> = ClientActionProperties<Attributes> & ClientActionMethods<ClientAction<Attributes>>;

export type ClientActionMethods<Action> = {

  --[[
    The function to activate the item on the server side. You can manually activate the item some other way too.
  ]]--
  activate: (self: Action) -> ();

  -- The function to "break down" the item. This usually runs after the round ends and sometimes after item use.
  -- You can manually break down the item some other way too.
  breakdown: (self: Action) -> ();

};

export type ClientActionProperties<Attributes> = {

  attributes: Attributes;

  -- The ID of the action. Keep this unique.
  id: string;

  -- The name of the action.
  name: string;

  -- The Roblox asset link to the action's icon image.
  iconImage: string;

  -- The description of the action.
  description: string;

  remoteFunction: RemoteFunction;

  remoteEvent: RemoteEvent?;
  
};

return {};
