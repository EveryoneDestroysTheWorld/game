--!strict

local ServerStorage = game:GetService("ServerStorage");

local ServerAction = require(ServerStorage.Classes.ServerAction);

local createMockContestant = require(ServerStorage.Modules.createMockContestant);

return {
  ChangeModesServerAction = {
    ["only works in batter mode"] = function()

      local contestant = createMockContestant();
      local action = ServerAction.get("StrikeOutSwipe").new({
        contestant = contestant;
      });

      local function canRunAction()

        return pcall(function()
      
          action:activate();
  
        end)

      end;

      contestant.attributes.archetypeMode = "Pitcher";
      assert(not canRunAction());

      -- contestant.attributes.archetypeMode = "Batter";
      -- assert(canRunAction());

    end;
  }
}