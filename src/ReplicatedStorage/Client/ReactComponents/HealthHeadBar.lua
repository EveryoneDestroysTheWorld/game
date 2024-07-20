--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);

type HealthHeadBar = {
  contestant: ClientContestant.ClientContestant;
}

local function HealthHeadBar(props: HealthHeadBar)

  local sizeXScale: number, setSizeXScale = React.useState(1);

  React.useEffect(function()

    local healthUpdatedEvent = props.contestant.onHealthUpdated:Connect(function()
    
      local character = props.contestant.character;
      local humanoid = if character then character:FindFirstChild("Humanoid") else nil;
      if humanoid then

        local baseHealth = humanoid:GetAttribute("BaseHealth");
        local currentHealth = humanoid:GetAttribute("CurrentHealth");
        if typeof(baseHealth) == "number" and typeof(currentHealth) == "number" then

          setSizeXScale(currentHealth / baseHealth);
          return;

        end;

      end;

      setSizeXScale(0);

    end);

    return function()

      healthUpdatedEvent:Disconnect();

    end;

  end, {props.contestant});

  return React.createElement("Frame", {
    Size = UDim2.new(1, 0, 0.1, 0);
    BackgroundColor3 = Color3.new(1, 1, 1);
    BackgroundTransparency = 0.7;
    BorderSizePixel = 0;
    LayoutOrder = 2;
  }, {
    CurrentHealth = React.createElement("Frame", {
      Size = UDim2.new(sizeXScale, 0, 1, 0);
      BackgroundColor3 = Color3.new(1, 1, 1);
      BorderSizePixel = 0;
    })
  });

end

return HealthHeadBar;