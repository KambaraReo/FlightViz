import './App.css'
import 'leaflet/dist/leaflet.css'
import { Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import FlightMapPage from "./pages";

function App() {
  return (
    <Routes>
      <Route path="/" element={<Layout />}>
        <Route path="/tracks/map" element={<FlightMapPage />} />
      </Route>
    </Routes>
  );
}

export default App
