import React, { useId } from 'react';

interface PaginationProps {
  page: number;
  pageSize: number;
  totalItems: number;
  totalPages: number;
  startItem: number;
  endItem: number;
  onPageChange: (page: number) => void;
  onPageSizeChange: (pageSize: number) => void;
}

const Pagination: React.FC<PaginationProps> = ({
  page,
  pageSize,
  totalItems,
  totalPages,
  startItem,
  endItem,
  onPageChange,
  onPageSizeChange,
}) => {
  const pageSizeId = useId();

  return (
    <div
      className="flex"
      style={{ justifyContent: 'space-between', alignItems: 'center', gap: '1rem', flexWrap: 'wrap', marginTop: '1rem' }}
    >
      <span style={{ color: 'var(--color-text-secondary)' }}>
        Showing {startItem}-{endItem} of {totalItems}
      </span>
      <div className="flex" style={{ alignItems: 'center', gap: '0.5rem' }}>
        <label htmlFor={pageSizeId} style={{ color: 'var(--color-text-secondary)' }}>
          Rows per page
        </label>
        <select
          id={pageSizeId}
          className="input"
          value={pageSize}
          onChange={(event) => onPageSizeChange(Number(event.target.value))}
          style={{ width: 'auto' }}
        >
          {[10, 25, 50].map((size) => (
            <option key={size} value={size}>{size}</option>
          ))}
        </select>
        <button
          type="button"
          className="btn btn-secondary"
          onClick={() => onPageChange(page - 1)}
          disabled={page <= 1}
        >
          Previous
        </button>
        <span style={{ color: 'var(--color-text-secondary)', whiteSpace: 'nowrap' }}>
          Page {page} of {totalPages}
        </span>
        <button
          type="button"
          className="btn btn-secondary"
          onClick={() => onPageChange(page + 1)}
          disabled={page >= totalPages}
        >
          Next
        </button>
      </div>
    </div>
  );
};

export default Pagination;
