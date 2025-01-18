--!strict
local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Profile = require(ServerStorage.Packages.Profile);
local Stage = require(ServerStorage.Packages.Stage);

local TurfWarContestantStatistics = require(ReplicatedStorage.Shared.TurfWarContestantStatistics);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);

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
  _lock: unknown;
  name: string;
  id: string;
}

export type HoldingHeavyItemServerEffectMethods = {
  activate: (self: HoldingHeavyItemServerEffect, contestant: ServerContestant) -> ();
  deactivate: (self: HoldingHeavyItemServerEffect, contestant: ServerContestant) -> ();
}

export type UndeadServerEffect = ServerEffect<UndeadServerEffectProperties & UndeadServerEffectMethods>;

export type UndeadServerEffectProperties = {
  name: string;
  id: string;
  _events: {
    [unknown]: RBXScriptConnection
  };
  _contestant: ServerContestant;
}

export type UndeadServerEffectConstructorProperties = {
  contestant: ServerContestant;
}

export type UndeadServerEffectMethods = {
  activate: (self: UndeadServerEffect, contestant: ServerContestant) -> ();
  deactivate: (self: UndeadServerEffect, contestant: ServerContestant) -> ();
}

export type ParalysisServerEffect = ServerEffect<ParalysisServerEffectProperties & ParalysisServerEffectMethods>;

export type ParalysisServerEffectConstructorProperties = {
  contestant: ServerContestant;
}

export type ParalysisServerEffectProperties = {
  name: string;
  id: string;
  _weight: WalkSpeedWeight;
  _contestant: ServerContestant;
}

export type ParalysisServerEffectMethods = {
  activate: (self: ParalysisServerEffect) -> ();
  deactivate: (self: ParalysisServerEffect) -> ();
}

export type InvincibilityServerEffect = ServerEffect<InvincibilityServerEffectProperties & InvincibilityServerEffectMethods>;

export type InvincibilityServerEffectProperties = {
  expirationTimeMilliseconds: number;
  test: number;
}

export type InvincibilityServerEffectMethods = {
  updateContestantStamina: (self: InvincibilityServerEffect, newStamina: number, oldStamina: number) -> number;
  updateContestantHealth: (self: InvincibilityServerEffect, newHealth: number, oldHealth: number) -> number;
}

export type InvinicbilityServerEffectConstructorProperties = {
  expirationTimeMilliseconds: number;
}

export type HoldingHeavyItemServerEffectConstructorProperties = {

}

export type ServerAction = ServerActionProperties & ServerActionEvents;

export type ServerActionProperties = {
  id: string;
  name: string;
  description: string;
  activate: (self: ServerAction, ...any) -> ();
  breakdown: (self: ServerAction) -> ();
  initialize: (self: ServerAction, ...any) -> ();
};

export type ServerActionEvents = {
  onActivate: RBXScriptSignal<"Press" | "Hold">;
}

export type ServerArchetype = ServerArchetypeProperties & ServerArchetypeMethods;

export type ServerArchetypeClass = ServerArchetypeProperties & {new: (...any) -> ServerArchetype};

export type ServerArchetypeProperties = {
  
  id: string;
  
  name: string;

  description: string?;

  type: "Fighter" | "Defender" | "Destroyer" | "Supporter";

  actionIDs: {string};

  initialize: (self: ServerArchetype, ...any) -> ();
  
}

export type ServerArchetypeMethods = {

  breakdown: (self: ServerArchetype) -> ();

  runAutoPilot: (self: ServerArchetype, actions: {ServerAction}) -> ();

}

export type WalkSpeedWeight = {
  walkSpeed: number;
  weight: number;
};

export type ServerContestantConstructorProperties = {
  character: Model?;
  baseStamina: number?;
  baseHealth: number?;
  currentStamina: number?;
  currentHealth: number?;
  effects: {ServerEffect}?;
  walkSpeedWeights: {WalkSpeedWeight}?;
  id: number;
  round: ServerRound;
  name: string;
  player: Player?;
  profile: Profile.Profile?;
  teamID: number?;
  items: {ServerItem}?;
  statistics: TurfWarContestantStatistics.TurfWarContestantStatistics?;
}

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

  currentHealth: number;

  baseHealth: number;

  baseStamina: number;

  statistics: TurfWarContestantStatistics.TurfWarContestantStatistics?;
  
}

export type ServerContestantMethods = {
  addWalkSpeedWeight: (self: ServerContestant, weight: WalkSpeedWeight) -> ();
  addItem: (self: ServerContestant, item: ServerItem) -> ();
  removeWalkSpeedWeight: (self: ServerContestant, weight: WalkSpeedWeight) -> ();
  removeItem: (self: ServerContestant, item: ServerItem) -> ();
  refreshWalkSpeed: (self: ServerContestant) -> ();
  addEffect: (self: ServerContestant, effect: ServerEffect) -> ();
  removeEffect: (self: ServerContestant, effect: ServerEffect) -> ();
  convertToClient: (self: ServerContestant) -> {any};
  disqualify: (self: ServerContestant) -> ();
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
  onEffectsUpdated: RBXScriptSignal<{ServerEffect}>;
}

export type ServerContestant = ServerContestantProperties & ServerContestantEvents & ServerContestantMethods;

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

export type ServerEffect<Class = unknown> = ServerEffectProperties & ServerEffectMethods<Class & ServerEffectProperties>;

export type ServerEffectProperties = {
  name: string;
  id: string;
  description: string?;
  expirationTimeMilliseconds: number?;
}

export type ServerEffectMethods<T> = {
  activate: ((self: T, ...any) -> ())?;
  deactivate: ((self: T, ...any) -> ())?;
  updateContestantHealth: ((self: T, newHealth: number, oldHealth: number, cause: Cause?) -> number)?;
  updateContestantStamina: ((self: T, newHealth: number, oldHealth: number, cause: Cause?) -> number)?;
}

export type ServerEffectClass<T = unknown, ExtendedServerEffect = unknown> = ServerEffectProperties & {
  new: (...T) -> ExtendedServerEffect & ServerEffect
}

export type ServerEffectFactory = {
  get: (
    ((effectID: "Invincibility") -> ServerEffectClass<InvinicbilityServerEffectConstructorProperties, InvincibilityServerEffect>)
    & ((effectID: "StaminaRecoverySuppression") -> ServerEffectClass)
    & ((effectID: "HoldingHeavyItem") -> ServerEffectClass<HoldingHeavyItemServerEffectConstructorProperties, HoldingHeavyItemServerEffect>)
    & ((effectID: "Paralysis") -> ServerEffectClass<ParalysisServerEffectConstructorProperties, ParalysisServerEffect>)
    & ((effectID: "Undead") -> ServerEffectClass<UndeadServerEffectConstructorProperties, UndeadServerEffect>)
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

  actions: {ServerAction};

  contestants: {ServerContestant};

  gameMode: GameMode?;

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