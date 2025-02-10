--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local TurfWarContestantStatistics = require(ReplicatedStorage.Shared.TurfWarContestantStatistics);
export type TurfWarContestantStatistics = TurfWarContestantStatistics.TurfWarContestantStatistics;

export type BatterUpDemonMode = "Batter" | "Pitcher";

export type BeastSlashClientAction = ClientAction<{
  remoteFunction: RemoteFunction;
  activate: (self: BeastSlashClientAction) -> ();
  breakdown: (self: BeastSlashClientAction) -> ();
}>;

export type ChangeBallTypeClientAction = ClientAction<{
  gui: ScreenGui?;
  remoteFunction: RemoteFunction;
  activate: (self: ChangeBallTypeClientAction) -> ();
  breakdown: (self: ChangeBallTypeClientAction) -> ();
}>;

export type ChangeModesClientAction = ClientAction<{
  currentMode: BatterUpDemonMode;
  remoteFunction: RemoteFunction;
  isProcessing: boolean;
  activate: (self: ChangeModesClientAction) -> ();
  breakdown: (self: ChangeModesClientAction) -> ();
}>;

export type StrikeOutSwipeClientAction = ClientAction<{
  remoteFunction: RemoteFunction;
}>;

export type ClientAction<Extension = unknown> = ClientActionProperties & Extension & ClientActionMethods;

export type ClientActionClass<ConstructorProperties = any, Action = any> = {
  new: (...ConstructorProperties) -> Action
}

export type ClientActionMethods = {

  -- The function to activate the item on the server side.
  -- You can manually activate the item some other way too.
  activate: (self: any, ...any) -> ();

  -- The function to "break down" the item. This usually runs after the round ends and sometimes after item use.
  -- You can manually break down the item some other way too.
  breakdown: (self: any) -> ();

  -- The function to initialize the item. This usually runs after the player receives an item. 
  -- This function does not mean the player activated the item. Use :activate() instead.
  initialize: (self: any) -> ();

}

export type ClientActionProperties = {

  -- The ID of the action. Keep this unique.
  id: string;

  -- The name of the action.
  name: string;

  -- The Roblox asset link to the action's icon image.
  iconImage: string;

  -- The description of the action.
  description: string;
  
};

export type ClientContestant = ClientContestantProperties & ClientContestantEvents & ClientContestantMethods;

export type ClientContestantConstructorProperties = ClientContestantProperties & {
  characterName: string?;
};

export type ClientContestantProperties = {
  
  id: number;

  archetypeID: string?;
  
  isDisqualified: boolean;

  player: Player?;

  character: Model?;

  name: string;

  isBot: boolean;

  teamID: number?;

  currentHealth: number?;

  baseHealth: number?;

  currentStamina: number?;

  baseStamina: number?;

  statistics: TurfWarContestantStatistics?;
  
}

export type Cause = {
  archetypeID: string;
  contestantID: number;
  actionID: string?;
}

export type ClientContestantMethods = {
}

export type ClientContestantEvents = {
  onDisqualified: RBXScriptSignal;
  onHealthUpdated: RBXScriptSignal;
  onStaminaUpdated: RBXScriptSignal;
  onArchetypeUpdated: RBXScriptSignal;
  onCharacterUpdated: RBXScriptSignal;
  onStatisticsUpdated: RBXScriptSignal;
}

export type ClientEffect<Properties = ClientEffectProperties, Methods = ClientEffectMethods> = Properties & Methods;

export type ClientEffectClass<ClientEffectConstructorProperties = any, ExtendedClientEffect = any> = ClientEffectProperties & {
  new: (...ClientEffectConstructorProperties) -> ExtendedClientEffect & ClientEffect
}

export type ClientEffectFactory = {
  get: (
    ((effectID: "Paralysis") -> ClientEffectClass<ParalysisClientEffectConstructorProperties, ParalysisClientEffect>)
    & ((effectID: string) -> ClientEffectClass)
  );
  random: () -> ClientEffectClass;
}

