--!strict

local ServerStorage = game:GetService("ServerStorage");

local ServerContestant = require(ServerStorage.Classes.Utilities.ServerContestant);

local function createMockContestant()

  return ServerContestant.new({
    name = "Test";
    id = 0;
    roundID = "Test"
  });

end;

return createMockContestant;