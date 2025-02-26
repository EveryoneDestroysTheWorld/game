--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientArchetype = require(ReplicatedStorage.Client.Interfaces.IClientArchetype);

type ClientArchetype = ClientArchetype.ClientArchetype;

export type ClientArchetypeType = "Fighter" | "Defender" | "Destroyer" | "Supporter";

export type ClientArchetypeClass<Archetype = ClientArchetype> = {

  id: string;
  
  name: string;

  description: string?;

  type: ClientArchetypeType;

  iconImage: string;

  actionIDs: {string};

  new: (contestantID: number) -> Archetype

}

return {};