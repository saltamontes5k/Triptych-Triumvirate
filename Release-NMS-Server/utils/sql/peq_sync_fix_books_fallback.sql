-- ============================================================================
-- Revert the books.id=1 ("MISSING ITEM TEXT") fallback text.
--
-- Almost every item (284,216 / 287,066) has an empty `filename`. Item text is
-- resolved through the book mechanism (`<itemid>#<filename>` -> GetBook(name)),
-- and an empty filename resolves to the empty-name book `books.id = 1`. The B4
-- "fill empty matching locals" step populated that fallback row with upstream's
-- literal placeholder 'MISSING ITEM TEXT', so every such item started rendering
-- that string. Restore the pre-merge empty text.
-- ============================================================================

UPDATE `books` SET `txtfile` = '' WHERE `id` = 1 AND `name` = '';
