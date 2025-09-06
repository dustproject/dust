import {
  $,
  channelsSchema,
  createSocketSchema,
  positionChange,
} from "dustkit/realtime";

export const hubSocket = createSocketSchema({
  in: $.type("never")
    .or({ t: "'positions'", d: [positionChange, "[]"] })
    .or({ t: "'presence'", d: "hex[]" }),
  out: $.type("never")
    .or("'tickPositions'")
    .or({ t: "'positions'", d: [positionChange, "[]"] })
    .or({ t: "'presence'", d: "hex[]" }),
});

export const clientDataSchema = $.type({
  "userAddress?": "hex | undefined",
  channels: channelsSchema,
});
