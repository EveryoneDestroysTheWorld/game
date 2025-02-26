--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local React = require(ReplicatedStorage.Shared.Packages.react);

type HealthHeadBar = {
  contestantID: number;
  roundID: string;
}

local function HealthHeadBar(props: HealthHeadBar)

  local healthPercentage, setHealthPercentage = React.useState(1);

  React.useEffect(function()
  
    -- TODO: Fix this
    local function updateHealthPercentage(currentHealth: number, baseHealth: number)

      setHealthPercentage(currentHealth / baseHealth);

    end;

    local function verifyEvent(roundID: string, contestantID: number, newHealthData)

      if roundID == props.roundID and contestantID == props.contestantID then

        updateHealthPercentage(newHealthData.currentHealth, newHealthData.baseHealth)

      end;

    end;

    local onHealthUpdated = ReplicatedStorage.Shared.Events.HealthUpdated:Connect(verifyEvent);

    return function()

      onHealthUpdated:Disconnect();

    end;

  end, {props.contestantID :: unknown, props.roundID});

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