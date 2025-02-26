--!strict

export type IServerAction<ExtendedProperties = {[unknown]: any}> = {
  id: string;
  name: string;
  description: string;
} & ExtendedProperties & {
  activate: (self: any, ...any) -> ();
  breakdown: (self: any, ...any) -> (); 
};

export type ServerActionClass<ConstructorProperties = any, Action = any> = {
  new: (...ConstructorProperties) -> Action
}

export type ServerActionFactory = {
  get: (actionID: string) -> ServerActionClass;
}

return {}