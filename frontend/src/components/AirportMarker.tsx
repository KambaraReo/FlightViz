import { Marker, Popup } from 'react-leaflet';
import L from 'leaflet';
import markerStyles from './AirportMarker.module.css';
import popupStyles from './AirportPopup.module.css';

interface Props {
  lat: number;
  lon: number;
  name: string;
}

const AirportMarker: React.FC<Props>= ({ lat, lon, name }) => {
  const airportIcon = L.divIcon({
    className: '',
    html: `<div class="${markerStyles['glow-marker']}"></div>`,
    iconSize: [10, 10],
    iconAnchor: [5, 5],
  });

  return (
    <Marker position={[lat, lon]} icon={airportIcon}>
      <Popup>
        <div className={popupStyles['glow-popup']}>
          <strong>{name}</strong><br />
          LAT: {lat.toFixed(2)}<br />
          LON: {lon.toFixed(2)}
        </div>
      </Popup>
    </Marker>
  );
}

export default AirportMarker;
