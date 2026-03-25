import { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../components/Sidebar/Sidebar";
import StatusBadge from "../components/ui/StatusBadge";
import "./PageStyles.css";

const DeclarationsPage = () => {
  const [declarations, setDeclarations] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    axios.get("http://localhost:8000/api/dashboard/declarations?period=Année")
      .then((res) => { setDeclarations(res.data); setLoading(false); })
      .catch((err) => { console.error(err); setLoading(false); });
  }, []);

  return (
    <div className="layout">
      <Sidebar />
      <main className="main-content">
        <div className="page-header">
          <h1 className="page-title">Déclarations enregistrées</h1>
          <span className="page-subtitle">{declarations.length} déclaration(s) trouvée(s)</span>
        </div>

        <div className="page-table-card">
          {loading ? (
            <p className="empty-msg">Chargement...</p>
          ) : declarations.length === 0 ? (
            <p className="empty-msg">Aucune déclaration trouvée.</p>
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
                {declarations.map((d, i) => (
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
