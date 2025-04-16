import { Messenger } from "dustkit";

export const dustBridge =
  typeof window !== "undefined"
    ? Messenger.bridge({
        from: Messenger.fromWindow(window),
        to: Messenger.fromWindow(window.opener ?? window.parent),
      })
    : Messenger.noop();
