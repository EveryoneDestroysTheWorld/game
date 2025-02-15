--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local PathfindingService = game:GetService("PathfindingService");

local types = require(ServerStorage.Modules.types);

local filterTable = require(ReplicatedStorage.Shared.Modules.filterTable);
local listContestantInstances = require(script.Parent.listContestantInstances);

--[[
  Searches for a target contestant. 
  
  This function considers returning contestants based on team IDs that differ from the provided contestant's team ID.
  After that, it returns the closest contestant that is "visible" to the provided contestant.
]]
return function(autopilot: types.AggressiveAutopilot, scope: "Allies" | "Rivals"): types.ServerContestant?
  
  local character = autopilot.contestant.character;
  if not character then return; end;

  local round = autopilot.contestant.round;

  -- Bots should ensure that the target contestant is within their view.
  -- This keeps things fair.
  local visibleContestants = {};
  local contestantInstances = listContestantInstances(round.contestants);

  for _, contestant in round.contestants do
    
    local isOnSameTeam = autopilot.contestant.teamID and contestant.teamID == autopilot.contestant.teamID;
    local isRival = not isOnSameTeam and contestant.currentHealth > 0;
    if contestant.id ~= autopilot.contestant.id then

      if scope == "Allies" and isOnSameTeam and contestant.isEliminated then

        table.insert(visibleContestants, contestant);

      elseif scope == "Rivals" and isRival then

        local botHead = character:FindFirstChild("Head");
        local enemyPrimaryPart = if contestant.character then contestant.character.PrimaryPart else nil;
        if not contestant.character or not botHead or not botHead:IsA("BasePart") or not enemyPrimaryPart then 
          
          continue; 
        
        end;

        local descendants = contestant.character:GetDescendants();
        local filteredInstances = filterTable(contestantInstances, function(instance)

          return not table.find(descendants, instance);

        end);

        local raycastParams = RaycastParams.new();
        raycastParams.FilterDescendantsInstances = filteredInstances;
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude;

        local raycastResult = workspace:Raycast(botHead.CFrame.Position, enemyPrimaryPart.CFrame.Position - botHead.CFrame.Position, raycastParams);
        if raycastResult and table.find(descendants, raycastResult.Instance) then

          if contestant.id == autopilot.rivalContestantID then

            return contestant;

          else
            
            table.insert(visibleContestants, contestant);

          end;

        end;

      end;

    end;

  end;

  local primaryPart = character.PrimaryPart;
  local targetContestant = nil;
  if visibleContestants[1] and primaryPart then

    -- Choose a target based on their closeness.
    local targetContestantDistance = nil;
    for _, possibleTargetContestant in visibleContestants do

      local path = PathfindingService:CreatePath();
      local targetPrimaryPart = if possibleTargetContestant.character then possibleTargetContestant.character.PrimaryPart else nil;
      if targetPrimaryPart then

        path:ComputeAsync(primaryPart.Position, targetPrimaryPart.Position);

        local waypoints = path:GetWaypoints();
        local previousPosition = primaryPart.Position;
        local possibleTargetContestantDistance = 0;
        for _, waypoint in waypoints do

          possibleTargetContestantDistance += (previousPosition - waypoint.Position).Magnitude;
          previousPosition = waypoint.Position;

        end;

        if not targetContestantDistance or possibleTargetContestantDistance < targetContestantDistance then

          targetContestant = possibleTargetContestant;
          targetContestantDistance = possibleTargetContestantDistance;

        end;

      end;

    end;

  end;

  return targetContestant;

end;