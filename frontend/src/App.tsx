import './App.css'
import 'leaflet/dist/leaflet.css'
import { Routes, Route } from "react-router-dom";

function App() {
  return (
    <Routes>
      <Route path="/" element={<div>Home Page</div>} />
    </Routes>
  );
}

export default App
