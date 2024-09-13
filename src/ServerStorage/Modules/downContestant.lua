--!strict
local ServerStorage = game:GetService("ServerStorage");
local ServerContestant = require(ServerStorage.Classes.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;

return function(contestant: ServerContestant): ()

  -- Remove all items from their inventory.
  contestant:updateInventory({});

  -- Turn the player transparent.
  if contestant.character then

    local highlight = Instance.new("Highlight");
    highlight.Name = "GhostHighlight";
    highlight.Parent = contestant.character;
    highlight.OutlineTransparency = 1;
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded;
    highlight.FillColor = Color3.fromRGB(152, 202, 248);
    highlight.FillTransparency = 0.5;

    local proximityPrompt = Instance.new("ProximityPrompt");
    proximityPrompt.Name = "RevivalProximityPrompt";
    proximityPrompt.ObjectText = "Downed contestant";
    proximityPrompt.ActionText = "Revive";
    proximityPrompt.HoldDuration = 3;
    proximityPrompt.Triggered:Once(function(player)
  
      -- Prevent the player from reviving themself.
      if player ~= contestant.player then

        contestant:updateHealth(contestant.baseHealth / 2);
        highlight:Destroy();
        proximityPrompt:Destroy();

      end;

    end);
    proximityPrompt.Parent = contestant.character;

  end;

end;