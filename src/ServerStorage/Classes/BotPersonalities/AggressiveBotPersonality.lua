--!strict

local ServerStorage = game:GetService("ServerStorage");
local PathfindingService = game:GetService("PathfindingService");

local types = require(ServerStorage.Classes.types);

local AggressiveBotPersonality = {
  __index = {} :: types.AggressiveBotPersonality;
};

function AggressiveBotPersonality.new(contestant: types.ServerContestant)

end;

function AggressiveBotPersonality.__index:run(): ()

  local character = self.contestant.character;
  if not character then return end;

  local round = self.contestant.round;

  if self.contestant.currentHealth > 0 then

    -- Bots should ensure that the target contestant is within their view.
    -- This keeps things fair.
    local visibleContestants = {};
    for _, contestant in round.contestants do
      
      if contestant.teamID ~= self.contestant.teamID then

        local botHead = character:FindFirstChild("Head");
        local enemyPrimaryPart = if contestant.character then contestant.character.PrimaryPart else nil;
        if not botHead or not botHead:IsA("BasePart") or not enemyPrimaryPart then 
          
          continue; 
        
        end;

        local raycastResult = workspace:Raycast(botHead.CFrame.Position, enemyPrimaryPart.CFrame.Position - botHead.CFrame.Position, RaycastParams.new());
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
          for _, waypoint in waypoints do

            -- TODO: Summarize distance with Dot

          end;

          local possibleTargetContestantDistance = 0;
          if not targetContestantDistance or possibleTargetContestantDistance < targetContestantDistance then

            targetContestant = possibleTargetContestant;
            targetContestantDistance = possibleTargetContestantDistance;

          end;

        end;

      end;

    end;

    if targetContestant then

      -- TODO: Handle with items, archetypes, and actions.

    elseif self.contestant.currentHealth < self.contestant:getModifiedBaseValue("Health") then

      for _, item in self.contestant.items do

        if item.id == "PotionOfRegeneration" then

          item:activate();

        end;

      end;

    end;

  end;

end;

return AggressiveBotPersonality;