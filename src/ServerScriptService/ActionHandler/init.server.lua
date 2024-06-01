local ReplicatedStorage = game:GetService("ReplicatedStorage");

ReplicatedStorage.Shared.Functions.ExecuteAction.OnServerInvoke = function(player: Player, actionName: string?, ...: any)

  -- Verify parameter types during runtime to maintain server security.
  assert(typeof(actionName) == "string", "Action name must be a string.");

  -- Execute the action.
  return require(script.DetachLimbAction):execute(player, ...);

end;