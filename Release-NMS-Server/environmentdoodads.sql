UPDATE `doors` SET `invert_state`=1 WHERE `id`=5391 AND `zone`='qeynos';
UPDATE `doors` SET `invert_state`=1, `close_timer_ms`=1, `doorisopen`=0, `keyitem`=-1 WHERE `id` IN (5391,5999,6000,6001,6002,6004,6005,6006,6018,6019,6020,6021,6038,6039,6040,6041,6042,6044,6045,6046,6047,6048,6049,6051,6052,6053,6054,6055,6056,6057,6058,6058,6059,6060,6061,6062,6063,6064,6066,6067,6068,6069,6085,6097,6098,6099) AND `zone`='akanon';
UPDATE `doors` SET `invert_state`=1, `close_timer_ms`=1, `doorisopen`=0, `keyitem`=-1 WHERE `id` IN (6037,6043,6070,6071,6072,6073) AND `zone`='akanon';
UPDATE `doors` SET `invert_state`=1, `keyitem`=-1 WHERE `id` IN (6746,6747,6748) AND `zone`='hole';
UPDATE `doors` SET `invert_state`=1, `keyitem`=-1 WHERE `id`=1412 AND `zone`='mistmoore';
UPDATE `doors` SET `invert_state`=1 WHERE `id`=7118 AND `zone`='lakeofillomen';
UPDATE `doors` SET `invert_state`=1, `keyitem`=-1 WHERE `id` IN (8844,8845,8891) AND `zone`='vexthal';
UPDATE `doors` SET `invert_state`=1, `keyitem`=-1 WHERE `id`=10972 AND `zone`='potranquility';
UPDATE `doors` SET `invert_state`=1 WHERE `id`=10950 AND `zone`='potranquility';
