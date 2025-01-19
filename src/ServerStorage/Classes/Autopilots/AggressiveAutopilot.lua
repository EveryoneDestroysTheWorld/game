--!strict

local ServerStorage = game:GetService("ServerStorage");
local PathfindingService = game:GetService("PathfindingService");

local types = require(ServerStorage.Classes.types);

local AggressiveAutopilot = {
  name = "Aggressive";
  id = script.Name:sub(1, script.Name:gsub("ServerEffect", ""):len());
  __index = {} :: types.AggressiveAutopilot;
};

function AggressiveAutopilot.new(properties: types.AggressiveAutopilotConstructorProperties)

  local autopilot = {
    contestant = properties.contestant;
    name = AggressiveAutopilot.name;
    id = AggressiveAutopilot.id;
  };

  return (setmetatable(autopilot, AggressiveAutopilot) :: unknown) :: types.AggressiveAutopilot

end;

function AggressiveAutopilot.__index:run(): ()

  local character = self.contestant.character;
  if not character then return end;

  local round = self.contestant.round;

  if self.contestant.currentHealth > 0 then

    -- Bots should ensure that the target contestant is within their view.
    -- This keeps things fair.
    local visibleContestants = {};
    local contestantInstances: {Instance} = {};
    for _, contestant in round.contestants do

      if contestant.character then

        for _, instance in contestant.character:GetChildren() do

          if instance:IsA("BasePart") then

            table.insert(contestantInstances, instance);

          end;

        end;

      end;

    end;

    for _, contestant in round.contestants do
      
      if contestant.teamID ~= self.contestant.teamID then

        local botHead = character:FindFirstChild("Head");
        local enemyPrimaryPart = if contestant.character then contestant.character.PrimaryPart else nil;
        if not botHead or not botHead:IsA("BasePart") or not enemyPrimaryPart then 
          
          continue; 
        
        end;

        local raycastParams = RaycastParams.new();
        raycastParams.FilterDescendantsInstances = contestantInstances;
        raycastParams.FilterType = Enum.RaycastFilterType.Include;

        local raycastResult = workspace:Raycast(botHead.CFrame.Position, enemyPrimaryPart.CFrame.Position - botHead.CFrame.Position, raycastParams);
        if raycastResult.Instance:IsDescendantOf(contestant.character) then

          table.insert(visibleContestants, contestant);

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

            if self.contestant.name == "BOT 6" then
              print(`{self.contestant.name} goes for {possibleTargetContestant.name} {possibleTargetContestantDistance}`)
            end
              targetContestant = possibleTargetContestant;
            targetContestantDistance = possibleTargetContestantDistance;

          end;

        end;

      end;

    end;

    if targetContestant and self.contestant.name == "BOT 6" then

      -- TODO: Handle with items, archetypes, and actions.
      warn(`{self.contestant.name} should go for {targetContestant.name}`);

    elseif self.contestant.currentHealth < self.contestant:getModifiedBaseValue("Health") then

      for _, item in self.contestant.items do

        if item.id == "PotionOfRegeneration" then

          item:activate();

        end;

      end;

    end;

  end;

end;

return AggressiveAutopilot;