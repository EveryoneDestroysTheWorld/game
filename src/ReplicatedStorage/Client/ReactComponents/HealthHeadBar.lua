--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local types = require(ReplicatedStorage.Client.Modules.SharedTypes);

type HealthHeadBar = {
  contestant: types.ClientContestant;
}

local function HealthHeadBar(props: HealthHeadBar)

  local contestant = props.contestant;

  local healthPercentage, setHealthPercentage = React.useState(1);

  React.useEffect(function()
  
    local function updateHealthPercentage()

      if contestant.currentHealth and contestant.baseHealth then

        setHealthPercentage(contestant.currentHealth / contestant.baseHealth);

      end;

    end;

    local onHealthUpdated = contestant.onHealthUpdated:Connect(updateHealthPercentage);

    return function()

      onHealthUpdated:Disconnect();

    end;

  end, {contestant});

  return React.createElement("Frame", {
    Size = UDim2.new(1, 0, 0.1, 0);
    BackgroundColor3 = Color3.new(1, 1, 1);
    BackgroundTransparency = 0.7;
    BorderSizePixel = 0;
    LayoutOrder = 2;
    Visible = healthPercentage < 1;
  }, {
    CurrentHealth = React.createElement("Frame", {
      Size = UDim2.new(healthPercentage, 0, 1, 0);
      BackgroundColor3 = Color3.new(1, 1, 1);
      BorderSizePixel = 0;
    })
  });

end

return HealthHeadBar;