--!strict
-- Currently, physics tests can't be done over Roblox's Open Cloud. 

local ServerStorage = game:GetService("ServerStorage");
local PhysicsService = game:GetService("PhysicsService");

local ServerArchetype = require(ServerStorage.Classes.ServerArchetype);

local createMockContestant = require(ServerStorage.Modules.createMockContestant);
local initializeCollisionGroup = require(ServerStorage.Modules.initializeCollisionGroup);

return {
  BatterUpDemonServerArchetype = {
    ["creates a bat for the contestant in batter mode"] = function()

      local contestant = createMockContestant();
      local character = ServerStorage.NPCRigs.Rig:Clone();
      contestant:updateCharacter(character);
      
      local collisionGroupName = `Contestant-{contestant.id}`;
      initializeCollisionGroup(collisionGroupName, character);

      ServerArchetype.get("BatterUpDemon").new({
        contestant = contestant;
      });

      contestant.attributes.archetypeMode = "Batter";
      ServerStorage.Events.ArchetypeModeChanged:Fire(contestant.id);

      local bat = character:WaitForChild("Bat", 1);
      assert(bat);

      PhysicsService:UnregisterCollisionGroup(collisionGroupName);

    end;
    ["removes the contestant's bat in pitcher mode"] = function()

      local contestant = createMockContestant();
      local character = ServerStorage.NPCRigs.Rig:Clone();
      contestant:updateCharacter(character);
      
      local collisionGroupName = `Contestant-{contestant.id}`;
      initializeCollisionGroup(collisionGroupName, character);

      ServerArchetype.get("BatterUpDemon").new({
        contestant = contestant;
      });
      
      contestant.attributes.archetypeMode = "Pitcher";
      ServerStorage.Events.ArchetypeModeChanged:Fire(contestant.id);
      local bat: Instance? = character:WaitForChild("Bat", 1);
      assert(not bat);

      contestant.attributes.archetypeMode = "Batter";
      ServerStorage.Events.ArchetypeModeChanged:Fire(contestant.id);
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
      ServerStorage.Events.ArchetypeModeChanged:Fire(contestant.id);
      continueEvent.Event:Wait();

      if coroutine.status(timeoutThread) == "running" then

        task.cancel(timeoutThread);

      end;
      
      changeEvent:Disconnect();
      assert(not bat.Parent);
      PhysicsService:UnregisterCollisionGroup(collisionGroupName);

    end;
  }
}