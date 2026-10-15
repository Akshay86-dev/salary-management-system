import React, { useEffect, useState } from 'react';
import dashboardService, { DashboardStats } from '../services/dashboardService';
import { errorMessage } from '../services/errorMessage';

type Distribution = { name: string; count: number };

interface DistributionChartProps {
  title: string;
  items: Distribution[];
  total: number;
  type: 'pie' | 'bar';
}

const chartColors = [
  'var(--color-primary)',
  'var(--color-info)',
  'var(--color-success)',
  'var(--color-warning)',
  'var(--color-error)',
  '#8b5cf6',
  '#ec4899',
  '#14b8a6',
  '#f97316',
  '#6366f1',
  '#84cc16',
  '#06b6d4'
];

const pieSlicePath = (startAngle: number, endAngle: number) => {
  const center = 120;
  const radius = 112;
  const pointAt = (angle: number) => {
    const radians = (angle * Math.PI) / 180;
    return {
      x: center + radius * Math.cos(radians),
      y: center + radius * Math.sin(radians)
    };
  };
  const start = pointAt(startAngle);

  if (endAngle - startAngle >= 360) {
    const opposite = pointAt(startAngle + 180);
    return [
      `M ${center} ${center}`,
      `L ${start.x} ${start.y}`,
      `A ${radius} ${radius} 0 1 1 ${opposite.x} ${opposite.y}`,
      `A ${radius} ${radius} 0 1 1 ${start.x} ${start.y}`,
      'Z'
    ].join(' ');
  }

  const end = pointAt(endAngle);
  const largeArc = endAngle - startAngle > 180 ? 1 : 0;

  return [
    `M ${center} ${center}`,
    `L ${start.x} ${start.y}`,
    `A ${radius} ${radius} 0 ${largeArc} 1 ${end.x} ${end.y}`,
    'Z'
  ].join(' ');
};

const DistributionChart: React.FC<DistributionChartProps> = ({ title, items, total, type }) => {
  const [selected, setSelected] = useState<string | null>(null);
  const chartTotal = items.reduce((sum, item) => sum + item.count, 0);
  const maxCount = Math.max(...items.map((item) => item.count), 1);
  const selectedItem = items.find((item) => item.name === selected);
  const percentage = selectedItem && total > 0
    ? ((selectedItem.count / total) * 100).toFixed(1)
    : null;
  let angle = 0;
  const pieSegments = items.map((item, index) => {
    const start = angle;
    angle += chartTotal > 0 ? (item.count / chartTotal) * 360 : 0;
    return {
      item,
      index,
      startAngle: start - 90,
      endAngle: angle - 90
    };
  });

  return (
    <section className="card" aria-label={title}>
      <h2 style={{ color: 'var(--color-text-primary)', fontSize: '1.125rem', marginBottom: '1rem' }}>
        {title}
      </h2>

      {items.length === 0 ? (
        <p style={{ color: 'var(--color-text-secondary)' }}>No employee data available.</p>
      ) : (
        <>
          {type === 'pie' ? (
            <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', justifyContent: 'center', gap: '2rem' }}>
              <svg
                role="group"
                aria-label={`${title} pie chart`}
                viewBox="0 0 240 240"
                style={{ width: 'min(15rem, 65vw)', aspectRatio: '1', flexShrink: 0 }}
              >
                {chartTotal > 0 ? pieSegments.map(({ item, index, startAngle, endAngle }) => {
                  if (item.count <= 0) return null;

                  const isSelected = selected === item.name;
                  const itemPercentage = ((item.count / total) * 100).toFixed(1);

                  return (
                    <path
                      key={item.name}
                      className="pie-chart-slice"
                      d={pieSlicePath(startAngle, endAngle)}
                      fill={chartColors[index % chartColors.length]}
                      stroke={isSelected ? 'var(--color-text-primary)' : 'var(--color-bg-primary)'}
                      strokeWidth={isSelected ? 4 : 1}
                      opacity={selected && !isSelected ? 0.45 : 1}
                      role="button"
                      tabIndex={0}
                      aria-label={`${item.name}: ${item.count.toLocaleString()} employees (${itemPercentage}%)`}
                      aria-pressed={isSelected}
                      onClick={() => setSelected(isSelected ? null : item.name)}
                      onKeyDown={(event) => {
                        if (event.key === 'Enter' || event.key === ' ') {
                          event.preventDefault();
                          setSelected(isSelected ? null : item.name);
                        }
                      }}
                      style={{ cursor: 'pointer', transition: 'opacity 150ms ease' }}
                    >
                      <title>{`${item.name}: ${item.count.toLocaleString()} employees (${itemPercentage}%)`}</title>
                    </path>
                  );
                }) : (
                  <circle cx="120" cy="120" r="112" fill="var(--color-bg-tertiary)" />
                )}
              </svg>
              <div style={{ display: 'grid', gap: '0.5rem', flex: '1 1 12rem' }}>
                {items.map((item, index) => {
                  const isSelected = selected === item.name;
                  return (
                    <button
                      key={item.name}
                      type="button"
                      aria-pressed={isSelected}
                      onClick={() => setSelected(isSelected ? null : item.name)}
                      style={{
                        display: 'grid',
                        gridTemplateColumns: 'minmax(0, 1fr) auto',
                        alignItems: 'center',
                        gap: '0.75rem',
                        width: '100%',
                        padding: '0.35rem',
                        border: isSelected ? '1px solid var(--color-primary)' : '1px solid transparent',
                        borderRadius: '0.375rem',
                        background: isSelected ? 'var(--color-bg-accent)' : 'transparent',
                        color: 'var(--color-text-primary)',
                        textAlign: 'left',
                        cursor: 'pointer'
                      }}
                    >
                      <span style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', minWidth: 0 }}>
                        <span
                          aria-hidden="true"
                          style={{
                            width: '0.75rem',
                            height: '0.75rem',
                            flexShrink: 0,
                            borderRadius: '50%',
                            background: chartColors[index % chartColors.length]
                          }}
                        />
                        <span style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                          {item.name}
                        </span>
                      </span>
                      <strong style={{ minWidth: '2.5rem', textAlign: 'right' }}>{item.count.toLocaleString()}</strong>
                    </button>
                  );
                })}
              </div>
            </div>
          ) : (
            <div style={{ display: 'grid', gap: '0.75rem' }}>
              {items.map((item) => {
                const isSelected = selected === item.name;
                return (
                  <button
                    key={item.name}
                    type="button"
                    aria-pressed={isSelected}
                    onClick={() => setSelected(isSelected ? null : item.name)}
                    style={{
                      display: 'grid',
                      gridTemplateColumns: 'minmax(6rem, 1fr) minmax(5rem, 2fr) auto',
                      alignItems: 'center',
                      gap: '0.75rem',
                      width: '100%',
                      padding: '0.35rem',
                      border: isSelected ? '1px solid var(--color-primary)' : '1px solid transparent',
                      borderRadius: '0.375rem',
                      background: isSelected ? 'var(--color-bg-accent)' : 'transparent',
                      color: 'var(--color-text-primary)',
                      textAlign: 'left',
                      cursor: 'pointer'
                    }}
                  >
                    <span style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                      {item.name}
                    </span>
                    <span
                      aria-hidden="true"
                      style={{
                        height: '0.7rem',
                        overflow: 'hidden',
                        borderRadius: '999px',
                        background: 'var(--color-bg-tertiary)'
                      }}
                    >
                      <span
                        style={{
                          display: 'block',
                          width: `${(item.count / maxCount) * 100}%`,
                          height: '100%',
                          borderRadius: 'inherit',
                          background: isSelected ? 'var(--color-primary)' : 'var(--color-info)'
                        }}
                      />
                    </span>
                    <strong style={{ minWidth: '2.5rem', textAlign: 'right' }}>{item.count.toLocaleString()}</strong>
                  </button>
                );
              })}
            </div>
          )}

          <p aria-live="polite" style={{ minHeight: '1.5rem', marginTop: '1rem', color: 'var(--color-text-secondary)' }}>
            {selectedItem && percentage !== null
              ? `${selectedItem.name}: ${selectedItem.count.toLocaleString()} employees (${percentage}%). Click again to clear.`
              : `Select a ${type === 'pie' ? 'category' : 'bar'} to highlight its employee count.`}
          </p>
        </>
      )}
    </section>
  );
};

