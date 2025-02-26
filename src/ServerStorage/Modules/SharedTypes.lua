--!strict

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Profile = require(ServerStorage.Packages.Profile);
local Stage = require(ServerStorage.Packages.Stage);

export type AggressiveAutopilot = AggressiveAutopilotProperties & AggressiveAutopilotMethods;

export type AggressiveAutopilotProperties = {
  contestant: ServerContestant;
  name: string;
  id: string;
  events: {RBXScriptConnection};
  rivalForgivenessMaxDelaySeconds: number;
  rivalForgivenessMinDelaySeconds: number;
  rivalContestantID: number?;
  rivalDeclaredSeconds: number?;
}

export type AggressiveAutopilotConstructorProperties = {
  contestant: ServerContestant;
}

export type AggressiveAutopilotMethods = {
  run: (self: AggressiveAutopilot) -> ();
}

export type Autopilot<Properties = AutopilotProperties, Methods = AutopilotMethods> = Properties & Methods;

export type AutopilotClass<AutopilotConstructorProperties = any, ExtendedAutopilot = any> = AutopilotProperties & {
  new: (...AutopilotConstructorProperties) -> ExtendedAutopilot & Autopilot
}

export type AutopilotFactory = {
  get: (
    ((effectID: "Aggressive") -> AutopilotClass<AggressiveAutopilotConstructorProperties, AggressiveAutopilot>)
    & ((effectID: string) -> AutopilotClass)
  );
  random: () -> AutopilotClass;
}

export type AutopilotProperties = {
  id: string;
  name: string;
}

export type AutopilotMethods = {
  run: (self: any) -> ();
}

export type BallType = "Explosive" | "Electric" | "Poison" | "Regular";

export type BatterUpDemonModes = "Batter" | "Pitcher";

export type BatterUpDemonServerArchetype = ServerArchetype<BatterUpDemonServerArchetypeProperties & BatterUpDemonServerArchetypeMethods>;

export type BatterUpDemonServerArchetypeProperties = {
  contestant: ServerContestant;
  ragdollClone: Model?;
  events: {RBXScriptConnection};
  isContestantDowned: boolean;
  type: ArchetypeType;
};

export type BatterUpDemonServerArchetypeConstructorProperties = {
  contestant: ServerContestant;
}

export type BatterUpDemonServerArchetypeMethods = {
  
};

export type HeresThePitchServerAction = ServerAction<{
  contestant: ServerContestant;
  collisionGroupName: string;
  bindableFunction: BindableFunction;
  remoteFunction: RemoteFunction?;
  balls: {Instance};
  activate: (self: HeresThePitchServerAction, coordinates: Vector3) -> ();
  breakdown: (self: HeresThePitchServerAction) -> ();
}>;

export type DetachLimbServerAction = ServerAction<{
  contestant: ServerContestant;
  detachedLimbs: {
    [string]: BasePart | Model
  };
  bindableFunction: BindableFunction;
  remoteFunction: RemoteFunction?;
}>;

export type DiveBombServerAction = ServerAction<{
  contestant: ServerContestant;
  anims: {
    [string]: AnimationTrack;
  };
  remoteFunction: RemoteFunction?;
}>;

export type DetonateDetachedLimbsServerAction = ServerAction<{
  contestant: ServerContestant;
  bindableFunction: BindableFunction;
  remoteFunction: RemoteFunction?;
  activate: (self: DetonateDetachedLimbsServerAction) -> ();
  breakdown: (self: DetonateDetachedLimbsServerAction) -> ();
}>;

export type ExplosivePunchServerAction = ServerAction<{
  contestant: ServerContestant;
  bindableFunction: BindableFunction;
  remoteFunction: RemoteFunction?;
  minimumRequiredStamina: number;
  latestActivationTimes: {number};
  currentAnimationTrack: AnimationTrack?;
  explosiveParts: {BasePart};
  activate: (self: ExplosivePunchServerAction) -> ();
  breakdown: (self: ExplosivePunchServerAction) -> ();
}>;

export type RocketFeetServerAction = ServerAction<{
  contestant: ServerContestant;
  bindableFunction: BindableFunction;
  remoteFunction: RemoteFunction?;
  minimumRequiredStamina: number;
  latestActivationTimes: {number};
  currentAnimationTrack: AnimationTrack?;
  leftFootExplosivePart: BasePart;
  rightFootExplosivePart: BasePart;
  activate: (self: RocketFeetServerAction) -> ();
  breakdown: (self: RocketFeetServerAction) -> ();
}>;

