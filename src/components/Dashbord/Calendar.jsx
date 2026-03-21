import "./Calendar.css";

const days = ["Mar", "Mer", "Jeu", "Ven", "Sam"];
const dates = [17, 18, 19, 20, 21];
const today = 19;

const Calendar = () => {
  return (
    <div className="calendar-card">
      <div className="calendar-header">
        <button className="cal-nav">‹</button>
        <span className="cal-month">Mars 2026</span>
        <button className="cal-nav">›</button>
      </div>

      <div className="calendar-grid">
        {days.map((d, i) => (
          <div key={i} className="cal-col">
            <span className="cal-day-name">{d}</span>
            <span className={`cal-date ${dates[i] === today ? "cal-date--today" : ""}`}>
              {dates[i]}
            </span>
          </div>
        ))}
      </div>

      <div className="calendar-stat">
        <div>
          <p className="cal-stat-label">Nombre de naissance</p>
          <p className="cal-stat-trend">↑ 0.09% par rapport au mois dernier</p>
        </div>
        <div className="cal-donut">
          <svg viewBox="0 0 40 40" width="48" height="48">
            <circle cx="20" cy="20" r="16" fill="none" stroke="#f0f0f0" strokeWidth="4"/>
            <circle cx="20" cy="20" r="16" fill="none" stroke="#E84435" strokeWidth="4"
              strokeDasharray="65 35" strokeLinecap="round"
              transform="rotate(-90 20 20)"/>
            <text x="20" y="20" textAnchor="middle" dominantBaseline="central"
              fontSize="8" fontWeight="700" fill="#1a1a1a">65%</text>
          </svg>
        </div>
      </div>
    </div>
  );
};

export default Calendar;