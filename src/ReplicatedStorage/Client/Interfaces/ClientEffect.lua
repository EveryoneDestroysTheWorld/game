--!strict

export type ClientEffect<Attributes = {}> = ClientEffectProperties<Attributes> & ClientEffectMethods<ClientEffect<Attributes>>;

export type ClientEffectProperties<Attributes> = {
  name: string;
  id: string;
  uniqueID: string;
  contestantID: number;
  description: string?;
  attributes: Attributes;
  remoteFunction: RemoteFunction;
}

export type ClientEffectMethods<Effect> = {
  activate: ((self: Effect, ...any) -> ());
  deactivate: ((self: Effect, ...any) -> ());
}

return {};