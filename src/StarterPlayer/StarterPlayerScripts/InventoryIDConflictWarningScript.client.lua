--!strict
-- This script ensures that there are no ID conflicts in actions and archetypes.
--
-- Programmer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local classes = ReplicatedStorage.Client.Classes;
local ClientAction = require(classes.ClientAction);
type ClientAction = ClientAction.ClientAction;
local ClientArchetype = require(classes.ClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;

for _, directory in {classes.Actions, classes.Archetypes} do

  local idList = {};
  for _, child in directory:GetChildren() do

    if child:IsA("ModuleScript") then

      local id = (require(child) :: ClientAction | ClientArchetype).id;
      assert(not idList[id], `{child.Name} has an ID conflict with {idList[id]}. The game may be unstable.`);
      idList[id] = child.Name;

    end;

  end;

end;