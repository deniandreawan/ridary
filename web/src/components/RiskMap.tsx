import type { Feature, FeatureCollection, LineString, Point } from "geojson";
import {
  LngLatBounds,
  Map as MapLibreMap,
  NavigationControl,
  Popup,
  setWorkerUrl,
  type GeoJSONSource
} from "maplibre-gl";
import workerUrl from "maplibre-gl/dist/maplibre-gl-worker.mjs?url";
import "maplibre-gl/dist/maplibre-gl.css";
import { useCallback, useEffect, useRef, useState } from "react";
import { riskFeatureCollection, riskPoints } from "../lib/risk";
import type { Ride, RiskCell } from "../types";
import { RouteArt } from "./RouteArt";

setWorkerUrl(workerUrl);

const LIGHT_STYLE_URL = "https://tiles.openfreemap.org/styles/positron";

const EMPTY_LINE: FeatureCollection<LineString> = {
  type: "FeatureCollection",
  features: []
};

export function RiskMap({
  riskCells,
  ride,
  height = 420,
  heightClassName,
  showRisk = true,
  showRoute = true
}: {
  riskCells: RiskCell[];
  ride?: Ride;
  height?: number;
  heightClassName?: string;
  showRisk?: boolean;
  showRoute?: boolean;
}) {
  const containerRef = useRef<HTMLDivElement | null>(null);
  const mapRef = useRef<MapLibreMap | null>(null);
  const readyRef = useRef(false);
  const dataRef = useRef({ riskCells, ride });
  const lastRideRef = useRef<string | undefined>(undefined);
  const [mapError, setMapError] = useState(false);
  const visibilityRef = useRef({ showRisk, showRoute });

  const fitData = useCallback(() => {
    const map = mapRef.current;
    if (!map || !readyRef.current) return;
    const bounds = new LngLatBounds();
    let hasBounds = false;

    for (const cell of dataRef.current.riskCells) {
      const point = riskFeatureCollection([cell]).features[0];
      if (point?.geometry.type === "Point") {
        bounds.extend(point.geometry.coordinates as [number, number]);
        hasBounds = true;
      }
    }

    for (const [lat, lon] of dataRef.current.ride?.routePreview ?? []) {
      bounds.extend([lon, lat]);
      hasBounds = true;
    }

    if (hasBounds) {
      map.fitBounds(bounds, { padding: 52, maxZoom: 13, duration: 0 });
    }
  }, []);

  const applyVisibility = useCallback(() => {
    const map = mapRef.current;
    if (!map || !readyRef.current) return;
    const visibility = visibilityRef.current;
    for (const id of ["risk-glow", "risk-circles"]) {
      if (map.getLayer(id)) {
        map.setLayoutProperty(id, "visibility", visibility.showRisk ? "visible" : "none");
      }
    }
    for (const id of ["route-casing", "route-line"]) {
      if (map.getLayer(id)) {
        map.setLayoutProperty(id, "visibility", visibility.showRoute ? "visible" : "none");
      }
    }
  }, []);

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
    if (currentRideID && currentRideID !== lastRideRef.current) {
      lastRideRef.current = currentRideID;
      fitData();
    }
  }, [fitData]);

  useEffect(() => {
    dataRef.current = { riskCells, ride };
    applyData();
  }, [applyData, ride, riskCells]);

  useEffect(() => {
    visibilityRef.current = { showRisk, showRoute };
    applyVisibility();
  }, [applyVisibility, showRisk, showRoute]);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    let map: MapLibreMap;
    try {
      map = new MapLibreMap({
        container,
        style: LIGHT_STYLE_URL,
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
          "circle-opacity": 0.12
        }
      });
      map.addLayer({
        id: "risk-circles",
        type: "circle",
        source: "risk",
        paint: {
          "circle-radius": ["get", "radius"],
          "circle-color": ["get", "color"],
          "circle-opacity": 0.46,
          "circle-stroke-color": ["get", "color"],
          "circle-stroke-width": 1.4
        }
      });

      map.addSource("route", {
        type: "geojson",
        data: EMPTY_LINE
      });
      map.addLayer({
        id: "route-casing",
        type: "line",
        source: "route",
        layout: {
          "line-cap": "round",
          "line-join": "round"
        },
        paint: {
          "line-color": "#ffffff",
          "line-width": 8.5,
          "line-opacity": 0.96
        }
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
          "line-color": "#00a6f4",
          "line-width": 4.5,
          "line-opacity": 0.98
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
        detail.style.color = "#66737a";
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
      applyVisibility();
      fitData();
    });

    return () => {
      readyRef.current = false;
      mapRef.current = null;
      map.remove();
    };
  }, [applyData, applyVisibility, fitData]);

  if (mapError) {
    const points = riskPoints(riskCells).slice(0, 6);
    return (
      <div
        className={`relative overflow-hidden rounded-2xl border border-line/75 bg-sky-soft/40 ${heightClassName ?? ""}`}
        style={heightClassName ? undefined : { height }}
        role="img"
        aria-label="Road risk map preview"
      >
        <RouteArt
          route={ride?.routePreview ?? []}
          className="h-full w-full"
        />
        {points.map((point, index) => {
          const left = 18 + ((index * 17 + 11) % 64);
          const top = 22 + ((index * 23 + 7) % 56);
          return (
            <div
              key={point.cell.id}
              className="pointer-events-none absolute -translate-x-1/2 -translate-y-1/2 rounded-full border-2 border-white px-2 py-0.5 font-mono text-[10px] font-semibold text-white shadow-sm"
              style={{
                left: `${left}%`,
                top: `${top}%`,
                backgroundColor: point.color
              }}
            >
              {point.cell.geohash}
            </div>
          );
        })}
      </div>
    );
  }

  return (
    <div
      ref={containerRef}
      className={`overflow-hidden rounded-2xl border border-line bg-ink-soft ${heightClassName ?? ""}`}
      style={heightClassName ? undefined : { height }}
      role="application"
      aria-label="Community road risk map"
    />
  );
}
