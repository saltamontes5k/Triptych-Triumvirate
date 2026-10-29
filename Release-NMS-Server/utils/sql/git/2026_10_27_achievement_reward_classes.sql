-- Server-authored class eligibility for achievement reward choices/bundles.
-- Defaults preserve existing unrestricted options. This is not a wire field.
ALTER TABLE reward_options
    ADD COLUMN class_mask INT UNSIGNED NOT NULL DEFAULT 65535 AFTER enabled;
