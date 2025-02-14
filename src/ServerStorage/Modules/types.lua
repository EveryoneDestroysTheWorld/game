--!strict

local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Profile = require(ServerStorage.Packages.Profile);
local Stage = require(ServerStorage.Packages.Stage);

local TurfWarContestantStatistics = require(ReplicatedStorage.Shared.TurfWarContestantStatistics);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);

export type ServerContestant = ServerContestantProperties & ServerContestantEvents & ServerContestantMethods;

export type ServerContestantProperties = {
  
  -- This could be nil if the server hasn't assigned an archetype to the contestant yet.
  archetypeID: string?;

  -- The character reference of the contestant. This is here to easily reference characters of bot contestants.
  -- If the contestant is a player, this is the same value as player.Character.
  character: Model?;

  currentStamina: number;

  walkSpeedWeights: {WalkSpeedWeight};

  effects: {ServerEffect};

  round: ServerRound;

  -- The ID of the contestant. 
  -- If the contestant is a bot, this is a unique temporary ID assigned by the server. It will be an irrational number.
  -- If the contestant is a player, this is the same value as player.UserId. It will be an integer.
  id: number;

  -- The name of the contestant. This is here to easily reference bot names. 
  -- If the contestant is a player, this is the same value as player.DisplayName. To get the username, use player.Name.
  name: string;

  -- Is this contestant still a part of the game?
  isDisqualified: boolean;

  -- The player reference of the contestant. This should be nil if the contestant isn't a player.
  player: Player?;

  -- The profile of the contestant. This should be nil if the contestant isn't a player.
  profile: Profile.Profile?;

  -- The team ID of the contestant. This will be nil if the game rules call for a free-for-all.
  teamID: number?;

  items: {ServerItem};

  baseModifiers: {
    health: {BaseModifier};
    stamina: {BaseModifier};
  };

  currentHealth: number;

  baseHealth: number;

  baseStamina: number;

  statistics: TurfWarContestantStatistics.TurfWarContestantStatistics?;

  attributes: {
    [string]: unknown;
  };

  tags: {string};
  
}

export type ServerContestantMethods = {
  addWalkSpeedWeight: (self: ServerContestant, weight: WalkSpeedWeight) -> ();
  addBaseModifier: (self: ServerContestant, modifierType: BaseModifierType, modifier: BaseModifier) -> ();
  addItem: (self: ServerContestant, item: ServerItem) -> ();
  removeBaseModifier: (self: ServerContestant, modifierType: BaseModifierType, modifier: BaseModifier) -> ();
  removeWalkSpeedWeight: (self: ServerContestant, weight: WalkSpeedWeight) -> ();
  removeItem: (self: ServerContestant, item: ServerItem) -> ();
  refreshWalkSpeed: (self: ServerContestant) -> ();
  addEffect: (self: ServerContestant, effect: ServerEffect) -> ();
  removeEffect: (self: ServerContestant, effect: ServerEffect) -> ();
  convertToClient: (self: ServerContestant) -> {any};
  disqualify: (self: ServerContestant) -> ();
  getModifiedBaseValue: (self: ServerContestant, modifierType: BaseModifierType) -> number;
  getInventoryItemIDs: (self: ServerContestant) -> {string};
  updateArchetypeID: (self: ServerContestant, newArchetypeID: string) -> ();
  updateCharacter: (self: ServerContestant, newCharacter: Model?) -> ();
  updateInventory: (self: ServerContestant, newInventory: {ServerItem}) -> ();
  updateHealth: (self: ServerContestant, newHealth: number, cause: Cause?) -> ();
  updateStamina: (self: ServerContestant, newStamina: number, cause: Cause?) -> ();
  mergeStatistics: (self: ServerContestant, newStatistics: TurfWarContestantStatistics.PatchableContestantTurfWarStatistics, cause: Cause?) -> ();
  toString: (self: ServerContestant) -> string;
}

export type ServerContestantEvents = {
  onDisqualified: RBXScriptSignal;
  onArchetypeUpdated: RBXScriptSignal;
  onHealthUpdated: RBXScriptSignal<number, number, Cause?>;
  onStaminaUpdated: RBXScriptSignal<number, number, Cause?>;
  onInventoryUpdated: RBXScriptSignal<{number}>;
  onEffectsUpdated: RBXScriptSignal;
}

export type AggressiveAutopilot = AggressiveAutopilotProperties & AggressiveAutopilotMethods;

