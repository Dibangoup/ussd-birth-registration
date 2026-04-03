import Sidebar from "../components/Sidebar/Sidebar";
import StatCard from "../components/Dashbord/StatCard";
import BirthChart from "../components/Dashbord/BirthChart";
import Calendar from "../components/Dashbord/Calendar";
import DeclaTable from "../components/Dashbord/DeclaTable";
import "./DashbordPage.css";

const DashboardPage = () => {
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
                <button key={p} className={`period-tab ${p === "Mois" ? "active" : ""}`}>
                  {p}
                </button>
              ))}
            </div>
            <span className="date-range">21 Mar 2026 – 31 Sept. 2026</span>
            <input className="search-input" placeholder="Rechercher..." />
          </div>
        </div>

        {/* Stat Cards */}

        <div className="stat-cards-row">
          <StatCard
            title="Déclarations Enregistrée(s)"
            value="1602"
            trend="+1.62%"
            trendLabel="par rapport au mois dernier"
            color="dark"
          />
          <StatCard
            title="Déclarations reçue(s)"
            value="2315"
            trend="+1.62%"
            trendLabel="par rapport au mois dernier"
            color="green"
          />
          <StatCard
            title="Demande rejetée(s)"
            value="157"
            trend="-1.62%"
            trendLabel="par rapport au mois dernier"
            color="red"
          />
          <StatCard
            title="Demande en attente(s)"
            value="203"
            trend="+0.09%"
            trendLabel="par rapport au mois dernier"
            color="default"
          />
        </div>

        {/* Chart + Calendar */}

        <div className="chart-row">
          <BirthChart />
          <Calendar />
        </div>

        {/* Table */}
        
        <DeclaTable />
      </main>
    </div>
  );
};

export default DashboardPage;