--!strict

export type IServerAction<Attributes = {[string]: any}, ActivationArguments... = (), BreakdownArguments... = ()> = {
  id: string;
  name: string;
  description: string;
  remoteFunction: RemoteFunction?;
  remoteEvent: RemoteEvent?;
  attributes: Attributes;
  contestantID: number;
} & {
  activate: (self: IServerAction<Attributes, ActivationArguments..., BreakdownArguments...>, ActivationArguments...) -> ();
  breakdown: (self: IServerAction<Attributes, ActivationArguments..., BreakdownArguments...>, BreakdownArguments...) -> (); 
};

export type ServerActionClass<ConstructorProperties = any, Action = any> = {
  new: (...ConstructorProperties) -> Action
}

export type ServerActionFactory = {
  get: (actionID: string) -> ServerActionClass;
}

return {}