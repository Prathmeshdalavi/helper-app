-- M1: customer accounts, OTP challenges, refresh tokens, auth rate limits.

CREATE TABLE users (
    id                uuid         PRIMARY KEY,
    phone_e164        varchar(16)  NOT NULL,
    full_name         varchar(60)  NOT NULL,
    email             varchar(254),
    role              varchar(20)  NOT NULL DEFAULT 'CUSTOMER',
    status            varchar(20)  NOT NULL DEFAULT 'ACTIVE',
    terms_accepted_at timestamptz,
    created_at        timestamptz  NOT NULL DEFAULT now(),
    updated_at        timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_users_phone  UNIQUE (phone_e164),
    CONSTRAINT chk_users_phone CHECK (phone_e164 ~ '^\+91[6-9][0-9]{9}$'),
    CONSTRAINT chk_users_name  CHECK (char_length(btrim(full_name)) >= 2),
    CONSTRAINT chk_users_role  CHECK (role IN ('CUSTOMER', 'HELPER', 'ADMIN')),
    CONSTRAINT chk_users_status CHECK (status IN ('ACTIVE', 'BLOCKED'))
);

CREATE TABLE otp_challenges (
    id           uuid        PRIMARY KEY,
    phone_e164   varchar(16) NOT NULL,
    code_hash    varchar(64) NOT NULL,          -- HMAC-SHA256 hex, never the code itself
    expires_at   timestamptz NOT NULL,
    attempts     integer     NOT NULL DEFAULT 0,
    max_attempts integer     NOT NULL,
    status       varchar(16) NOT NULL DEFAULT 'ACTIVE',
    created_at   timestamptz NOT NULL DEFAULT now(),
    updated_at   timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT chk_otp_status   CHECK (status IN ('ACTIVE', 'CONSUMED', 'INVALIDATED', 'LOCKED', 'EXPIRED')),
    CONSTRAINT chk_otp_attempts CHECK (attempts >= 0 AND max_attempts > 0)
);

-- At most one live challenge per phone, enforced by the database.
CREATE UNIQUE INDEX uq_otp_one_active_per_phone ON otp_challenges (phone_e164) WHERE status = 'ACTIVE';
CREATE INDEX ix_otp_phone_created ON otp_challenges (phone_e164, created_at DESC);

CREATE TABLE refresh_tokens (
    id             uuid        PRIMARY KEY,
    user_id        uuid        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    family_id      uuid        NOT NULL,         -- one login = one family; reuse revokes the family
    token_hash     varchar(64) NOT NULL,         -- SHA-256 hex of the opaque token
    expires_at     timestamptz NOT NULL,
    revoked_at     timestamptz,
    replaced_by_id uuid,
    created_at     timestamptz NOT NULL DEFAULT now(),
    updated_at     timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_refresh_token_hash UNIQUE (token_hash)
);
CREATE INDEX ix_refresh_user   ON refresh_tokens (user_id);
CREATE INDEX ix_refresh_family ON refresh_tokens (family_id);

-- Fixed-window counters. Keys hold hashed identifiers, never raw phone numbers or IPs.
CREATE TABLE auth_rate_limits (
    rl_key       varchar(128) NOT NULL,
    window_start timestamptz  NOT NULL,
    hits         integer      NOT NULL,
    PRIMARY KEY (rl_key, window_start)
);
CREATE INDEX ix_rate_limits_window ON auth_rate_limits (window_start);
