import { type ClientRpcSchema, messagePort } from "dustkit/internal";

export const dustClient = messagePort<ClientRpcSchema>(
  window.opener ?? window.parent,
);
