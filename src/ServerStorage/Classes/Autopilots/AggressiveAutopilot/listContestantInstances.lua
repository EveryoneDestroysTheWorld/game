--!strict

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local function listContestantInstances(contestants: {types.ServerContestant}): {Instance}

  local instances: {Instance} = {};

  for _, contestant in contestants do

    if contestant.character then

      for _, instance in contestant.character:GetChildren() do

        if instance:IsA("BasePart") then

          table.insert(instances, instance);

        end;

      end;

    end;

  end;

  return instances;

end;

return listContestantInstances;