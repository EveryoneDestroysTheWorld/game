--!strict

local ServerStorage = game:GetService("ServerStorage");

local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);

type IServerContestant = IServerContestant.IServerContestant;

return function(contestant: IServerContestant): ()

  for _, modifier in contestant.baseModifiers.health do

    if modifier.cause.actionID == "DetachLimb" then

      contestant:removeBaseModifier("Health", modifier);

    end;

  end;

end;