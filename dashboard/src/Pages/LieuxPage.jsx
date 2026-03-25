import { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../components/Sidebar/Sidebar";
import "./PageStyles.css";

const LieuxPage = () => {
  const [lieux, setLieux] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    axios.get("http://localhost:8000/api/localites")
      .then((res) => { setLieux(res.data); setLoading(false); })
      .catch((err) => { console.error(err); setLoading(false); });
  }, []);

  return (
    <div className="layout">
      <Sidebar />
      <main className="main-content">
        <div className="page-header">
          <h1 className="page-title">Lieux de naissance</h1>
          <span className="page-subtitle">{lieux.length} localité(s) enregistrée(s)</span>
        </div>

        <div className="page-table-card">
          {loading ? (
            <p className="empty-msg">Chargement...</p>
          ) : lieux.length === 0 ? (
            <p className="empty-msg">Aucune localité trouvée dans la base de données.</p>
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
                {lieux.map((l, i) => (
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
