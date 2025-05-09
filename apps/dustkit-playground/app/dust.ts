import { type ClientRpcSchema, messagePort } from "dustkit/internal";
import { getMessagePortRpcClient } from "dustkit/internal";

export const dustClient = messagePort<ClientRpcSchema>(
  await getMessagePortRpcClient(window.opener ?? window.parent),
);
