--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;

local types = require(ReplicatedStorage.Client.Modules.SharedTypes);

type StatContainerProperties = {
  iconImage: string;
  contestant: types.ClientContestant;
  layoutOrder: number;
}

local function StatContainer(props: StatContainerProperties)

  local value, setValue = React.useState("--");

  React.useEffect(function()
  
    local event;

    if props.layoutOrder == 1 then

      event = props.contestant.onHealthUpdated:Connect(function()
      
        setValue(`{props.contestant.currentHealth}`);

      end);

      setValue(`{props.contestant.currentHealth}`);

    else

      event = props.contestant.onStaminaUpdated:Connect(function()
      
        setValue(`{props.contestant.currentStamina}`);

      end);

      setValue(`{props.contestant.currentStamina}`);

    end;

    return function()

      if event then

        event:Disconnect();

      end;

    end;

  end, {props.layoutOrder :: unknown, props.contestant});

  return React.createElement("Frame", {
    AutomaticSize = Enum.AutomaticSize.XY;
    Size = UDim2.new();
    BackgroundTransparency = 1;
    LayoutOrder = props.layoutOrder;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 5);
      FillDirection = Enum.FillDirection.Horizontal;
      VerticalAlignment = Enum.VerticalAlignment.Center;
    });
    ImageLabel = React.createElement("ImageLabel", {
      Size = UDim2.new(1, 0, 1, 0);
      SizeConstraint = Enum.SizeConstraint.RelativeYY;
      Image = props.iconImage;
      ImageTransparency = 0.4;
      BackgroundTransparency = 1;
      LayoutOrder = 1;
      ImageColor3 = Color3.new(1, 1, 1);
    });
    CurrentValueLabel = React.createElement("TextLabel", {
      BackgroundTransparency = 1;
      LayoutOrder = 2;
      Text = value;
      FontFace = Font.fromId(11702779517, Enum.FontWeight.Regular);
      TextSize = 14;
      AutomaticSize = Enum.AutomaticSize.XY;
      TextColor3 = Color3.new(1, 1, 1);
      Size = UDim2.new();
    });
  });

end;

return StatContainer;