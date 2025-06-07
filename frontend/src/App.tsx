import './App.css'
import 'leaflet/dist/leaflet.css'
import { Routes, Route } from "react-router-dom";
import AirportMapPage from "./pages/AirportMap";

function App() {
  return (
    <Routes>
      <Route path="/" element={<div>Home Page</div>} />
      <Route path="/tracks/map" element={<AirportMapPage />} />
    </Routes>
  );
}

export default App
