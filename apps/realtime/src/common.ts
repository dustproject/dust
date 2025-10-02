export function createTimeout(
  ms: number,
  fn: (...args: unknown[]) => unknown,
): () => void {
  const timer = setTimeout(fn, ms);
  return function off() {
    clearTimeout(timer);
  };
}

export function createInterval(
  ms: number,
  fn: (...args: unknown[]) => unknown,
): () => void {
  const timer = setInterval(fn, ms);
  return function off() {
    clearInterval(timer);
  };
}

export function wait(ms: number): Promise<void> {
  return new Promise<void>((resolve) => setTimeout(() => resolve(), ms));
}

export function isDefined<T>(argument: T | undefined): argument is T {
  return argument !== undefined;
}
