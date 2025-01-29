--!strict

local ServerStorage = game:GetService("ServerStorage");
local types = require(ServerStorage.Modules.types);

return function(contestant: types.ServerContestant): ()

  for _, modifier in contestant.baseModifiers.health do

    if modifier.cause.actionID == "DetachLimb" then

      contestant:removeBaseModifier("Health", modifier);

    end;

  end;

end;