--!strict

local ServerStorage = game:GetService("ServerStorage");

local IServerAction = require(ServerStorage.Interfaces.IServerAction);

type IServerAction = IServerAction.IServerAction;

export type IServerArchetype<Attributes = {}> = ServerArchetypeProperties<Attributes> & {

  breakdown: (self: IServerArchetype<Attributes>) -> ();

  getActions: (self: IServerArchetype<Attributes>) -> {IServerAction};

};

export type ArchetypeType = "Fighter" | "Defender" | "Destroyer" | "Supporter";

export type ServerArchetypeProperties<Attributes> = {
  
  id: string;
  
  name: string;

  description: string;

  type: ArchetypeType;

  actionIDs: {string};

  attributes: Attributes;
  
};

return {};