--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local dataTypeTween = require(ReplicatedStorage.Client.Classes.DataTypeTween);

type TeammateCardListProps = {
  layoutOrder: number;
  children: any;
  shouldHide: boolean?;
}

local function TeammateCardList(props: TeammateCardListProps)

  local isTweening, setIsTweening = React.useState(false);
  local containerRef = React.useRef(nil :: GuiObject?);
  local finalTweenedPosition, setFinalTweenedPosition = React.useState(nil :: UDim2?);
  React.useEffect(function(): ()
  
    if props.layoutOrder == 2 then 

      local container = containerRef.current;
      if container then

        setIsTweening(true);
        local position;
        local tween = dataTypeTween({
          type = "Number";
          goalValue = if props.shouldHide then 300 else 0;
          initialValue = container.Position.X.Offset;
          tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut);
          onChange = function(newValue: number)

            -- Using containerRef just in case the type of element changes.
            container = containerRef.current;
            if container then

              container.Position = UDim2.new(1, newValue, 0.5, 0);
              position = container.Position;
              if container:IsA("CanvasGroup") then

                container.GroupTransparency = newValue / 300;

              end;

            end;

          end;
        });
        
        tween.Completed:Once(function()
        
          setFinalTweenedPosition(position);
          setIsTweening(false);

        end);

        tween:Play()

        return function()
  
          tween:Cancel();
    
        end;

      end;

    end;

  end, {props.shouldHide :: any, props.layoutOrder});

  return React.createElement(if isTweening then "CanvasGroup" else "Frame", {
    AnchorPoint = Vector2.new(if props.layoutOrder == 1 then 0 else 1, 0.5);
    AutomaticSize = Enum.AutomaticSize.XY;
    ref = containerRef;
    Position = if props.layoutOrder == 1 then UDim2.new(0, 0, 0.5, 0) elseif finalTweenedPosition and not isTweening then finalTweenedPosition else nil;
    BackgroundTransparency = 1;
    Size = UDim2.new();
    LayoutOrder = props.layoutOrder;
  }, {
    React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 1);
      HorizontalAlignment = if props.layoutOrder == 2 then Enum.HorizontalAlignment.Right else nil;
    });
    React.createElement(React.Fragment, {}, props.children);
  })

end;

return TeammateCardList;