import type { Feature, FeatureCollection, LineString, Point } from "geojson";
import {
  LngLatBounds,
  Map as MapLibreMap,
  NavigationControl,
  Popup,
  type GeoJSONSource,
  type StyleSpecification
} from "maplibre-gl";
import "maplibre-gl/dist/maplibre-gl.css";
import { useCallback, useEffect, useRef, useState } from "react";
import { riskFeatureCollection } from "../lib/risk";
import type { Ride, RiskCell } from "../types";

const DARK_STYLE: StyleSpecification = {
  version: 8,
  sources: {
    carto: {
      type: "raster",
      tiles: [
        "https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png"
      ],
      tileSize: 256,
      attribution: "© OpenStreetMap © CARTO"
    }
  },
  layers: [
    {
      id: "carto",
      type: "raster",
      source: "carto",
      minzoom: 0,
      maxzoom: 20
    }
  ]
};

const EMPTY_LINE: FeatureCollection<LineString> = {
  type: "FeatureCollection",
  features: []
};

export function RiskMap({
  riskCells,
  ride,
  height = 420
}: {
  riskCells: RiskCell[];
  ride?: Ride;
  height?: number;
}) {
  const containerRef = useRef<HTMLDivElement | null>(null);
  const mapRef = useRef<MapLibreMap | null>(null);
  const readyRef = useRef(false);
  const dataRef = useRef({ riskCells, ride });
  const lastRideRef = useRef<string | undefined>(undefined);
  const [mapError, setMapError] = useState(false);

  const applyData = useCallback(() => {
    const map = mapRef.current;
    if (!map || !readyRef.current) return;

    const riskSource = map.getSource("risk") as GeoJSONSource | undefined;
    riskSource?.setData(
      riskFeatureCollection(dataRef.current.riskCells) as FeatureCollection<Point>
    );

    const routeSource = map.getSource("route") as GeoJSONSource | undefined;
    const route = dataRef.current.ride?.routePreview ?? [];
    if (route.length > 1) {
      routeSource?.setData({
        type: "Feature",
        properties: {},
        geometry: {
          type: "LineString",
          coordinates: route.map(([lat, lon]) => [lon, lat])
        }
      } as Feature<LineString>);
    } else {
      routeSource?.setData(EMPTY_LINE);
    }

    const currentRideID = dataRef.current.ride?.id;
    if (currentRideID && currentRideID !== lastRideRef.current && route.length > 1) {
      const bounds = new LngLatBounds();
      for (const [lat, lon] of route) {
        bounds.extend([lon, lat]);
      }
      map.fitBounds(bounds, { padding: 48, maxZoom: 14, duration: 0 });
      lastRideRef.current = currentRideID;
    }
  }, []);

  useEffect(() => {
    dataRef.current = { riskCells, ride };
    applyData();
  }, [applyData, ride, riskCells]);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    let map: MapLibreMap;
    try {
      map = new MapLibreMap({
        container,
        style: DARK_STYLE,
        center: [106.8456, -6.2088],
        zoom: 11.4
      });
    } catch {
      queueMicrotask(() => setMapError(true));
      return;
    }

    mapRef.current = map;
    map.addControl(new NavigationControl({ showCompass: false }), "bottom-right");

    map.on("load", () => {
      readyRef.current = true;

      map.addSource("risk", {
        type: "geojson",
        data: riskFeatureCollection([]) as FeatureCollection<Point>
      });
      map.addLayer({
        id: "risk-glow",
        type: "circle",
        source: "risk",
        paint: {
          "circle-radius": ["*", ["get", "radius"], 1.9],
          "circle-color": ["get", "color"],
          "circle-opacity": 0.08
        }
      });
      map.addLayer({
        id: "risk-circles",
        type: "circle",
        source: "risk",
        paint: {
          "circle-radius": ["get", "radius"],
          "circle-color": ["get", "color"],
          "circle-opacity": 0.28,
          "circle-stroke-color": ["get", "color"],
          "circle-stroke-width": 1.4
        }
      });

      map.addSource("route", {
        type: "geojson",
        data: EMPTY_LINE
      });
      map.addLayer({
        id: "route-line",
        type: "line",
        source: "route",
        layout: {
          "line-cap": "round",
          "line-join": "round"
        },
        paint: {
          "line-color": "#ffb84d",
          "line-width": 4,
          "line-opacity": 0.92,
          "line-blur": 0.4
        }
      });

      map.on("click", "risk-circles", (event) => {
        const feature = event.features?.[0];
        if (!feature) return;
        const properties = feature.properties as Record<string, unknown>;
        const geohash = String(properties.geohash ?? "");
        const count = Number(properties.count ?? 0);
        const severity = Number(properties.severity ?? 0);

        const element = document.createElement("div");
        const title = document.createElement("div");
        title.textContent = `Risk cell ${geohash}`;
        title.style.fontWeight = "600";
        title.style.marginBottom = "4px";
        const detail = document.createElement("div");
        detail.textContent = `${count} events · avg severity ${severity.toFixed(1)}`;
        detail.style.color = "#93a6b5";
        element.append(title, detail);

        new Popup({ closeButton: true, offset: 12 })
          .setLngLat(event.lngLat)
          .setDOMContent(element)
          .addTo(map);
      });

      map.on("mouseenter", "risk-circles", () => {
        map.getCanvas().style.cursor = "pointer";
      });
      map.on("mouseleave", "risk-circles", () => {
        map.getCanvas().style.cursor = "";
      });

      applyData();

      const bounds = new LngLatBounds();
      let hasBounds = false;
      for (const cell of dataRef.current.riskCells) {
        const point = riskFeatureCollection([cell]).features[0];
        if (point?.geometry.type === "Point") {
          bounds.extend(point.geometry.coordinates as [number, number]);
          hasBounds = true;
        }
      }
      if (hasBounds) {
        map.fitBounds(bounds, { padding: 52, maxZoom: 13, duration: 0 });
      }
    });

    return () => {
      readyRef.current = false;
      mapRef.current = null;
      map.remove();
    };
  }, [applyData]);

  if (mapError) {
    return (
      <div
        className="flex items-center justify-center rounded-2xl border border-line bg-ink-soft px-6 text-center"
        style={{ height }}
      >
        <div className="max-w-sm text-xs leading-relaxed text-muted">
          The map could not start in this browser. The ride and risk details
          are still available in the page.
        </div>
      </div>
    );
  }

  return (
    <div
      ref={containerRef}
      className="overflow-hidden rounded-2xl border border-line bg-ink-soft"
      style={{ height }}
      role="application"
      aria-label="Community road risk map"
    />
  );
}
