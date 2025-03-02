--!strict

local ServerStorage = game:GetService("ServerStorage");

local ServerContestant = require(ServerStorage.Classes.Utilities.ServerContestant);

local function createMockContestant()

  return ServerContestant.new({
    name = "Mock";
    id = 0;
    roundID = "Mock"
  });

end;

return createMockContestant;