export type FireBeamServerAction = ServerAction<{
  contestant: ServerContestant;
  startChargeTimeMilliseconds: number?;
  maxChargeDurationMilliseconds: number;
  coordinates: Vector3?;
  bindableFunction: BindableFunction;
  remoteFunction: RemoteFunction?;
  remoteEvent: RemoteEvent?;
  charge: number;
}>;

export type LockOnServerAction = ServerAction<{
  contestant: ServerContestant;
  previousTargets: {Instance};
  remoteEvent: RemoteEvent?;
  activate: (self: LockOnServerAction, shouldReleaseLock: boolean?) -> ();
  breakdown: (self: LockOnServerAction) -> ();
}>;

export type TakeFlightServerAction = ServerAction<{
  contestant: ServerContestant;
  remoteFunction: RemoteFunction?;
  animationTracks: {
    [string]: AnimationTrack;
  };
  linearVelocity: LinearVelocity?;
  activate: (self: TakeFlightServerAction) -> boolean;
  breakdown: (self: TakeFlightServerAction) -> ();
}>;

export type TarBombServerAction = ServerAction<{
  contestant: ServerContestant;
  coordinates: Vector3?;
  remoteEvent: RemoteEvent?;
  remoteFunction: RemoteFunction?;
  animationTracks: {
    [string]: AnimationTrack;
  };
  startChargeTimeMilliseconds: number?;
  maxChargeDurationMilliseconds: number;
  activate: (self: TarBombServerAction, shouldCharge: boolean, coordinates: Vector3?, shouldUseTarget: boolean?, shouldBypassStaminaCheck: boolean?) -> ();
  breakdown: (self: TarBombServerAction) -> ();
}>;

export type DefaultServerArchetype = ServerArchetype<DefaultServerArchetypeProperties & DefaultServerArchetypeMethods>;

export type DefaultServerArchetypeProperties = {
  events: {RBXScriptConnection};
  contestant: ServerContestant;
  isContestantDowned: boolean;
  ragdollClone: Model?;
}

export type DefaultServerArchetypeMethods = {

}

export type DraconicKnightServerArchetype = ServerArchetype<DraconicKnightServerArchetypeProperties & DraconicKnightServerArchetypeMethods>;

export type DraconicKnightServerArchetypeProperties = {
  contestant: ServerContestant;
  ragdollClone: Model?;
  events: {RBXScriptConnection};
  roughArmorEffect: RoughArmorServerEffect;
  wingProp: Model?;
};

export type DraconicKnightServerArchetypeConstructorProperties = {
  contestant: ServerContestant;
}

export type DraconicKnightServerArchetypeMethods = {
  
};

export type ExplosiveMimicServerArchetype = ServerArchetype<ExplosiveMimicServerArchetypeProperties & ExplosiveMimicServerArchetypeMethods>;

export type ExplosiveMimicServerArchetypeProperties = {
  contestant: ServerContestant;
  events: {RBXScriptConnection};
};

export type ExplosiveMimicServerArchetypeConstructorProperties = {
  contestant: ServerContestant;
  round: ServerRound;
}

export type ExplosiveMimicServerArchetypeMethods = {
  breakdown: (self: ExplosiveMimicServerArchetype) -> ();
};

export type UndeadConsciousnessServerArchetype = ServerArchetype<UndeadConsciousnessServerArchetypeProperties & UndeadConsciousnessServerArchetypeMethods>;

export type UndeadConsciousnessServerArchetypeProperties = {
  contestant: ServerContestant;
  ragdollClone: Model?;
  round: ServerRound;
  events: {RBXScriptConnection};
  undeadEffect: UndeadServerEffect;
};

export type UndeadConsciousnessServerArchetypeConstructorProperties = {
  contestant: ServerContestant;
  round: ServerRound;
}

export type UndeadConsciousnessServerArchetypeMethods = {
  
};

export type Cause = {
  contestantID: number?; 
  actionID: string?; 
  archetypeID: string?;
  itemID: string?;
  effectID: string?;
};

export type HoldingHeavyItemServerEffect = ServerEffect<HoldingHeavyItemServerEffectProperties & HoldingHeavyItemServerEffectMethods>;

export type HoldingHeavyItemServerEffectProperties = {
  lock: unknown;
  contestant: ServerContestant;
}

export type HoldingHeavyItemServerEffectMethods = {
  activate: (self: HoldingHeavyItemServerEffect) -> ();
  breakdown: (self: HoldingHeavyItemServerEffect) -> ();
}

