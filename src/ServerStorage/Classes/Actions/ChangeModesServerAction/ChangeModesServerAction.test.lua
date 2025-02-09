--!strict

local ServerStorage = game:GetService("ServerStorage");

local ServerAction = require(ServerStorage.Classes.ServerAction);

local createMockContestant = require(ServerStorage.Modules.createMockContestant);

return {
  ChangeModesServerAction = {
    ["can change archetype modes"] = function()

      local contestant = createMockContestant();
      local action = ServerAction.get("ChangeModes").new({
        contestant = contestant;
      });

      action:activate("Batter");

      assert(contestant.attributes.archetypeMode);
      assert(contestant.attributes.archetypeMode == "Batter");

      action:activate("Pitcher");

      assert(contestant.attributes.archetypeMode :: unknown == "Pitcher");

    end;
  }
}