const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        setStats(await dashboardService.getStats());
      } catch (err) {
        setError(errorMessage(err, 'Failed to load dashboard stats'));
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  return (
    <div>
      <h1 style={{ marginBottom: '1rem', color: 'var(--color-text-primary)' }}>Dashboard</h1>
      {error && (
        <div style={{ color: 'var(--color-error)', padding: '1rem' }} role="alert">
          {error}
        </div>
      )}
      <div className="grid">
        <div className="card">
          <h3 style={{ color: 'var(--color-text-secondary)', marginBottom: '0.5rem' }}>Total Departments</h3>
          <p style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--color-primary)' }}>
            {loading ? '…' : stats?.total_departments ?? 0}
          </p>
        </div>
        <div className="card">
          <h3 style={{ color: 'var(--color-text-secondary)', marginBottom: '0.5rem' }}>Total Employees</h3>
          <p style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--color-primary)' }}>
            {loading ? '…' : stats?.total_employees ?? 0}
          </p>
        </div>
        <div className="card">
          <h3 style={{ color: 'var(--color-text-secondary)', marginBottom: '0.5rem' }}>Total Countries</h3>
          <p style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--color-primary)' }}>
            {loading ? '…' : stats?.total_countries ?? 0}
          </p>
        </div>
      </div>

      {loading ? (
        <div className="flex-center" style={{ padding: '2rem' }}>
          <span className="loader" aria-label="Loading employee distributions" />
        </div>
      ) : stats && (
        <div className="grid" style={{ marginTop: '1rem', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))' }}>
          <DistributionChart
            title="Employees by Department"
            items={stats.employees_by_department || []}
            total={stats.total_employees}
            type="pie"
          />
          <DistributionChart
            title="Employees by Country"
            items={stats.employees_by_country || []}
            total={stats.total_employees}
            type="pie"
          />
        </div>
      )}
    </div>
  );
};

export default Dashboard;
