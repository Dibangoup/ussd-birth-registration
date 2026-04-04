import { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../components/Sidebar/Sidebar";
import StatusBadge from "../components/ui/StatusBadge";
import "./PageStyles.css";

const POLL_INTERVAL = 10000;

const DeclarationsPage = () => {
  const [declarations, setDeclarations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [period, setPeriod] = useState("Année");
  const [statusFilter, setStatusFilter] = useState("Tous");
  const [sortKey, setSortKey] = useState(null);
  const [sortDir, setSortDir] = useState("asc");

  const fetchDeclarations = () => {
    axios.get(`http://localhost:8000/api/dashboard/declarations?period=${period}`)
      .then((res) => { setDeclarations(res.data); setLoading(false); })
      .catch((err) => { console.error(err); setLoading(false); });
  };

  useEffect(() => {
    setLoading(true);
    fetchDeclarations();
    const interval = setInterval(fetchDeclarations, POLL_INTERVAL);
    return () => clearInterval(interval);
  }, [period]);

  // Filtrage par recherche textuelle + statut
  const filtered = declarations.filter((d) => {
    // Filtre statut
    if (statusFilter !== "Tous" && d.statut !== statusFilter) return false;
    // Filtre recherche
    if (search.trim() === "") return true;
    const q = search.toLowerCase();
    return (
      (d.enfant || "").toLowerCase().includes(q) ||
      (d.sexe || "").toLowerCase().includes(q) ||
      (d.date || "").toLowerCase().includes(q) ||
      (d.localite || "").toLowerCase().includes(q) ||
      (d.pere || "").toLowerCase().includes(q) ||
      (d.mere || "").toLowerCase().includes(q) ||
      (d.statut || "").toLowerCase().includes(q)
    );
  });

  // Tri par colonne
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
          <h1 className="page-title">Déclarations enregistrées</h1>
          <span className="page-subtitle">{sorted.length} déclaration(s) trouvée(s)</span>
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
                id="search-declarations"
                className="search-bar"
                type="text"
                placeholder="Rechercher par nom, sexe, localité..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
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
                  <th className="sortable" onClick={() => handleSort("date")}>Date de naissance <SortArrow col="date" /></th>
                  <th>Heure</th>
                  <th className="sortable" onClick={() => handleSort("localite")}>Localité <SortArrow col="localite" /></th>
                  <th className="sortable" onClick={() => handleSort("pere")}>Père <SortArrow col="pere" /></th>
                  <th className="sortable" onClick={() => handleSort("mere")}>Mère <SortArrow col="mere" /></th>
                  <th className="sortable" onClick={() => handleSort("statut")}>Statut <SortArrow col="statut" /></th>
                </tr>
              </thead>
              <tbody>
                {sorted.map((d, i) => (
                  <tr key={d.id || i}>
                    <td>{i + 1}</td>
                    <td className="cell-bold">{d.enfant}</td>
                    <td>{d.sexe}</td>
                    <td>{d.date}</td>
                    <td>{d.heure}</td>
                    <td>{d.localite}</td>
                    <td>{d.pere}</td>
                    <td>{d.mere}</td>
                    <td><StatusBadge status={d.statut} /></td>
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

export default DeclarationsPage;
