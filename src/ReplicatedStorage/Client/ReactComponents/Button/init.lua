--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local Colors = require(ReplicatedStorage.Client.Colors);

type ButtonProps = {
  text: string; 
  type: "Primary" | "Secondary" | "Danger";
  onClick: () -> (); 
  isDisabled: boolean?; 
  LayoutOrder: number;
};

local function Button(props: ButtonProps)

  return React.createElement("TextButton", {
    Text = props.text:upper();
    BackgroundColor3 = if props.isDisabled then Colors.DisabledButton else Colors.DemoDemonsOrange;
    TextColor3 = Colors.ButtonText;
    AutoButtonColor = not props.isDisabled;
    LayoutOrder = props.LayoutOrder;
    Active = not props.isDisabled;
    AutomaticSize = Enum.AutomaticSize.XY;
    FontFace = Font.fromId(11702779517, Enum.FontWeight.SemiBold);
    BackgroundTransparency = 0.1;
    TextSize = 14;
    [React.Event.Activated] = if props.isDisabled then nil else function()

      props.onClick();

    end;
  }, {
    UIPadding = React.createElement("UIPadding", {
      PaddingLeft = UDim.new(0, 15);
      PaddingRight = UDim.new(0, 15);
      PaddingTop = UDim.new(0, 7);
      PaddingBottom = UDim.new(0, 7);
    });
    UICorner = React.createElement("UICorner", {
      CornerRadius = UDim.new(1, 0);
    });
  });

end

return Button;