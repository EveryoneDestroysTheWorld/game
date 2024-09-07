--!strict
-- This script ensures that there are no ID conflicts in actions and archetypes.
-- Writers: Christian Toney (Christian_Toney)

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local classes = ReplicatedStorage.Client.Classes;

for _, directory in {classes.Actions, classes.Archetypes} do

  local idList = {};
  for _, child in directory:GetChildren() do

    if child:IsA("ModuleScript") then

      local id = (require(child) :: {ID: string}).ID;
      assert(not idList[id], `{child.Name} has an ID conflict with {idList[id]}. The game may be unstable.`);
      idList[id] = child.Name;

    end;

  end;

end;

script:Destroy();