export type AggressiveAutopilotProperties = {
  safeSpaceTime: number?;
  contestant: ServerContestant;
  name: string;
  id: string;
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
  actions: {ServerAction};
};

export type BatterUpDemonServerArchetypeConstructorProperties = {
  contestant: ServerContestant;
}

export type BatterUpDemonServerArchetypeMethods = {
  
};

export type ChangeBallTypeServerAction = ServerAction<{
  contestant: ServerContestant;
  bindableFunction: BindableFunction;
  remoteFunction: RemoteFunction?;
  activate: (self: ChangeBallTypeServerAction, ballType: BallType) -> ();
  breakdown: (self: ChangeBallTypeServerAction) -> ();
}>;

export type ChangeModesServerAction = ServerAction<{
  contestant: ServerContestant;
  bindableFunction: BindableFunction;
  remoteFunction: RemoteFunction?;
  activate: (self: ChangeModesServerAction, mode: BatterUpDemonModes) -> ();
  breakdown: (self: ChangeModesServerAction) -> ();
}>;

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

export type BeastSlashServerAction = ServerAction<{
  contestant: ServerContestant;
  bindableFunction: BindableFunction;
  remoteFunction: RemoteFunction?;
  animationTracks: {
    [string]: AnimationTrack;
  };
  activate: (self: BeastSlashServerAction) -> ();
  breakdown: (self: BeastSlashServerAction) -> ();
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
  actions: {ServerAction}; 
};

export type DraconicKnightServerArchetypeConstructorProperties = {
  contestant: ServerContestant;
}

export type DraconicKnightServerArchetypeMethods = {
  
};

export type ExplosiveMimicServerArchetype = ServerArchetype<ExplosiveMimicServerArchetypeProperties & ExplosiveMimicServerArchetypeMethods>;

export type ExplosiveMimicServerArchetypeProperties = {
  contestant: ServerContestant;
  ragdollClone: Model?;
  round: ServerRound;
  events: {RBXScriptConnection};
  actions: {ServerAction};
};

export type ExplosiveMimicServerArchetypeConstructorProperties = {
  contestant: ServerContestant;
  round: ServerRound;
}

export type ExplosiveMimicServerArchetypeMethods = {
  
};

export type UndeadConsciousnessServerArchetype = ServerArchetype<UndeadConsciousnessServerArchetypeProperties & UndeadConsciousnessServerArchetypeMethods>;

export type UndeadConsciousnessServerArchetypeProperties = {
  contestant: ServerContestant;
  ragdollClone: Model?;
  round: ServerRound;
  events: {RBXScriptConnection};
  undeadEffect: UndeadServerEffect;
  actions: {ServerAction};
};

export type UndeadConsciousnessServerArchetypeConstructorProperties = {
  contestant: ServerContestant;
  round: ServerRound;
}

export type UndeadConsciousnessServerArchetypeMethods = {
  
};

export type RoundStatus = ClientRound.RoundStatus;

export type Cause = {
  contestantID: number?; 
  actionID: string?; 
  archetypeID: string?;
  itemID: string?;
  effectID: string?;
};

export type GameModeProperties = {
  id: string;
  name: string;
  description: string;
  start: (self: GameMode) -> ();
  breakdown: (self: GameMode) -> ();
  toString: (self: GameMode) -> string;
};

export type GameMode = GameModeProperties;

export type GameModeClass = GameModeProperties & {new: (...any) -> GameMode};

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

export type ServerActionConstructorProperties = {
  contestant: ServerContestant;
}

export type ServerAction<ExtendedProperties = unknown> = {
  id: string;
  name: string;
  description: string;
} & ExtendedProperties & {
  activate: (self: any, ...any) -> ();
  breakdown: (self: any, ...any) -> (); 
};

export type ServerActionClass<ConstructorProperties = any, Action = any> = {
  new: (...ConstructorProperties) -> Action
}

export type ServerActionFactory = {
  get: (
    ((effectID: "ChangeModes") -> ServerActionClass<ServerActionConstructorProperties, ChangeModesServerAction>)
    & ((effectID: "StrikeOutStrike") -> ServerActionClass<ServerActionConstructorProperties, StrikeOutSwipeServerAction>)
    & ((actionID: string) -> ServerActionClass)
  );
}

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

