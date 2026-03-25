import { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../components/Sidebar/Sidebar";
import "./PageStyles.css";

const StatistiquesPage = () => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    axios.get("http://localhost:8000/api/statistiques")
      .then((res) => { setStats(res.data); setLoading(false); })
      .catch((err) => { console.error(err); setLoading(false); });
  }, []);

  if (loading) return (
    <div className="layout"><Sidebar /><main className="main-content"><p className="empty-msg">Chargement...</p></main></div>
  );

  return (
    <div className="layout">
      <Sidebar />
      <main className="main-content">
        <div className="page-header">
          <h1 className="page-title">Statistiques</h1>
          <span className="page-subtitle">Vue d'ensemble complète</span>
        </div>

        <div className="stats-grid">
          <div className="stat-block stat-block--purple">
            <span className="stat-block-value">{stats?.total || 0}</span>
            <span className="stat-block-label">Total déclarations</span>
          </div>
          <div className="stat-block stat-block--green">
            <span className="stat-block-value">{stats?.valides || 0}</span>
            <span className="stat-block-label">Validées</span>
          </div>
          <div className="stat-block stat-block--red">
            <span className="stat-block-value">{stats?.rejetees || 0}</span>
            <span className="stat-block-label">Rejetées</span>
          </div>
          <div className="stat-block stat-block--orange">
            <span className="stat-block-value">{stats?.en_attente || 0}</span>
            <span className="stat-block-label">En attente</span>
          </div>
          <div className="stat-block stat-block--blue">
            <span className="stat-block-value">{stats?.garcons || 0}</span>
            <span className="stat-block-label">Garçons</span>
          </div>
          <div className="stat-block stat-block--pink">
            <span className="stat-block-value">{stats?.filles || 0}</span>
            <span className="stat-block-label">Filles</span>
          </div>
          <div className="stat-block stat-block--teal">
            <span className="stat-block-value">{stats?.localites || 0}</span>
            <span className="stat-block-label">Localités actives</span>
          </div>
          <div className="stat-block stat-block--dark">
            <span className="stat-block-value">{stats?.parents || 0}</span>
            <span className="stat-block-label">Parents enregistrés</span>
          </div>
        </div>
      </main>
    </div>
  );
};

export default StatistiquesPage;
