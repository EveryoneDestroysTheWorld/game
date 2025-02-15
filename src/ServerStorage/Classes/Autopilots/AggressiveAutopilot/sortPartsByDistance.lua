--!strict

local PathfindingService = game:GetService("PathfindingService");

local function sortPartsByDistance(primaryPart: BasePart, parts: {BasePart}): ()

  local targetContestantDistances = {};
  for _, targetPart in parts do

    local path = PathfindingService:CreatePath();

    path:ComputeAsync(primaryPart.Position, targetPart.Position);

    local waypoints = path:GetWaypoints();
    local previousPosition = primaryPart.Position;
    local possibleTargetContestantDistance = 0;
    for _, waypoint in waypoints do

      possibleTargetContestantDistance += (previousPosition - waypoint.Position).Magnitude;
      previousPosition = waypoint.Position;

    end;

    table.insert(targetContestantDistances, possibleTargetContestantDistance);

  end;

  table.sort(parts, function(part1, part2)
  
    local part1Index = table.find(parts, part1) or math.huge;
    local part2Index = table.find(parts, part2) or math.huge;
    return part1Index < part2Index;

  end)

end;

return sortPartsByDistance;