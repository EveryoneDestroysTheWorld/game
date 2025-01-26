--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ContextActionService = game:GetService("ContextActionService");

local types = require(script.Parent.types);
local React = require(ReplicatedStorage.Shared.Packages.react);

local function KeyboardButton(properties: {
  Image: string;
  LayoutOrder: number;
  onActivated: () -> ();
})

  return React.createElement("TextButton", {
    Size = UDim2.new(0, 20, 0, 20);
    BackgroundColor3 = Color3.fromRGB(17, 20, 42);
    BackgroundTransparency = 0.6;
    BorderSizePixel = 0;
    LayoutOrder = properties.LayoutOrder;
    Text = "";
    [React.Event.Activated] = function()

      properties.onActivated();

    end;
  }, {
    ImageLabel = React.createElement("ImageLabel", {
      Image = properties.Image;
      Size = UDim2.new(1, 0, 1, 0);
      BackgroundTransparency = 1;
    });
    UICorner = React.createElement("UICorner", {
      CornerRadius = UDim.new(0, 5);
    });
  });

end;

local function QuickSelectionMenu(properties: types.ControlGuideProperties)

  local function moveSelection(direction: "Left" | "Right")

    if properties.selectedOption then

      -- Get the current index.
      local currentOptionIndex: number?;
      for index, option in properties.options do

        if option.key == properties.selectedOption.key then

          currentOptionIndex = index;

        end;

      end;

      assert(currentOptionIndex);

      if direction == "Left" and currentOptionIndex - 1 > 0 then

        properties.onSelectionChanged(properties.options[currentOptionIndex - 1])

      elseif direction == "Right" and currentOptionIndex + 1 <= #properties.options then

        properties.onSelectionChanged(properties.options[currentOptionIndex + 1])
        
      end;

    end;

  end;

  React.useEffect(function()

    local function checkSelection(actionName: string, inputState: Enum.UserInputState): ()

      if inputState == Enum.UserInputState.Begin then

        moveSelection(if actionName == "MoveSelectionLeft" then "Left" else "Right");

      end;

    end;
  
    ContextActionService:BindAction("MoveSelectionLeft", checkSelection, false, Enum.KeyCode.Left);
    ContextActionService:BindAction("MoveSelectionRight", checkSelection, false, Enum.KeyCode.Right);

    return function()

      ContextActionService:UnbindAction("MoveSelectionLeft");
      ContextActionService:UnbindAction("MoveSelectionRight");

    end;

  end, {properties.selectedOption :: unknown, properties.options});

  return React.createElement("Frame", {
    AutomaticSize = Enum.AutomaticSize.XY;
    BackgroundTransparency = 1;
    LayoutOrder = 4;
  }, {
    -- TODO: Implement specific control guides for mobile devices and game controllers
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      FillDirection = Enum.FillDirection.Horizontal;
      Padding = UDim.new(0, 5);
    });
    LeftButton = React.createElement(KeyboardButton, {
      Image = "rbxassetid://102551290838815";
      LayoutOrder = 1;
      onActivated = function()

        moveSelection("Left");
        
      end;
    });
    RightButton = React.createElement(KeyboardButton, {
      Image = "rbxassetid://88442502338263";
      LayoutOrder = 2;
      onActivated = function()

        moveSelection("Right")

      end;
    });
  });

end;

return QuickSelectionMenu;