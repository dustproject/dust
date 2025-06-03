export class MessagePortTargetClosedBeforeReadyError extends Error {
  constructor() {
    super("MessagePort target closed before ready.");
    this.name = "MessagePortTargetClosedBeforeReadyError";
  }
}
