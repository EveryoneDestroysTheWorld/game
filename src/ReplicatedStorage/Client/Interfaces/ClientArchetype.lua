--!strict

export type ClientArchetypeType = "Fighter" | "Defender" | "Destroyer" | "Supporter";

export type ClientArchetype = {
  
  id: string;
  
  name: string;

  description: string?;

  type: ClientArchetypeType;

  iconImage: string;

  actionIDs: {string};

  breakdown: (self: ClientArchetype) -> ();
  
}

return {};