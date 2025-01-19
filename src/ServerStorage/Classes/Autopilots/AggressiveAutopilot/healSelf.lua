--!strict

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Classes.types);

return function(autopilotContestant: types.ServerContestant)
  
  for _, item in autopilotContestant.items do

    if item.id == "PotionOfRegeneration" then

      item:activate();

    end;

  end;

end;