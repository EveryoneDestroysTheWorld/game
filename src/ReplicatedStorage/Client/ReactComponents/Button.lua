--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local Colors = require(ReplicatedStorage.Client.Colors);
local useResponsiveDesign = require(ReplicatedStorage.Client.ReactHooks.useResponsiveDesign);

type ButtonProps = {
  text: string; 
  type: "Primary" | "Secondary" | "Danger";
  onClick: () -> (); 
  isDisabled: boolean?; 
  LayoutOrder: number;
  TextTransparency: number?;
  BackgroundTransparency: number?;
  AnchorPoint: Vector2?;
  Visible: boolean?;
  Position: UDim2?;
  textSize: number?
};

local function Button(props: ButtonProps)

  local shouldUseFullPadding = useResponsiveDesign({minimumWidth = 700});

  return React.createElement("TextButton", {
    Text = props.text:upper();
    BackgroundColor3 = if props.isDisabled then Colors.DisabledButton else Colors.DemoDemonsOrange;
    TextColor3 = Colors.ButtonText;
    AutoButtonColor = not props.isDisabled;
    BackgroundTransparency = props.BackgroundTransparency;
    TextTransparency = props.TextTransparency;
    LayoutOrder = props.LayoutOrder;
    Active = not props.isDisabled;
    AutomaticSize = Enum.AutomaticSize.XY;
    FontFace = Font.fromId(11702779517, Enum.FontWeight.SemiBold);
    Position = props.Position;
    AnchorPoint = props.AnchorPoint;
    Visible = props.Visible;
    TextSize = props.textSize or 14;
    [React.Event.Activated] = if props.isDisabled then nil else function()

      props.onClick();

    end;
  }, {
    UIPadding = React.createElement("UIPadding", {
      PaddingLeft = UDim.new(0, if shouldUseFullPadding then 15 else 7);
      PaddingRight = UDim.new(0, if shouldUseFullPadding then 15 else 7);
      PaddingTop = UDim.new(0, if shouldUseFullPadding then 7 else 5);
      PaddingBottom = UDim.new(0, if shouldUseFullPadding then 7 else 5);
    });
    UICorner = React.createElement("UICorner", {
      CornerRadius = UDim.new(1, 0);
    });
  });

end

return Button;