export type ServerArchetype<ExtendedProperties = unknown> = ServerArchetypeProperties & ExtendedProperties & ServerArchetypeMethods;

export type ServerArchetypeClass = ServerArchetypeProperties & {new: (...any) -> ServerArchetype};

export type ArchetypeType = "Fighter" | "Defender" | "Destroyer" | "Supporter";

export type ServerArchetypeProperties = {
  
  id: string;
  
  name: string;

  description: string;

  type: ArchetypeType;

  actionIDs: {string};
  
};

export type ServerArchetypeMethods = {

  breakdown: (self: any) -> ();

};

export type WalkSpeedWeight = {
  walkSpeed: number;
  weight: number;
};

export type ServerContestantConstructorProperties = {
  id: number;
  round: ServerRound;
  name: string;
}

export type BaseModifierType = "Health" | "Stamina";

export type BaseModifier = {
  delta: number;
  cause: Cause;
};

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

export type ServerEffectDefaultProperties = {
  id: string;
  name: string;
  uniqueID: string;
  description: string;
};

export type ServerEffect<ExtendedProperties = unknown> = ServerEffectDefaultProperties & ExtendedProperties & {
  activate: (self: any, ...any) -> ();
  breakdown: (self: any, ...any) -> (); 
  updateContestantHealth: ((self: any, newHealth: number, oldHealth: number, cause: Cause?) -> number)?;
  updateContestantStamina: ((self: any, newHealth: number, oldHealth: number, cause: Cause?) -> number)?;
};

export type ServerEffectClass<ServerEffectConstructorProperties = any, ExtendedServerEffect = any> = ServerEffectDefaultProperties & {
  new: (...ServerEffectConstructorProperties) -> ExtendedServerEffect
}

export type ServerEffectFactory = {
  get: (
    ((effectID: "Invincibility") -> ServerEffectClass<ServerEffectConstructorProperties, InvincibilityServerEffect>)
    & ((effectID: "StaminaRecoverySuppression") -> ServerEffectClass)
    & ((effectID: "HoldingHeavyItem") -> ServerEffectClass<ServerEffectConstructorProperties, HoldingHeavyItemServerEffect>)
    & ((effectID: "Paralysis") -> ServerEffectClass<ServerEffectConstructorProperties, ParalysisServerEffect>)
    & ((effectID: "Undead") -> ServerEffectClass<ServerEffectConstructorProperties, UndeadServerEffect>)
    & ((effectID: "RoughArmor") -> ServerEffectClass<ServerEffectConstructorProperties, RoughArmorServerEffect>)
    & ((effectID: string) -> ServerEffectClass)
  );
  random: () -> ServerEffectClass;
}

export type ServerItem = ServerItemProperties & ServerItemEvents;

export type ServerRoundConstructorProperties = {

  -- This round's unique ID.
  id: string;

  gameModeID: string;
  
  -- This stage's ID.
  stageID: string;

  status: ClientRound.RoundStatus;

  timeStarted: number?;

  duration: number?;

  timeEnded: number?;

  contestantIDs: {number};
  
  stage: Stage.Stage?

}

export type ServerRoundProperties = ServerRoundConstructorProperties & {  

  stage: Stage.Stage;

  archetypes: {ServerArchetype};

  contestants: {ServerContestant};

  gameMode: GameMode?;

  autopilotTasks: {thread};

};

export type ServerRoundEvents = {
  onStopped: RBXScriptSignal;
  onEnded: RBXScriptSignal;
  onStatusChanged: RBXScriptSignal;
  onContestantAdded: RBXScriptSignal;
  onContestantRemoved: RBXScriptSignal;
  onTimeStartedChanged: RBXScriptSignal;
}

export type ServerRoundMethods = {

  --[[
    Adds a contestant to the round.
  ]]
  addContestant: (self: ServerRound, contestant: ServerContestant) -> ();

  --[[
    Converts the current server round to a client object, stripping any sensitive data.
  ]]
  getClientConstructorProperties: (self: ServerRound) -> any;
  setStatus: (self: ServerRound, newStatus: ClientRound.RoundStatus) -> ();
  start: (self: ServerRound) -> ();
  stop: (self: ServerRound, forced: boolean?) -> ();
  setGameMode: (self: ServerRound, gameMode: GameMode) -> ();
  toString: (self: ServerRound) -> string;
}

export type ServerRound = ServerRoundProperties & ServerRoundEvents & ServerRoundMethods;

return {};