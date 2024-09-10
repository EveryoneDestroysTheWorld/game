--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local dataTypeTween = require(ReplicatedStorage.Client.Classes.DataTypeTween);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local useResponsiveDesign = require(ReplicatedStorage.Client.ReactHooks.useResponsiveDesign);

type TeammateCardListProps = {
  layoutOrder: number;
  children: any;
  shouldHide: boolean?;
  round: ClientRound;
}

local function TeammateCardList(props: TeammateCardListProps)

  local containerRef = React.useRef(nil :: GuiObject?);
  React.useEffect(function(): ()

    if props.round then

      local function checkStatus()

        if props.round.status == "Matchup preview" then

          task.delay(5, function()

            local container = containerRef.current;
            if container then

              local tween = dataTypeTween({
                type = "Number";
                goalValue = if props.layoutOrder == 1 then -25 else 25;
                initialValue = container.Position.X.Offset;
                tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut);
                onChange = function(newValue: number)
      
                  -- Using containerRef just in case the type of element changes.
                  container = containerRef.current;
                  if container then
      
                    container.Position = UDim2.new(container.Position.X.Scale, newValue, container.Position.Y.Scale, container.Position.Y.Offset);
      
                  end;
      
                end;
              });
      
              tween:Play();

            end;

          end);

        end;

      end;

      local event = props.round.onStatusChanged:Connect(checkStatus);

      checkStatus();

      return function()

        event:Disconnect();
  
      end;
    
    end;

  end, {props.round});

  local hiddenValue = 250 + 15;

  React.useEffect(function()
  
    local container = containerRef.current;
    if container then

      container.Position = UDim2.new(1, if props.shouldHide then hiddenValue else 0, 0.5, 0);

    end;
    
  end, {});

  React.useEffect(function(): ()
  
    local container = containerRef.current;
    if container and props.layoutOrder == 1 then 
      
      container.Position = UDim2.new(0, 0, 0.5, 0);
    
    elseif props.layoutOrder == 2 then 

      if container then

        local tween = dataTypeTween({
          type = "Number";
          goalValue = if props.shouldHide then hiddenValue else 0;
          initialValue = container.Position.X.Offset;
          tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut);
          onChange = function(newValue: number)

            -- Using containerRef just in case the type of element changes.
            container = containerRef.current;
            if container then

              container.Position = UDim2.new(container.Position.X.Scale, newValue, container.Position.Y.Scale, container.Position.Y.Offset);

            end;

          end;
        });

        tween:Play();

        return function()
  
          tween:Cancel();
    
        end;

      end;

    end;

  end, {props.shouldHide :: any, props.layoutOrder});

  local shouldUseMaximumSpacing = useResponsiveDesign({minimumHeight = 300});

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(if props.layoutOrder == 1 then 0 else 1, 0.5);
    AutomaticSize = Enum.AutomaticSize.XY;
    ref = containerRef;
    BackgroundTransparency = 1;
    Size = UDim2.new();
    LayoutOrder = props.layoutOrder;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, if shouldUseMaximumSpacing then 15 else 1);
      HorizontalAlignment = if props.layoutOrder == 2 then Enum.HorizontalAlignment.Right else nil;
    });
    Children = React.createElement(React.Fragment, {}, props.children);
  })

end;

return TeammateCardList;