import StatusBadge from "../ui/StatusBadge";
import "./DeclaTable.css";

const declarations = [
  { id: 1, localite: "Béoumi",     pere: "kouakou thomas", mere: "kouakou amoin", heure: "00h15min", date: "21/01/2026", enfant: "Konan kouadio",  sexe: "M", statut: "Enregistrée" },
  { id: 2, localite: "Kouakoukro", pere: "kouakou amoin",  mere: "Kouassi Eve",   heure: "10h50min", date: "08/02/2026", enfant: "Kouassi edvige", sexe: "F", statut: "Rejetée"     },
  { id: 3, localite: "Mankono",    pere: "kouakou amoin",  mere: "Koné fatou",    heure: "03h20min", date: "01/03/2026", enfant: "Koné noussa",    sexe: "M", statut: "En attente"  },
  { id: 4, localite: "Gbaipleu",   pere: "kouakou amoin",  mere: "Gba anne",      heure: "01h00min", date: "09/03/2026", enfant: "Gba solange",    sexe: "F", statut: "Enregistrée" },
  { id: 5, localite: "Gbaipleu",   pere: "kouakou amoin",  mere: "Gba anne",      heure: "12h39min", date: "09/03/2026", enfant: "Gba solange",    sexe: "F", statut: "Enregistrée" },
];

const DeclaTable = () => {
  return (
    <div className="decla-table-card">
      <div className="decla-table-header">
        <h3 className="decla-table-title">Déclarations</h3>
        <div className="decla-table-actions">
          <button className="icon-btn">↻</button>
          <button className="icon-btn">↗</button>
        </div>
      </div>

      <div className="table-wrapper">
        <table className="decla-table">
          <thead>
            <tr>
              <th>Localité</th>
              <th>Nom du père</th>
              <th>Nom de la mère</th>
              <th>Heure</th>
              <th>Date de naissance</th>
              <th>Nom de l'enfant</th>
              <th>Sexe de l'enfant</th>
              <th>Statut de la demande</th>
            </tr>
          </thead>
          <tbody>
            {declarations.map((d) => (
              <tr key={d.id}>
                <td>
                  <span className="row-num">{d.id}</span>
                  {d.localite}
                </td>
                <td>{d.pere}</td>
                <td>{d.mere}</td>
                <td>{d.heure}</td>
                <td>{d.date}</td>
                <td>{d.enfant}</td>
                <td>{d.sexe}</td>
                <td><StatusBadge status={d.statut} /></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default DeclaTable;