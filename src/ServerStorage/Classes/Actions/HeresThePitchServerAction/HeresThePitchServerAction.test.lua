--!strict
-- Currently, physics tests can't be done over Roblox's Open Cloud. 

local ServerStorage = game:GetService("ServerStorage");

local ServerAction = require(ServerStorage.Classes.ServerAction);

local createMockContestant = require(ServerStorage.Modules.createMockContestant);

return {
  HeresThePitchServerAction = {
    ["only works in pitcher mode"] = function()

      local contestant = createMockContestant();
      local action = ServerAction.get("ChangeModes").new({
        contestant = contestant;
      });

      contestant.attributes.archetypeMode = "Batter";

      local canRunAction = pcall(function()
      
        action:activate();

      end);

      assert(not canRunAction);

      -- TODO: Test pitcher mode.

    end;
  }
}