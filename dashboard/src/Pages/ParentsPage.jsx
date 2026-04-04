import { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../components/Sidebar/Sidebar";
import "./PageStyles.css";

const POLL_INTERVAL = 10000;

const ParentsPage = () => {
  const [parents, setParents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  const fetchParents = () => {
    axios.get("http://localhost:8000/api/parents")
      .then((res) => { setParents(res.data); setLoading(false); })
      .catch((err) => { console.error(err); setLoading(false); });
  };

  useEffect(() => {
    fetchParents();
    const interval = setInterval(fetchParents, POLL_INTERVAL);
    return () => clearInterval(interval);
  }, []);

  const filtered = parents.filter((p) => {
    const q = search.toLowerCase();
    return (
      (p.nom_pere || "").toLowerCase().includes(q) ||
      (p.prenom_pere || "").toLowerCase().includes(q) ||
      (p.telephone_pere || "").toLowerCase().includes(q) ||
      (p.nom_mere || "").toLowerCase().includes(q) ||
      (p.prenom_mere || "").toLowerCase().includes(q) ||
      (p.telephone_mere || "").toLowerCase().includes(q)
    );
  });

  return (
    <div className="layout">
      <Sidebar />
      <main className="main-content">
        <div className="page-header">
          <h1 className="page-title">Parents / Déclarants</h1>
          <span className="page-subtitle">{filtered.length} parent(s) enregistré(s)</span>
        </div>

        <div className="page-table-card">
          <div className="search-bar-wrapper">
            <span className="search-bar-icon">🔍</span>
            <input
              id="search-parents"
              className="search-bar"
              type="text"
              placeholder="Rechercher par nom, prénom, téléphone..."
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
                  <th>Nom du père</th>
                  <th>Prénom du père</th>
                  <th>Tél. père</th>
                  <th>Nom de la mère</th>
                  <th>Prénom de la mère</th>
                  <th>Tél. mère</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((p, i) => (
                  <tr key={p.id || i}>
                    <td>{i + 1}</td>
                    <td className="cell-bold">{p.nom_pere || "—"}</td>
                    <td>{p.prenom_pere || "—"}</td>
                    <td>{p.telephone_pere || "—"}</td>
                    <td className="cell-bold">{p.nom_mere || "—"}</td>
                    <td>{p.prenom_mere || "—"}</td>
                    <td>{p.telephone_mere || "—"}</td>
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

export default ParentsPage;
