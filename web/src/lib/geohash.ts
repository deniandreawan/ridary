const BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz";

export interface LatLon {
  lat: number;
  lon: number;
}

export function encodeGeohash(lat: number, lon: number, precision = 6): string {
  if (!Number.isFinite(lat) || lat < -90 || lat > 90) {
    throw new Error("Latitude must be between -90 and 90");
  }
  if (!Number.isFinite(lon) || lon < -180 || lon > 180) {
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
      const mid = (lonMin + lonMax) / 2;
      if (lon >= mid) {
        bitValue = bitValue * 2 + 1;
        lonMin = mid;
      } else {
        bitValue *= 2;
        lonMax = mid;
      }
    } else {
      const mid = (latMin + latMax) / 2;
      if (lat >= mid) {
        bitValue = bitValue * 2 + 1;
        latMin = mid;
      } else {
        bitValue *= 2;
        latMax = mid;
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

export function decodeGeohash(hash: string): LatLon {
  if (!/^[0-9b-hjkmnp-z]{1,12}$/.test(hash)) {
    throw new Error("Invalid geohash");
  }

  let even = true;
  let latMin = -90;
  let latMax = 90;
  let lonMin = -180;
  let lonMax = 180;

  for (const character of hash) {
    const index = BASE32.indexOf(character);
    if (index < 0) {
      throw new Error("Invalid geohash character");
    }

    for (let mask = 16; mask > 0; mask >>= 1) {
      const bit = (index & mask) !== 0;
      if (even) {
        const mid = (lonMin + lonMax) / 2;
        if (bit) {
          lonMin = mid;
        } else {
          lonMax = mid;
        }
      } else {
        const mid = (latMin + latMax) / 2;
        if (bit) {
          latMin = mid;
        } else {
          latMax = mid;
        }
      }
      even = !even;
    }
  }

  return {
    lat: (latMin + latMax) / 2,
    lon: (lonMin + lonMax) / 2
  };
}

export function geohashCell(hash: string): [number, number, number, number] {
  let even = true;
  let latMin = -90;
  let latMax = 90;
  let lonMin = -180;
  let lonMax = 180;

  for (const character of hash) {
    const index = BASE32.indexOf(character);
    if (index < 0) {
      throw new Error("Invalid geohash character");
    }
    for (let mask = 16; mask > 0; mask >>= 1) {
      const bit = (index & mask) !== 0;
      if (even) {
        const mid = (lonMin + lonMax) / 2;
        if (bit) {
          lonMin = mid;
        } else {
          lonMax = mid;
        }
      } else {
        const mid = (latMin + latMax) / 2;
        if (bit) {
          latMin = mid;
        } else {
          latMax = mid;
        }
      }
      even = !even;
    }
  }

  return [latMin, lonMin, latMax, lonMax];
}
