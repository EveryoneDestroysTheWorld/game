--!strict
local ServerStorage = game:GetService("ServerStorage");
local types = require(ServerStorage.Classes.types)

return function(contestant: types.ServerContestant)

  assert(not ServerStorage.Functions.GetActionLocks:Invoke(contestant.id), "Actions are currently locked.");

end;