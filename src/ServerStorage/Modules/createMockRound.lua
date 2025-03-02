--!strict

local ServerStorage = game:GetService("ServerStorage");

local ServerRound = require(ServerStorage.Classes.Utilities.ServerRound);

local function createMockContestant()

  return ServerRound.new({
    contestantIDs = {};
    status = "Waiting for players";
    gameModeID = "TurfWar";
    id = "MOCK"
  });

end;

return createMockContestant;