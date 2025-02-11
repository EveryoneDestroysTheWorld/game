--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

export type RagdollData = {
  keys: {any};
  createdInstances: {Instance};
  motor6Ds: {Motor6D};
  humanoid: Humanoid?;
}

export type RagdollService = {
  ragdolls: {
    [Model]: RagdollData?;
  };
  ragdollCharacter: (self: RagdollService, character: Model, key: any, player: Player?) -> ();
  restoreCharacter: (self: RagdollService, character: Model, key: any, player: Player?) -> ();
}

local RagdollService: RagdollService = {
  ragdolls = {};
} :: RagdollService;

function RagdollService:ragdollCharacter(character: Model, key: any, player: Player?)

  local existingRagdollData = RagdollService.ragdolls[character];
  if existingRagdollData then

    table.insert(existingRagdollData.keys, key);

  else

    RagdollService.ragdolls[character] = {
      keys = {key};
      createdInstances = {};
      motor6Ds = {};
    };

    local newRagdollData = RagdollService.ragdolls[character] :: RagdollData;
    
    if player then

      ReplicatedStorage.Shared.Functions.ToggleAnimateScript:InvokeClient(player, false);

    end;

    for _, instance in character:GetDescendants() do

      if instance:IsA("Motor6D") and instance.Name ~= "Root" then

        local socket = Instance.new("BallSocketConstraint");
        local attachment1 = Instance.new("Attachment");
        local attachment2 = Instance.new("Attachment");
        socket.Attachment0 = attachment1
        socket.Attachment1 = attachment2
        socket.LimitsEnabled = true
        socket.TwistLimitsEnabled = true
        attachment1.CFrame = instance.C0
        attachment2.CFrame = instance.C1
        attachment1.Parent = instance.Part0
        attachment2.Parent = instance.Part1
        socket.Parent = instance.Parent
        instance.Enabled = false;

        table.insert(newRagdollData.createdInstances, socket);
        table.insert(newRagdollData.createdInstances, attachment1);
        table.insert(newRagdollData.createdInstances, attachment2);

        table.insert(newRagdollData.motor6Ds, instance);

      elseif instance:IsA("Humanoid") then

        if player then

          ReplicatedStorage.Shared.Functions.ChangeHumanoidState:InvokeClient(player, Enum.HumanoidStateType.Physics);

        else

          instance:ChangeState(Enum.HumanoidStateType.Physics);
          newRagdollData.humanoid = instance;

        end;

      end;
    
    end;

  end;

end;

function RagdollService:restoreCharacter(character: Model, key: any, player: Player?)

  local ragdollData = RagdollService.ragdolls[character];
  if ragdollData then

    local keyIndex = table.find(ragdollData.keys, key);
    if keyIndex then

      table.remove(ragdollData.keys, keyIndex);

    end;

    if #ragdollData.keys <= 0 then

      for _, motor6D in ragdollData.motor6Ds do

        motor6D.Enabled = true;

      end;

      for _, createdInstance in ragdollData.createdInstances do

        createdInstance:Destroy();

      end;

      if ragdollData.humanoid then

        ragdollData.humanoid:ChangeState(Enum.HumanoidStateType.Freefall);

      end;

      if player then

        ReplicatedStorage.Shared.Functions.ChangeHumanoidState:InvokeClient(player, Enum.HumanoidStateType.Freefall);
        ReplicatedStorage.Shared.Functions.ToggleAnimateScript:InvokeClient(player, true);

      end;

      RagdollService.ragdolls[character] = nil;

    end;

  end;

end;

return RagdollService;