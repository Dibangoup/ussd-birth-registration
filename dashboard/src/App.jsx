import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import DashboardPage from "./Pages/DashbordPage";
import DeclarationsPage from "./Pages/DeclarationsPage";
import ParentsPage from "./Pages/ParentsPage";
import StatistiquesPage from "./Pages/StatistiquesPage";
import LieuxPage from "./Pages/LieuxPage";
import DemandesPage from "./Pages/DemandesPage";
import "./App.css";

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<DashboardPage />} />
        <Route path="/declarations" element={<DeclarationsPage />} />
        <Route path="/parents" element={<ParentsPage />} />
        <Route path="/statistiques" element={<StatistiquesPage />} />
        <Route path="/lieux" element={<LieuxPage />} />
        <Route path="/demandes" element={<DemandesPage />} />
      </Routes>
    </Router>
  );
}

export default App;