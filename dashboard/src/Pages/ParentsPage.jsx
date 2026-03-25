import { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../components/Sidebar/Sidebar";
import "./PageStyles.css";

const ParentsPage = () => {
  const [parents, setParents] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    axios.get("http://localhost:8000/api/parents")
      .then((res) => { setParents(res.data); setLoading(false); })
      .catch((err) => { console.error(err); setLoading(false); });
  }, []);

  return (
    <div className="layout">
      <Sidebar />
      <main className="main-content">
        <div className="page-header">
          <h1 className="page-title">Parents / Déclarants</h1>
          <span className="page-subtitle">{parents.length} parent(s) enregistré(s)</span>
        </div>

        <div className="page-table-card">
          {loading ? (
            <p className="empty-msg">Chargement...</p>
          ) : parents.length === 0 ? (
            <p className="empty-msg">Aucun parent trouvé dans la base de données.</p>
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
                {parents.map((p, i) => (
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
