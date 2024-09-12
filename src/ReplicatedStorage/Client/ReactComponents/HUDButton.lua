--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local UserInputService = game:GetService("UserInputService");
local useResponsiveDesign = require(ReplicatedStorage.Client.ReactHooks.useResponsiveDesign);
local CircleUICorner = require(script.Parent.CircleUICorner);

type HUDButtonProps = {
  type: "Action" | "Item";
  onActivate: () -> ();
  shortcutCharacter: string;
  iconImage: string?;
}

local function HUDButton(props: HUDButtonProps)

  local isKeyboardEnabled, setIsKeyboardEnabled = React.useState(false);

  local function onActivate()

    props.onActivate();

  end;

  React.useEffect(function()
  
    UserInputService:GetPropertyChangedSignal("KeyboardEnabled"):Connect(function()
    
      setIsKeyboardEnabled(isKeyboardEnabled);

    end);

  end, {});

  local shouldUseFullSize = useResponsiveDesign({minimumWidth = 600});

  return React.createElement("TextButton", {
    [React.Event.Activated] = onActivate;
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.XY;
    Text = "";
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 5);
      HorizontalAlignment = Enum.HorizontalAlignment.Center;
      VerticalFlex = Enum.UIFlexAlignment.SpaceBetween;
    });
    IconContainerButton = React.createElement("TextButton", {
      [React.Event.Activated] = onActivate;
      AnchorPoint = Vector2.new(0.5, 0.5);
      BackgroundTransparency = 0.4;
      BackgroundColor3 = Color3.new(0, 0, 0);
      BorderSizePixel = 0;
      Text = "";
      Position = UDim2.new(0.5, 0, 0.5, 0);
      Size = UDim2.new(0, if shouldUseFullSize then 50 else 15, 0, if shouldUseFullSize then 50 else 15);
    }, {
      UIStroke = React.createElement("UIStroke", {
        Color = Color3.fromRGB(204, 204, 204);
        Thickness = 1;
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        Transparency = 0.4;
      });
      UICorner = if props.type == "Action" then React.createElement(CircleUICorner) else nil;
      IconImageLabel = if props.iconImage then React.createElement("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5);
        Position = UDim2.new(0.5, 0, 0.5, 0);
        Size = UDim2.new(1, if shouldUseFullSize then -10 else -5, 1, if shouldUseFullSize then -10 else -5);
        BackgroundTransparency = 1;
        Image = props.iconImage;
      }) else nil;
    });
    -- ShortcutCharacterLabel = if props.shortcutCharacter then React.createElement("TextLabel", {
    --   BackgroundTransparency = 1;
    --   LayoutOrder = 2;
    --   TextColor3 = Color3.new(1, 1, 1);
    --   TextSize = 14;
    --   Text = props.shortcutCharacter;
    --   FontFace = Font.fromId(11702779517, Enum.FontWeight.Bold);
    --   AutomaticSize = Enum.AutomaticSize.XY;
    -- }) else nil;
  });

end;

return HUDButton;