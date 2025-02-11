--!strict

local ServerStorage = game:GetService("ServerStorage");

local ServerContestant = require(ServerStorage.Classes.ServerContestant);
local types = require(ServerStorage.Modules.types);

local function createMockContestant()

  return ServerContestant.new({
    round = {} :: types.ServerRound;
    name = "Test";
    id = 0;
  });

end;

return createMockContestant;