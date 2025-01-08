--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local ContextActionService = game:GetService("ContextActionService");

type RoundTimerProps = {
  value: string;
  onChange: (newValue: string) -> ();
}

local function SearchBox(properties: RoundTimerProps)

  local textBoxRef = React.useRef(nil :: TextBox?);

  React.useEffect(function()

    local function toggleSearchBar(actionName, inputState: Enum.UserInputState)

      if inputState == Enum.UserInputState.Begin and textBoxRef.current and not textBoxRef.current:IsFocused() then

        textBoxRef.current:CaptureFocus();

      end;

    end;

    ContextActionService:BindAction("ToggleSearchBar", toggleSearchBar, false, Enum.KeyCode.Slash);

    return function()

      ContextActionService:UnbindAction("ToggleSearchBar");

    end;

  end, {});

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(0.5, 1);
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.Y;
    Position = UDim2.new(0.5, 0, 1, -30);
    Size = UDim2.new(0, 200, 0, 0);
  }, {
    TextBox = React.createElement("TextBox", {
      [React.Event.InputBegan] = function()

        if textBoxRef.current then

          properties.onChange(textBoxRef.current.Text);

        end;

      end;
      ref = textBoxRef;
    })
  });

end;

return SearchBox;