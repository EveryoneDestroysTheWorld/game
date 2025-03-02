--!strict
-- Currently, physics tests can't be done over Roblox's Open Cloud. 

local ServerStorage = game:GetService("ServerStorage");

local HeresThePitchServerAction = require(script.Parent);

local createMockContestant = require(ServerStorage.Modules.createMockContestant);
local createMockRound = require(ServerStorage.Modules.createMockRound);

return {
  HeresThePitchServerAction = {
    ["only works in pitcher mode"] = function()

      local round = createMockRound();
      local contestant = createMockContestant();
      round:addContestant(contestant);
      local action = HeresThePitchServerAction.new(contestant, round);

      local function canRunAction()

        return pcall(function()
      
          action:activate();
  
        end)

      end;

      contestant.attributes.archetypeMode = "Batter";
      assert(not canRunAction());

      -- contestant.attributes.archetypeMode = "Pitcher";
      -- assert(canRunAction());

    end;
  }
}