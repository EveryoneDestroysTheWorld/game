--!strict

local ServerStorage = game:GetService("ServerStorage");

local ChangeModesServerAction = require(script.Parent);

local createMockContestant = require(ServerStorage.Modules.createMockContestant);

return {
  ChangeModesServerAction = {
    ["can change archetype modes"] = function()

      local contestant = createMockContestant();
      local action = ChangeModesServerAction.new(contestant);

      action:activate("Batter");

      assert(contestant.attributes.archetypeMode == "Batter");

      action:activate("Pitcher");

      assert(contestant.attributes.archetypeMode :: unknown == "Pitcher");

    end;
  }
}