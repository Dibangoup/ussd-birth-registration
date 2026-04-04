import { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../components/Sidebar/Sidebar";
import StatCard from "../components/Dashbord/StatCard";
import BirthChart from "../components/Dashbord/BirthChart";
import Calendar from "../components/Dashbord/Calendar";
import DeclaTable from "../components/Dashbord/DeclaTable";
import "./DashbordPage.css";

const DashboardPage = () => {
  const [period, setPeriod] = useState("Mois");
  const [search, setSearch] = useState("");
  const [stats, setStats] = useState({
    valides: 0,
    recues: 0,
    rejetees: 0,
    en_attente: 0
  });

  useEffect(() => {
    axios.get(`http://localhost:8000/api/dashboard/stats?period=${period}`)
      .then((res) => setStats(res.data))
      .catch((err) => console.error("Erreur API stats:", err));
  }, [period]);

  return (
    <div className="layout">
      <Sidebar />

      <main className="main-content">
        
        {/* Header */}

        <div className="page-header">
          <h1 className="page-title">Tableau de bord</h1>
          <div className="header-controls">
            <div className="period-tabs">
              {["Jour", "Semaine", "Mois", "Année"].map((p) => (
                <button 
                  key={p} 
                  className={`period-tab ${p === period ? "active" : ""}`}
                  onClick={() => setPeriod(p)}
                >
                  {p}
                </button>
              ))}
            </div>
            <span className="date-range">11 Mar 2026 – 31 Sept. 2026</span>
            <input className="search-input" placeholder="Rechercher..." />
          </div>
        </div>

        {/* Stat Cards */}

        <div className="stat-cards-row">
          <StatCard
            title="Déclarations Enregistrée(s)"
            value={stats.valides}
            trend="+1.62%"
            trendLabel={`sur la période (${period})`}
            color="dark"
          />
          <StatCard
            title="Déclarations reçue(s)"
            value={stats.recues}
            trend="+1.62%"
            trendLabel={`sur la période (${period})`}
            color="green"
          />
          <StatCard
            title="Demande rejetée(s)"
            value={stats.rejetees}
            trend="-1.62%"
            trendLabel={`sur la période (${period})`}
            color="red"
          />
          <StatCard
            title="Demande en attente(s)"
            value={stats.en_attente}
            trend="+0.09%"
            trendLabel={`sur la période (${period})`}
            color="default"
          />
        </div>

        {/* Chart + Calendar */}

        <div className="chart-row">
          <BirthChart period={period} />
          <Calendar period={period} />
        </div>

        {/* Table */}
        <DeclaTable />
      </main>
    </div>
  );
};

export default DashboardPage;
