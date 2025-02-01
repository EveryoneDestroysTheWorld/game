--!strict

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local function removeExcessiveBalls(action: types.HeresThePitchServerAction): ()

  local maximumBalls = 10;
  while #action.balls + 1 > maximumBalls do

    action.balls[1]:Destroy();
    table.remove(action.balls, 1);

  end;

end;

return removeExcessiveBalls;