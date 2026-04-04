import { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../components/Sidebar/Sidebar";
import StatusBadge from "../components/ui/StatusBadge";
import "./PageStyles.css";

const DeclarationsPage = () => {
  const [declarations, setDeclarations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  useEffect(() => {
    axios.get("http://localhost:8000/api/dashboard/declarations?period=Année")
      .then((res) => { setDeclarations(res.data); setLoading(false); })
      .catch((err) => { console.error(err); setLoading(false); });
  }, []);

  const filtered = declarations.filter((d) => {
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

  return (
    <div className="layout">
      <Sidebar />
      <main className="main-content">
        <div className="page-header">
          <h1 className="page-title">Déclarations enregistrées</h1>
          <span className="page-subtitle">{filtered.length} déclaration(s) trouvée(s)</span>
        </div>

        <div className="page-table-card">
          <div className="search-bar-wrapper">
            <span className="search-bar-icon">🔍</span>
            <input
              id="search-declarations"
              className="search-bar"
              type="text"
              placeholder="Rechercher par nom, sexe, localité, statut..."
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
                  <th>Enfant</th>
                  <th>Sexe</th>
                  <th>Date de naissance</th>
                  <th>Heure</th>
                  <th>Localité</th>
                  <th>Père</th>
                  <th>Mère</th>
                  <th>Statut</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((d, i) => (
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
