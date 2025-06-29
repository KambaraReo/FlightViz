import { useEffect, useState, useMemo } from 'react';
import { MapContainer, TileLayer, Polyline, Marker} from 'react-leaflet';
import AirportMarker from './AirportMarker';
import PlaybackControls from './PlaybackControls';
import TimestampDisplay from './TimestampDisplay';
import { fetchAirports } from '../utils/api/airports';
import { fetchOneDayTrack, type TrackPoint } from '../utils/api/tracks';
import { getColorByAltitude } from '../utils/track';
import L from "leaflet";

import type { Airport } from '../utils/api/airports';

type AirportMapProps = {
  flightId: string;
  colorByAltitude: boolean;
};

const AirportMap = ({ flightId, colorByAltitude }: AirportMapProps) => {
  const [airports, setAirports] = useState<Airport[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const status = 1;
  const [track, setTrack] = useState<TrackPoint[]>([]);
  const [animationIndex, setAnimationIndex] = useState<number>(0);
  const [isPlaying, setIsPlaying] = useState<boolean>(false);
  const [speed, setSpeed] = useState(500);
  const [showFullTrack, setShowFullTrack] = useState(false);
  const { timestamp: currentTimestamp } = track[animationIndex] ?? {}
  const [firstPoint, lastPoint] = [track[0], track[track.length - 1]];
  const { timestamp: startTimestamp } = firstPoint || {};
  const { timestamp: endTimestamp } = lastPoint || {};
  const range = { start: startTimestamp, end: endTimestamp };

  const radarIcon = useMemo(() => {
    const blinkingClass = isPlaying ? 'leaflet-blinking-icon' : '';

    return L.divIcon({
      html: `<div class="${blinkingClass}" style="
        width: 10px;
        height: 10px;
        border: 2px solid yellow;
        background-color: transparent;
        box-sizing: border-box;
        border-radius: 0;
      "></div>`,
      className: '',
      iconSize: [10, 10],
    });
  }, [isPlaying]);

  const altitudeColoredSegments = useMemo(() => {
    if (track.length < 2) return [];

    const segments = [];
    const end = showFullTrack ? track.length : animationIndex + 1;

    for (let i = 1; i < end; i++) {
      const prev = track[i - 1];
      const curr = track[i];
      const color = getColorByAltitude(curr.alt ?? 0);

      segments.push({
        positions: [
          [prev.lat, prev.lon],
          [curr.lat, curr.lon],
        ],
        color,
      });
    }

    return segments;
  }, [track, animationIndex, showFullTrack]);

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const [airportData, trackData] = await Promise.all([
          fetchAirports(status),
          fetchOneDayTrack(flightId)
        ]);
        setAirports(airportData);
        setTrack(trackData);
        setAnimationIndex(0);
      } catch (err) {
        console.error("データの取得に失敗しました", err);
        setError("データの取得に失敗しました");
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [flightId]);

  useEffect(() => {
    if (!isPlaying || track.length === 0) return;

    const interval = setInterval(() => {
      setAnimationIndex((prevIndex) => {
        if (prevIndex < track.length - 1) {
          return prevIndex + 1;
        } else {
          setIsPlaying(false);
          clearInterval(interval);
          return prevIndex;
        }
      });
    }, speed);

    return () => clearInterval(interval);
  }, [isPlaying, speed, track]);

  useEffect(() => {
    if (showFullTrack) {
      setIsPlaying(false);
    }
  }, [showFullTrack]);

  return loading ? (
    <p>Loading...</p>
  ) : ( error ? (
    <p>{error}</p>
  ): (
    <div className="w-full h-full flex flex-col">
      <div className="flex flex-col gap-2 p-2 bg-black text-green-400 text-sm">
        <PlaybackControls
          isPlaying={isPlaying}
          setIsPlaying={setIsPlaying}
          animationIndex={animationIndex}
          setAnimationIndex={setAnimationIndex}
          speed={speed}
          setSpeed={setSpeed}
          max={track.length > 0 ? track.length - 1 : 0}
          showFullTrack={showFullTrack}
          setShowFullTrack={setShowFullTrack}
          disabled={showFullTrack}
        />

        {showFullTrack ? (
          <TimestampDisplay range={range} />
        ) : (
          <TimestampDisplay timestamp={currentTimestamp} />
        )}
      </div>

      <div className="flex-grow">
        <MapContainer
          center={[36.2048, 138.2529]}
          zoom={5.0}
          className="w-full h-full min-h-[360px]"
        >
          <TileLayer
            url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
            attribution='&copy; OpenStreetMap & CartoDB'
          />
          {airports.map((airport) => (
            <AirportMarker
              key={airport.icao_code}
              code={airport.icao_code}
              label={airport.label}
              lat={airport.lat}
              lon={airport.lon}
            />
          ))}
          {track.length > 0 && (
            <>
              {showFullTrack ? (
                colorByAltitude ? (
                  altitudeColoredSegments.map((seg, idx) => (
                    <Polyline
                      key={idx}
                      positions={seg.positions.map(([lat, lon]) => [lat, lon])}
                      pathOptions={{ color: seg.color, weight: 1, opacity: 0.8 }}
                    />
                  ))
                ) : (
                  <Polyline
                    positions={track.map((point) => [point.lat, point.lon])}
                    pathOptions={{ color: 'yellow', weight: 1, opacity: 0.8 }}
                  />
                )
              ) : colorByAltitude ? (
                altitudeColoredSegments.map((seg, idx) => (
                  <Polyline
                    key={idx}
                    positions={seg.positions.map(([lat, lon]) => [lat, lon])}
                    pathOptions={{ color: seg.color, weight: 1, opacity: 0.8 }}
                  />
                ))
              ) : (
                <>
                  {animationIndex > 0 && (
                    <Polyline
                      positions={track.slice(0, animationIndex + 1).map((point) => [point.lat, point.lon])}
                      pathOptions={{ color: 'yellow', weight: 1, opacity: 0.8 }}
                    />
                  )}
                </>
              )}

              {!showFullTrack && track.length > 0 && (
                <Marker
                  position={[track[animationIndex].lat, track[animationIndex].lon]}
                  icon={radarIcon}
                />
              )}
            </>
          )}
        </MapContainer>
      </div>
    </div>
  ));
};

export default AirportMap;
