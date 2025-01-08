--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ContextActionService = game:GetService("ContextActionService");

export type SearchResultButtonProperties = {
  onActivate: () -> ();
  isSelected: boolean;
}

local function SearchResultButton(properties: SearchResultButtonProperties)

  React.useEffect(function(): ()
  
    if properties.isSelected then

      local function selectResult(actionName: string, inputState: Enum.UserInputState)

        if inputState == Enum.UserInputState.Begin then

          properties.onActivate();

        end;

      end;

      ContextActionService:BindAction("SelectResult", selectResult, false, Enum.KeyCode.Return, Enum.KeyCode.KeypadEnter);

      return function()

        ContextActionService:UnbindAction("SelectResult");

      end;

    end;

  end, {properties.isSelected});

  return React.createElement("TextButton", {
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.Y;
    Size = UDim2.new(1, 0, 0, 0);
    Text = ""
  }, {
    TopSection = React.createElement("Frame", {
      AutomaticSize = Enum.AutomaticSize.Y;
      BorderSizePixel = 0;
      Size = UDim2.new(1, 0, 0, 30);
    }, {
      TitleLabel = React.createElement("TextLabel", {
        
      });
      DescriptionLabel = React.createElement("TextLabel");
    });
    BottomSection = React.createElement("Frame", {
      AutomaticSize = Enum.AutomaticSize.Y;
      Size = UDim2.new(1, 0, 0, 0);
    });
  });

end;

return SearchResultButton;