export type ClientEffectProperties = {
  name: string;
  id: string;
  description: string?;
}

export type ClientEffectMethods = {
  activate: ((self: any, ...any) -> ())?;
  deactivate: ((self: any, ...any) -> ())?;
}

export type DetachLimbClientAction = ClientAction<{
  gui: ScreenGui?;
  remoteFunction: RemoteFunction;
  activate: (self: DetachLimbClientAction) -> ();
  breakdown: (self: DetachLimbClientAction) -> ();
}>;

export type HeresThePitchClientAction = ClientAction<{
  remoteEvent: RemoteEvent;
  remoteFunction: RemoteFunction;
  activate: (self: HeresThePitchClientAction) -> ();
  breakdown: (self: HeresThePitchClientAction) -> ();
}>;

export type DetonateDetachedLimbsClientAction = ClientAction<{
  gui: ScreenGui?;
  remoteFunction: RemoteFunction;
  activate: (self: DetonateDetachedLimbsClientAction) -> ();
  breakdown: (self: DetonateDetachedLimbsClientAction) -> ();
}>;

export type DiveBombClientAction = ClientAction<{
  remoteFunction: RemoteFunction;
  activate: (self: DiveBombClientAction) -> ();
  breakdown: (self: DiveBombClientAction) -> ();
}>;

export type ExplosivePunchClientAction = ClientAction<{
  remoteFunction: RemoteFunction;
  activate: (self: ExplosivePunchClientAction) -> ();
  breakdown: (self: ExplosivePunchClientAction) -> ();
}>;

export type FireBeamClientAction = ClientAction<{
  remoteFunction: RemoteFunction;
  chargeNotificationTask: thread?;
  remoteEvent: RemoteEvent;
  isCharging: boolean;
  activate: (self: FireBeamClientAction, shouldCharge: boolean) -> ();
  breakdown: (self: FireBeamClientAction) -> ();
}>;

export type LockOnClientAction = ClientAction<{
  previousTargets: {Instance};
  targetingGUI: BillboardGui;
  activate: (self: LockOnClientAction) -> ();
  breakdown: (self: LockOnClientAction) -> ();
}>;

export type RocketFeetClientAction = ClientAction<{
  remoteFunction: RemoteFunction;
  jumpButtonClickEvent: RBXScriptConnection?;
  cFrameEvent: RBXScriptConnection?;
  activate: (self: RocketFeetClientAction) -> ();
  breakdown: (self: RocketFeetClientAction) -> ();
}>;

export type TakeFlightClientAction = ClientAction<{
  remoteFunction: RemoteFunction;
  activate: (self: TakeFlightClientAction) -> ();
  breakdown: (self: TakeFlightClientAction) -> ();
}>;

export type TarBombClientAction = ClientAction<{
  remoteFunction: RemoteFunction;
  isCharging: boolean;
  chargeNotificationTask: thread?;
  remoteEvent: RemoteEvent;
  activate: (self: TarBombClientAction, shouldCharge: boolean) -> ();
  breakdown: (self: TarBombClientAction) -> ();
}>;

export type ParalysisClientEffect = ClientEffect<ParalysisClientEffectProperties & ParalysisClientEffectMethods>;

export type ParalysisClientEffectProperties = {
  name: string;
  id: string;
  contestant: ClientContestant;
  uniqueID: string;
  events: {RBXScriptConnection};
  remoteFunction: RemoteFunction;
  frozenAnimations: {
    [AnimationTrack]: number;
  }
}

export type ParalysisClientEffectMethods = {
  activate: (self: ParalysisClientEffect) -> ();
  deactivate: (self: ParalysisClientEffect) -> ();
}

export type ParalysisClientEffectConstructorProperties = {
  contestant: ClientContestant;
  uniqueID: string;
  events: {RBXScriptConnection};
}

return {};