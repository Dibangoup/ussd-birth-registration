import { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../components/Sidebar/Sidebar";
import "./PageStyles.css";

const POLL_INTERVAL = 10000;

const LieuxPage = () => {
  const [lieux, setLieux] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  const fetchLieux = () => {
    axios.get("http://localhost:8000/api/localites")
      .then((res) => { setLieux(res.data); setLoading(false); })
      .catch((err) => { console.error(err); setLoading(false); });
  };

  useEffect(() => {
    fetchLieux();
    const interval = setInterval(fetchLieux, POLL_INTERVAL);
    return () => clearInterval(interval);
  }, []);

  const filtered = lieux.filter((l) => {
    const q = search.toLowerCase();
    return (
      (l.nom || "").toLowerCase().includes(q) ||
      (l.type || "").toLowerCase().includes(q)
    );
  });

  return (
    <div className="layout">
      <Sidebar />
      <main className="main-content">
        <div className="page-header">
          <h1 className="page-title">Lieux de naissance</h1>
          <span className="page-subtitle">{filtered.length} localité(s) enregistrée(s)</span>
        </div>

        <div className="page-table-card">
          <div className="search-bar-wrapper">
            <span className="search-bar-icon">🔍</span>
            <input
              id="search-lieux"
              className="search-bar"
              type="text"
              placeholder="Rechercher par nom ou type de localité..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>

          {loading ? (
            <p className="empty-msg">Chargement...</p>
          ) : filtered.length === 0 ? (
            <p className="search-no-results">Aucun résultat pour « {search} »</p>
          ) : (
            <table className="page-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>Nom de la localité</th>
                  <th>Type</th>
                  <th>Nombre de naissances</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((l, i) => (
                  <tr key={l.id || i}>
                    <td>{i + 1}</td>
                    <td className="cell-bold">{l.nom}</td>
                    <td>{l.type}</td>
                    <td>{l.nb_naissances}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </main>
    </div>
  );
};

export default LieuxPage;
