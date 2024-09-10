--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

local function ActionButtonContainer()

  local actionButtons, setActionButtons = React.useState({});

  React.useEffect(function()
  
    ReplicatedStorage.Client.Functions.AddActionButton.OnInvoke = function(actionButton)

      setActionButtons(function(actionButtons)
      
        local newActionButtons = table.clone(actionButtons);
        table.insert(newActionButtons, actionButton);
        return newActionButtons;

      end);

    end;

  end, {});

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(1, 1);
    Position = UDim2.new(1, -15, 1, -15);
    Size = UDim2.new(0, 0, 0, 0);
    AutomaticSize = Enum.AutomaticSize.XY;
    BackgroundTransparency = 1;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      Padding = UDim.new(0, 5);
      FillDirection = Enum.FillDirection.Horizontal;
    });
    ActionButtonList = React.createElement(React.Fragment, {}, actionButtons);
  });

end;

return ActionButtonContainer;