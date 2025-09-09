import { $ } from "./common";
import { createSocketSchema } from "./createSocketSchema";

export const position = $.type([
  // position
  "vec3",
  // orientation
  "vec2",
  // velocity
  "vec3",
]);

export const positionChange = $.type({
  u: "hex",
  t: "number",
  d: position,
});

export const clientSocket = createSocketSchema({
  in: $.type("never")
    .or({ t: "'positions'", d: [positionChange, "[]"] })
    .or({ t: "'presence'", d: "hex[]" }),
  out: $.type("never").or(position),
});
