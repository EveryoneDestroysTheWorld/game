--!strict

local ServerStorage = game:GetService("ServerStorage");

local StrikeOutSwipeServerAction = require(script.Parent);

local createMockContestant = require(ServerStorage.Modules.createMockContestant);
local createMockRound = require(ServerStorage.Modules.createMockRound);

return {
  ChangeModesServerAction = {
    ["only works in batter mode"] = function()

      local round = createMockRound();
      local contestant = createMockContestant();
      round:addContestant(contestant);
      local action = StrikeOutSwipeServerAction.new(contestant, round);

      local function canRunAction()

        return pcall(function()
      
          action:activate(false);
  
        end)

      end;

      contestant.attributes.archetypeMode = "Pitcher";
      assert(not canRunAction());

      -- contestant.attributes.archetypeMode = "Batter";
      -- assert(canRunAction());

    end;
  }
}