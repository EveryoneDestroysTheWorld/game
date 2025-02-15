--!strict
-- Bots should ensure that the target part is within their view. This keeps things fair.
--
-- Programmers: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local listContestantInstances = require(script.Parent.listContestantInstances);

--[[
  Returns a list of instances that the autopilot contestant can see.
]]
local function listVisibleVulnerableParts(autopilotContestant: types.ServerContestant, scope: "Unclaimed" | "RivalClaims"): {BasePart}

  local character = autopilotContestant.character;
  if not character then 

    return {};

  end;

  local contestantInstances = listContestantInstances(autopilotContestant.round.contestants);

  local visibleVulnerableParts = {};
  local botHead = character:FindFirstChild("Head");
  if not autopilotContestant.character or not botHead or not botHead:IsA("BasePart") then 
    
    return {}; 
  
  end;

  for _, vulnerablePart in ServerStorage.Functions.GetVulnerableParts:Invoke() do

    local currentDurability = vulnerablePart:GetAttribute("CurrentDurability");
    local isClaimable = typeof(currentDurability) ~= "number" or currentDurability <= 0;
    if scope == "Unclaimed" and isClaimable then

      continue;

    end;

    local destroyerID = vulnerablePart:GetAttribute("DestroyerID");
    if scope == "RivalClaims" and typeof(destroyerID) == "number" then

      local shouldSkip = false;
      for _, contestant in autopilotContestant.round.contestants do

        if contestant.id == destroyerID and contestant.teamID and contestant.teamID == autopilotContestant.teamID then

          shouldSkip = true;
          break;

        end;

      end;

      if shouldSkip then

        continue;

      end;

    end;

    local raycastParams = RaycastParams.new();
    raycastParams.FilterDescendantsInstances = contestantInstances;
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude;

    local raycastResult = workspace:Raycast(botHead.CFrame.Position, vulnerablePart.CFrame.Position - botHead.CFrame.Position, raycastParams);
    if raycastResult and raycastResult.Instance == vulnerablePart then

      table.insert(visibleVulnerableParts, vulnerablePart);

    end;

  end;

  return visibleVulnerableParts;

end;

return listVisibleVulnerableParts;