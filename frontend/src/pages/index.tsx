import { useState } from "react";
import AirportMap from "../components/AirportMap";
import FlightSelector from "../components/FlightSelector";

const FlightMapPage = () => {
  const defaultFlightId = 'AP00520';
  const [flightId, setFlightId] = useState<string>(defaultFlightId);

  return (
    <div className="w-full h-screen">
      <FlightSelector
        flightId={flightId}
        setFlightId={setFlightId}
      />
      <AirportMap flightId={flightId} />
    </div>
  );
};

export default FlightMapPage;
