import { type } from "arktype";

const searchParamsInput = type({
  "[string]": "string | string[] | undefined | null",
});

export function toSearchParams(input: typeof searchParamsInput.infer) {
  return new URLSearchParams(
    Array.from(Object.entries(input)).flatMap(([name, value]) => {
      if (value == null) return [];
      if (typeof value === "string") return [[name, value]];
      return value.map((v) => [name, v]);
    }),
  );
}
