--!strict

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Classes.types);

return function(contestant: types.ServerContestant): BasePart?

  local visibleVulnerableParts = {};
  for _, vulnerableParts in ServerStorage.Functions.GetVulnerableParts:Invoke() do

    

  end;

  return;

end;