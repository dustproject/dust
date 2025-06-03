export class MessagePortTargetClosedBeforeReadyError extends Error {
  constructor() {
    super("MessagePort target closed before ready.");
    this.name = "MessagePortTargetClosedBeforeReadyError";
  }
}

export class MessagePortUnexpectedReadyMessageError extends Error {
  constructor() {
    super("Unexpected ready message from MessagePort.");
    this.name = "MessagePortUnexpectedReadyMessageError";
  }
}
