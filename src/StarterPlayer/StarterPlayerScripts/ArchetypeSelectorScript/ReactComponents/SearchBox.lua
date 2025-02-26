--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local ContextActionService = game:GetService("ContextActionService");
local Fonts = require(ReplicatedStorage.Client.Modules.Fonts);

type RoundTimerProps = {
  value: string;
  onChange: (newValue: string) -> ();
}

local function SearchBox(properties: RoundTimerProps)

  local textBoxRef = React.useRef(nil :: TextBox?);

  React.useEffect(function()

    local function toggleSearchBar(actionName, inputState: Enum.UserInputState)

      if inputState == Enum.UserInputState.Begin and textBoxRef.current and not textBoxRef.current:IsFocused() then

        task.wait();
        textBoxRef.current:CaptureFocus();

      end;

    end;

    ContextActionService:BindAction("ToggleSearchBar", toggleSearchBar, false, Enum.KeyCode.Slash);

    return function()

      ContextActionService:UnbindAction("ToggleSearchBar");

    end;

  end, {});

  local function refresh()

    if textBoxRef.current then

      properties.onChange(textBoxRef.current.Text);

    end;

  end;

  return React.createElement("TextBox", {
    BackgroundColor3 = Color3.new();
    BorderSizePixel = 0;
    AutomaticSize = Enum.AutomaticSize.Y;
    Size = UDim2.new(1, 0, 0, 30);
    PlaceholderText = "Press / and type to search for an archetype";
    ref = textBoxRef;
    Text = "";
    ClearTextOnFocus = false;
    TextColor3 = Color3.new(1, 1, 1);
    TextXAlignment = Enum.TextXAlignment.Left;
    LayoutOrder = 1;
    FontFace = Fonts.Regular;
    TextSize = 14;
    PlaceholderColor3 = Color3.fromRGB(204, 204, 204);
    [React.Change.Text] = refresh;
  }, {
    UIPadding = React.createElement("UIPadding", {
      PaddingLeft = UDim.new(0, 15);
      PaddingRight = UDim.new(0, 15);
    });
    UISizeConstraint = React.createElement("UISizeConstraint", {
      MaxSize = Vector2.new(700, math.huge);
    });
  });

end;

return SearchBox;