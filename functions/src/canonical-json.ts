function sortValue(value: unknown): unknown {
  if (value === null) {
    return null;
  }

  if (Array.isArray(value)) {
    return value.map((item) => sortValue(item));
  }

  if (typeof value === "object") {
    const record = value as Record<string, unknown>;
    const sorted: Record<string, unknown> = {};
    for (const key of Object.keys(record).sort()) {
      const child = record[key];
      if (child === undefined) {
        throw new Error(`Cannot canonicalize undefined value at key "${key}"`);
      }
      sorted[key] = sortValue(child);
    }
    return sorted;
  }

  if (
    typeof value === "string" ||
    typeof value === "number" ||
    typeof value === "boolean"
  ) {
    if (typeof value === "number" && !Number.isFinite(value)) {
      throw new Error("Cannot canonicalize a non-finite number");
    }
    return value;
  }

  throw new Error(`Cannot canonicalize value of type ${typeof value}`);
}

/**
 * Stable JSON serialization used for hashing and Ed25519 signatures.
 * Keys are sorted recursively; arrays keep their order; no whitespace.
 */
export function canonicalJson(value: unknown): string {
  return JSON.stringify(sortValue(value));
}