export type RegenerationServerEffectProperties = {
  contestant: ServerContestant;
  rateSeconds: number;
  maxRegenerations: number;
  shouldRegenerate: boolean;
}

export type RegenerationServerEffect = ServerEffect<RegenerationServerEffectProperties & RegenerationServerEffectMethods>;

export type ServerEffectConstructorProperties = {
  contestant: ServerContestant;
};

export type RegenerationServerEffectMethods = {
  activate: (self: RegenerationServerEffect) -> ();
  breakdown: (self: RegenerationServerEffect) -> ();
}

export type UndeadServerEffectProperties = {
  events: {
    [unknown]: RBXScriptConnection
  };
  contestant: ServerContestant;
  walkSpeedWeight: WalkSpeedWeight;
};

export type UndeadServerEffectMethods = {
  activate: (self: UndeadServerEffect) -> ();
  breakdown: (self: UndeadServerEffect) -> ();
};

export type UndeadServerEffect = ServerEffect<UndeadServerEffectProperties & UndeadServerEffectMethods>;

export type RoughArmorServerEffectProperties = {
  events: {
    [unknown]: RBXScriptConnection
  };
  contestant: ServerContestant;
  baseHealthModifier: BaseModifier;
}

export type RoughArmorServerEffectMethods = {
  activate: (self: RoughArmorServerEffect) -> ();
  breakdown: (self: RoughArmorServerEffect) -> ();
};

export type RoughArmorServerEffect = ServerEffect<RoughArmorServerEffectProperties & RoughArmorServerEffectMethods>;

export type ParalysisServerEffectProperties = {
  name: string;
  id: string;
  weight: WalkSpeedWeight;
  contestant: ServerContestant;
  uniqueID: string;
  remoteFunction: RemoteFunction?;
  ragdollKey: {};
  frozenAnimations: {
    [AnimationTrack]: number;
  };
}

export type ParalysisServerEffect = ServerEffect<ParalysisServerEffectProperties & {
  activate: (self: ParalysisServerEffect) -> ();
  breakdown: (self: ParalysisServerEffect) -> ();
}>;

export type InvincibilityServerEffect = ServerEffect<{
  contestant: ServerContestant;
  expirationTimeMilliseconds: number?;
  updateContestantStamina: (self: InvincibilityServerEffect, newStamina: number, oldStamina: number) -> number;
  updateContestantHealth: (self: InvincibilityServerEffect, newHealth: number, oldHealth: number) -> number;
}>;

export type StunnedServerEffect = ServerEffect<{
  contestant: ServerContestant;
  activate: (self: StunnedServerEffect) -> ();
  breakdown: (self: StunnedServerEffect) -> ();
}>;

export type StrikeOutSwipeServerAction = ServerAction<{
  bat: BasePart;
  contestant: ServerContestant;
  remoteFunction: RemoteFunction?;
  startChargeTimeMilliseconds: number?;
  maxChargeDurationMilliseconds: number;
  requiredStamina: number;
  touchedEvent: RBXScriptConnection?;
  remoteEvent: RemoteEvent?;
  swingAnimation: AnimationTrack?;
  touchedExpirationTask: thread;
  touchedTimeLimitSeconds: number;
  baseDamage: number;
  maxBonusDamage: number;
  activate: (self: StrikeOutSwipeServerAction, shouldCharge: boolean) -> ();
  breakdown: (self: StrikeOutSwipeServerAction) -> ();
}>;

export type ServerContestantConstructorProperties = {
  id: number;
  round: ServerRound;
  name: string;
}

export type ServerItemProperties = {

  -- The ID of the item. Keep this unique.
  id: string;

  name: string;

  -- The description of the item. 
  description: string;

  -- The function to activate the item on the server side.
  -- You can manually activate the item some other way too.
  activate: (self: ServerItem, ...any) -> ();

  -- The function to "break down" the item. This usually runs after the round ends and sometimes after item use.
  -- You can manually break down the item some other way too.
  breakdown: (self: ServerItem, ...any) -> ();

  -- The function to initialize the item. This usually runs after the player receives an item. 
  -- This function does not mean the player activated the item. Use :activate() instead.
  initialize: (self: ServerItem, ...any) -> ();

};

export type ServerItemEvents = {

  -- Called when the item activates.
  onActivate: RBXScriptSignal<"Press" | "Hold">;

}

export type ServerItem = ServerItemProperties & ServerItemEvents;

return {};