import './App.css'
import 'leaflet/dist/leaflet.css'
import { Routes, Route } from "react-router-dom";
import FlightMapPage from "./pages";

function App() {
  return (
    <Routes>
      <Route path="/" element={<div>Home Page</div>} />
      <Route path="/tracks/map" element={<FlightMapPage />} />
    </Routes>
  );
}

export default App
