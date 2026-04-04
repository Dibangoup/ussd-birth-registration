import { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../components/Sidebar/Sidebar";
import StatusBadge from "../components/ui/StatusBadge";
import "./PageStyles.css";

const POLL_INTERVAL = 10000;

const DemandesPage = () => {
  const [demandes, setDemandes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [period, setPeriod] = useState("Mois");
  const [statusFilter, setStatusFilter] = useState("Tous");
  const [sortKey, setSortKey] = useState(null);
  const [sortDir, setSortDir] = useState("asc");

  const fetchDemandes = () => {
    const params = new URLSearchParams();
    params.set("period", period);
    if (statusFilter !== "Tous") {
      // Map display labels back to backend values
      const statusMap = { "En attente": "en_attente", "Enregistrée": "valide", "Rejetée": "rejete" };
      params.set("statut", statusMap[statusFilter] || statusFilter);
    }
    axios.get(`http://localhost:8000/api/demandes?${params.toString()}`)
      .then((res) => { setDemandes(res.data); setLoading(false); })
      .catch((err) => { console.error(err); setLoading(false); });
  };

  useEffect(() => {
    setLoading(true);
    fetchDemandes();
    const interval = setInterval(fetchDemandes, POLL_INTERVAL);
    return () => clearInterval(interval);
  }, [period, statusFilter]);

  const updateStatut = (id, newStatut) => {
    axios.patch(`http://localhost:8000/api/demandes/${id}`, { statut: newStatut })
      .then(() => {
        setDemandes(prev => prev.map(d => d.id === id ? { ...d, statut: newStatut === "valide" ? "Enregistrée" : "Rejetée" } : d));
      })
      .catch((err) => console.error("Erreur:", err));
  };

  // Filtrage recherche textuelle
  const filtered = demandes.filter((d) => {
    if (search.trim() === "") return true;
    const q = search.toLowerCase();
    return (
      (d.enfant || "").toLowerCase().includes(q) ||
      (d.sexe || "").toLowerCase().includes(q) ||
      (d.date || "").toLowerCase().includes(q) ||
      (d.telephone || "").toLowerCase().includes(q) ||
      (d.statut || "").toLowerCase().includes(q)
    );
  });

  // Tri
  const handleSort = (key) => {
    if (sortKey === key) {
      setSortDir(sortDir === "asc" ? "desc" : "asc");
    } else {
      setSortKey(key);
      setSortDir("asc");
    }
  };

  const sorted = [...filtered].sort((a, b) => {
    if (!sortKey) return 0;
    const va = (a[sortKey] || "").toLowerCase();
    const vb = (b[sortKey] || "").toLowerCase();
    if (va < vb) return sortDir === "asc" ? -1 : 1;
    if (va > vb) return sortDir === "asc" ? 1 : -1;
    return 0;
  });

  const SortArrow = ({ col }) => (
    <span className={`sort-arrow ${sortKey === col ? "active" : ""}`}>
      {sortKey === col ? (sortDir === "asc" ? "▲" : "▼") : "⇅"}
    </span>
  );

  return (
    <div className="layout">
      <Sidebar />
      <main className="main-content">
        <div className="page-header">
          <h1 className="page-title">Demandes</h1>
          <span className="page-subtitle">Validez ou rejetez les déclarations</span>
        </div>

        <div className="page-table-card">
          {/* Barre de filtres */}
          <div className="filter-bar">
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

            <select
              className="status-select"
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
            >
              <option value="Tous">Tous les statuts</option>
              <option value="En attente">En attente</option>
              <option value="Enregistrée">Enregistrée</option>
              <option value="Rejetée">Rejetée</option>
            </select>

            <div className="search-bar-wrapper">
              <span className="search-bar-icon">🔍</span>
              <input
                id="search-demandes"
                className="search-bar"
                type="text"
                placeholder="Rechercher par nom, téléphone..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>

            <span className="filter-count">{sorted.length} résultat(s)</span>
          </div>

          {loading ? (
            <p className="empty-msg">Chargement...</p>
          ) : sorted.length === 0 ? (
            <p className="search-no-results">Aucun résultat pour les filtres sélectionnés</p>
          ) : (
            <table className="page-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th className="sortable" onClick={() => handleSort("enfant")}>Enfant <SortArrow col="enfant" /></th>
                  <th className="sortable" onClick={() => handleSort("sexe")}>Sexe <SortArrow col="sexe" /></th>
                  <th className="sortable" onClick={() => handleSort("date")}>Date <SortArrow col="date" /></th>
                  <th>Déclarant (Tél.)</th>
                  <th className="sortable" onClick={() => handleSort("statut")}>Statut <SortArrow col="statut" /></th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {sorted.map((d, i) => (
                  <tr key={d.id || i}>
                    <td>{i + 1}</td>
                    <td className="cell-bold">{d.enfant}</td>
                    <td>{d.sexe}</td>
                    <td>{d.date}</td>
                    <td>{d.telephone}</td>
                    <td><StatusBadge status={d.statut} /></td>
                    <td className="action-btns">
                      {d.statut === "En attente" && (
                        <>
                          <button className="btn-validate" onClick={() => updateStatut(d.id, "valide")}>✓ Valider</button>
                          <button className="btn-reject" onClick={() => updateStatut(d.id, "rejete")}>✗ Rejeter</button>
                        </>
                      )}
                    </td>
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

export default DemandesPage;
