import type { EntityId, ProgramId } from "../common";
import type { Config } from "./config";

// TODO: split schema out into directional specific schemas (app->client, client->app)

export type MessengerSchema = [
  {
    topic: "internal:ready";
    payload: undefined;
    response: undefined;
  },
  {
    topic: "app:open";
    payload: {
      config: Config;
      via?: {
        entity: EntityId;
        program: ProgramId;
      };
    };
    response: undefined;
  },
  {
    topic: "client:setWaypoint";
    payload: {
      target: EntityId;
      label: string;
    };
    response: undefined;
  },
];
