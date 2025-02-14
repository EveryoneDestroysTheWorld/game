--!strict

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");
local UserInputService = game:GetService("UserInputService");

local React = require(ReplicatedStorage.Shared.Packages.react);
local CameraService = require(ReplicatedStorage.Client.Modules.CameraService);

local function VirtualController()

  local trackingEvent, setTrackingEvent = React.useState(nil);
  local touch: InputObject?, setTouch = React.useState(nil :: InputObject?);
  local distanceIndicatorCircleRef = React.useRef(nil :: Frame?);

  local player = Players.LocalPlayer;

  React.useEffect(function()

    local inputEndedEvent = UserInputService.InputEnded:Connect(function(input)
    
      if input == touch then

        -- Reset the touch.
        setTouch(nil);

        CameraService.virtualControllerTouch = nil;
        
        if trackingEvent then

          trackingEvent:Disconnect();
    
        end

        -- Reset the indicator.
        if distanceIndicatorCircleRef.current then

          TweenService:Create(distanceIndicatorCircleRef.current, TweenInfo.new(0.3, Enum.EasingStyle.Elastic), {
            Position = UDim2.new(0.5, 0, 0.5, 0);
          }):Play();

        end;

        -- Stop the player.
        local character = player.Character;
        local humanoid = if character then character:FindFirstChild("Humanoid") else nil;
        if humanoid and humanoid:IsA("Humanoid") then

          humanoid:Move(Vector3.zero);

        end

      end;

    end);

    return function()

      inputEndedEvent:Disconnect();

    end;

  end, {touch});

  return React.createElement("TextButton", {
    AnchorPoint = Vector2.new(0, 1);
    BackgroundColor3 = Color3.new(0, 0, 0);
    BackgroundTransparency = 0.85;
    Position = UDim2.new(0, 30, 1, -30);
    Size = UDim2.new(0, 80, 0, 80);
    Text = "";
    [React.Event.InputBegan] = function(_, input: InputObject)

      if input.UserInputType == Enum.UserInputType.Touch and not touch then

        setTouch(input);

        if trackingEvent then

          trackingEvent:Disconnect();
    
        end

        CameraService.virtualControllerTouch = input;

        local originalCursorPosition = Vector2.new(input.Position.X, input.Position.Y);

        setTrackingEvent(
          UserInputService.TouchMoved:Connect(function(modifiedTouch: InputObject)

            if modifiedTouch == input then
        
              -- Move the character.
              local xDiff = input.Position.X - originalCursorPosition.X;
              xDiff = if xDiff > 0 then math.min(xDiff, 22) else math.max(xDiff, -22);
              local yDiff = input.Position.Y - originalCursorPosition.Y;
              yDiff = if yDiff > 0 then math.min(yDiff, 22) else math.max(yDiff, -22);

              local character = player.Character;
              local humanoid = if character then character:FindFirstChild("Humanoid") else nil;
              if humanoid and humanoid:IsA("Humanoid") then
      
                humanoid:Move(Vector3.new(xDiff / 22, 0, yDiff / 22), true);
      
              end

              -- Reposition the indicator.
              if distanceIndicatorCircleRef.current then

                distanceIndicatorCircleRef.current.Position = UDim2.new(0.5, xDiff, 0.5, yDiff);

              end;
              
            end
          
          end)
        );

      end;

    end;
  }, {
    UICorner = React.createElement("UICorner", {
      CornerRadius = UDim.new(1, 0);
    });
    UIStroke = React.createElement("UIStroke", {
      Transparency = 0.8;
      Color = Color3.new(0, 0, 0);
      ApplyStrokeMode = "Border";
    });
    DistanceIndicatorCircle = React.createElement("Frame", {
      AnchorPoint = Vector2.new(0.5, 0.5);
      BackgroundColor3 = Color3.new(1, 1, 1);
      BackgroundTransparency = 0.3;
      Position = UDim2.new(0.5, 0, 0.5, 0);
      Size = UDim2.new(0.5, 0, 0.5, 0);
      ref = distanceIndicatorCircleRef;
    }, {
      UICorner = React.createElement("UICorner", {
        CornerRadius = UDim.new(1, 0);
      });
      UIStroke = React.createElement("UIStroke", {
        Transparency = 0.8;
        Thickness = 2;
        Color = Color3.new(0, 0, 0);
        ApplyStrokeMode = "Border";
      });
    });
  });

end;

return VirtualController;