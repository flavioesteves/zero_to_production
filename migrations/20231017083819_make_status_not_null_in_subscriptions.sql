-- Add migration script here
-- We wrap whole migration in a transaction to maker sure
-- it succeeds or fails atomically
-- `sqlx` does not do it automatically for us.

BEGIN;
    -- Backfill `status`
    UPDATE subscriptions
      SET status = 'confirmed'
      WHERE status IS NULL;
    -- Make `status` mandatory
    ALTER TABLE subscriptions ALTER COLUMN status SET NOT NULL;
COMMIT;
