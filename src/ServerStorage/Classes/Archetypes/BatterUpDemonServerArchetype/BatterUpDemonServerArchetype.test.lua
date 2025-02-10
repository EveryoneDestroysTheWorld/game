--!strict
-- Currently, physics tests can't be done over Roblox's Open Cloud. 

local ServerStorage = game:GetService("ServerStorage");

local createMockContestant = require(ServerStorage.Modules.createMockContestant);

return {
  BatterUpDemonServerArchetype = {
    ["creates a bat for the contestant in batter mode"] = function()

      local contestant = createMockContestant();
      local character = Instance.new("Model");
      contestant:updateCharacter(character);

      contestant.attributes.archetypeMode = "Batter";
      ServerStorage.Events.ArchetypeModeChanged:Fire();

      local bat = character:WaitForChild("Bat", 1);
      assert(bat);

    end;
    ["removes the contestant's bat in pitcher mode"] = function()

      local contestant = createMockContestant();
      local character = Instance.new("Model");
      contestant:updateCharacter(character);
      
      contestant.attributes.archetypeMode = "Pitcher";
      ServerStorage.Events.ArchetypeModeChanged:Fire();
      local bat: Instance? = character:WaitForChild("Bat", 1);
      assert(not bat);

      contestant.attributes.archetypeMode = "Batter";
      ServerStorage.Events.ArchetypeModeChanged:Fire();
      bat = character:WaitForChild("Bat", 1);
      assert(bat);

      local continueEvent = Instance.new("BindableEvent");
      local changeEvent = bat:GetPropertyChangedSignal("Parent"):Connect(function()
      
        if not bat.Parent then

          continueEvent:Fire();

        end;

      end);

      local timeoutThread = task.delay(3, function()
      
        continueEvent:Fire();

      end);

      contestant.attributes.archetypeMode = "Pitcher";
      ServerStorage.Events.ArchetypeModeChanged:Fire();
      continueEvent.Event:Wait();

      task.cancel(timeoutThread);
      changeEvent:Disconnect();
      assert(not bat.Parent);

    end;
  }
}