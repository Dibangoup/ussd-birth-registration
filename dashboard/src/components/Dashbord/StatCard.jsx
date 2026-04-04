import "./StatCard.css";

const StatCard = ({ title, value, trend, trendLabel, color = "default" }) => {
  const isPositive = trend && trend.startsWith("+");

  return (
    <div className={`stat-card stat-card--${color}`}>
      <p className="stat-card__title">{title}</p>
      <p className="stat-card__value">{value}</p>
      {trend && (
        <p className="stat-card__trend">
          <span className={isPositive ? "trend-up" : "trend-down"}>{trend}</span>
          <span className="trend-label"> {trendLabel}</span>
        </p>
      )}
    </div>
  );
};

export default StatCard;