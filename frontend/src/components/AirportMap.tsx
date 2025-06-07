import { MapContainer, TileLayer } from 'react-leaflet';
import AirportMarker from './AirportMarker';

type Airport = {
  id: number;
  name: string;
  lat: number;
  lon: number;
};

const airports: Airport[] = [
  { id: 1, name: "羽田空港", lat: 35.5494, lon: 139.7798 },
  { id: 2, name: "成田空港", lat: 35.7719, lon: 140.3929 },
  { id: 3, name: "関西国際空港", lat: 34.4347, lon: 135.2442 },
  { id: 4, name: "中部国際空港", lat: 34.8584, lon: 136.8053 }
];

const AirportMap = () => (
  <MapContainer
    center={[36.2048, 138.2529]}
    zoom={5.0}
    className="w-full h-full"
  >
    <TileLayer
      url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
      attribution='&copy; OpenStreetMap & CartoDB'
    />
    {airports.map((airport) => (
      <AirportMarker
        key={airport.id}
        lat={airport.lat}
        lon={airport.lon}
        name={airport.name}
      />
    ))}
  </MapContainer>
);

export default AirportMap;
