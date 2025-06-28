import { useState } from "react";
import AirportMap from "../components/AirportMap";
import FlightSelector from "../components/FlightSelector";
import AltitudeControls from '../components/AltitudeControls';

const FlightMapPage = () => {
  const defaultFlightId = 'AP00520';
  const [flightId, setFlightId] = useState<string>(defaultFlightId);
  const [colorByAltitude, setColorByAltitude] = useState(false);

  return (
    <div className="overflow-x-auto">
      <div className="flex flex-col md:flex-row w-full md:min-w-[1024px] h-[760px]">
        <div className="order-2 md:order-1 w-full md:w-[75%] h-full">
          <AirportMap
            flightId={flightId}
            colorByAltitude={colorByAltitude}
          />
        </div>
        <div className="order-1 md:order-2 w-full md:w-[25%] h-auto flex flex-col items-center gap-4 p-4 bg-black border-t md:border-t-0 md:border-l border-green-500">
          <FlightSelector
            flightId={flightId}
            setFlightId={setFlightId}
          />
          <AltitudeControls
            colorByAltitude={colorByAltitude}
            setColorByAltitude={setColorByAltitude}
          />
        </div>
      </div>
    </div>
  );
};

export default FlightMapPage;
