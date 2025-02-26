--!strict

local ServerStorage = game:GetService("ServerStorage");

local SharedTypes = require(ServerStorage.Modules.SharedTypes);

export type ServerEffectProperties<Attributes> = {
  id: string;
  name: string;
  uniqueID: string;
  description: string;
  attributes: Attributes
};

export type IServerEffect<Attributes = {}> = ServerEffectProperties<Attributes> & {
  activate: (self: IServerEffect<Attributes>, ...any) -> ();
  breakdown: (self: IServerEffect<Attributes>, ...any) -> (); 
  updateContestantHealth: ((self: IServerEffect<Attributes>, newHealth: number, oldHealth: number, cause: SharedTypes.Cause?) -> number)?;
  updateContestantStamina: ((self: IServerEffect<Attributes>, newHealth: number, oldHealth: number, cause: SharedTypes.Cause?) -> number)?;
};

return {};