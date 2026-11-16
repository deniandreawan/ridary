const BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz";

export function encodeGeohash(
  latitude: number,
  longitude: number,
  precision = 6
): string {
  if (!Number.isFinite(latitude) || latitude < -90 || latitude > 90) {
    throw new Error("Latitude must be between -90 and 90");
  }
  if (!Number.isFinite(longitude) || longitude < -180 || longitude > 180) {
    throw new Error("Longitude must be between -180 and 180");
  }
  if (!Number.isInteger(precision) || precision < 1 || precision > 12) {
    throw new Error("Precision must be an integer between 1 and 12");
  }

  let latMin = -90;
  let latMax = 90;
  let lonMin = -180;
  let lonMax = 180;
  let hash = "";
  let bits = 0;
  let bitValue = 0;
  let even = true;

  while (hash.length < precision) {
    if (even) {
      const lonMid = (lonMin + lonMax) / 2;
      if (longitude >= lonMid) {
        bitValue = bitValue * 2 + 1;
        lonMin = lonMid;
      } else {
        bitValue *= 2;
        lonMax = lonMid;
      }
    } else {
      const latMid = (latMin + latMax) / 2;
      if (latitude >= latMid) {
        bitValue = bitValue * 2 + 1;
        latMin = latMid;
      } else {
        bitValue *= 2;
        latMax = latMid;
      }
    }

    even = !even;

    if (bits < 4) {
      bits += 1;
    } else {
      hash += BASE32.charAt(bitValue);
      bits = 0;
      bitValue = 0;
    }
  }

  return hash;
}

export function isValidGeohash(value: string): boolean {
  return /^[0-9a-z]{6,8}$/.test(value);
}
