--!strict

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local function findContestantFromPart(contestantList: {types.ServerContestant}, basePart: BasePart): types.ServerContestant?

  for _, possibleMatch in contestantList do

    if possibleMatch.character and possibleMatch.character:IsAncestorOf(basePart) then

      return possibleMatch;

    end;

  end;

  return;

end;

return findContestantFromPart;