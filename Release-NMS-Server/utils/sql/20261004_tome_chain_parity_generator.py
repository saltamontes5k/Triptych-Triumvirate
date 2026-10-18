#!/usr/bin/env python3
"""Extend short tome (universal) AA chains to native parity.

For every aa_custom_mapping pair where the universal chain is shorter than the
native chain, clone the missing native tail ranks into universal ids (native id
+ 20000, the house clone convention), mirroring rank columns, aa_rank_effects,
and aa_rank_prereqs. Never overwrites: any clone-id collision aborts that pair.

Usage: python tome_chain_parity.py [--apply] [--sql-out PATH]
Dry run by default. --apply writes to the DB and emits the applied SQL
(+ rollback) to --sql-out (default: stdout).
"""
import sys
import pymysql

DB = dict(host='127.0.0.1', user='eqemu', password='eqemu', database='peq', charset='utf8mb4')
MIRROR_OFFSET = 20000
RANK_COLS = ['upper_hotkey_sid', 'lower_hotkey_sid', 'title_sid', 'desc_sid',
             'cost', 'level_req', 'spell', 'spell_type', 'recast_time', 'expansion']


def chain(cur, first_rank_id):
    """Walk a rank chain, appending only ids whose aa_ranks row exists
    (dangling next_id targets are NOT counted — mirrors the loader's self-heal)."""
    ids, current, seen = [], first_rank_id, set()
    while current and current > 0 and current not in seen and len(ids) < 100:
        cur.execute("SELECT next_id FROM aa_ranks WHERE id = %s", (current,))
        row = cur.fetchone()
        if not row:
            break
        ids.append(current)
        seen.add(current)
        if row[0] is None or row[0] <= 0:
            break
        current = row[0]
    return ids


def table_cols(cur, table):
    cur.execute(f"SHOW COLUMNS FROM {table}")
    return [r[0] for r in cur.fetchall()]


def main():
    apply = '--apply' in sys.argv
    conn = pymysql.connect(**DB)
    cur = conn.cursor()

    cur.execute("SELECT original_aa_id, universal_aa_id, aa_name FROM aa_custom_mapping")
    pairs = cur.fetchall()

    plans = []
    for orig, uni, name in pairs:
        cur.execute("SELECT first_rank_id FROM aa_ability WHERE id = %s", (orig,))
        r = cur.fetchone()
        n_first = r[0] if r else 0
        cur.execute("SELECT first_rank_id FROM aa_ability WHERE id = %s", (uni,))
        r = cur.fetchone()
        u_first = r[0] if r else 0
        if not n_first or not u_first:
            print(f"SKIP {name} ({orig}->{uni}): ability row missing")
            continue
        n_chain = chain(cur, n_first)
        u_chain = chain(cur, u_first)
        if len(u_chain) >= len(n_chain):
            continue
        missing = n_chain[len(u_chain):]
        clone_ids = [n + MIRROR_OFFSET for n in missing]
        fmt = ','.join(['%s'] * len(clone_ids))
        cur.execute(f"SELECT id FROM aa_ranks WHERE id IN ({fmt})", clone_ids)
        taken = [x[0] for x in cur.fetchall()]
        if taken:
            print(f"ABORT {name} ({orig}->{uni}): clone ids already exist: {taken}")
            continue
        plans.append(dict(orig=orig, uni=uni, name=name, u_chain=u_chain,
                          missing=missing, clone_ids=clone_ids))

    print(f"Pairs needing extension: {len(plans)}")
    for p in plans:
        print(f"  {p['name']} ({p['orig']}->{p['uni']}): "
              f"{len(p['u_chain'])} -> {len(p['u_chain']) + len(p['clone_ids'])} ranks "
              f"(+{len(p['clone_ids'])}: {p['clone_ids'][0]}..{p['clone_ids'][-1]})")

    if not apply:
        print("Dry run — rerun with --apply to write.")
        return

    effect_cols = [c for c in table_cols(cur, 'aa_rank_effects') if c != 'rank_id']
    prereq_cols = [c for c in table_cols(cur, 'aa_rank_prereqs') if c != 'rank_id']
    applied_sql, rollback_sql = [], []
    all_clone_ids = []

    for p in plans:
        tail = p['u_chain'][-1]
        old_tail_next = None
        cur.execute("SELECT next_id FROM aa_ranks WHERE id = %s", (tail,))
        old_tail_next = cur.fetchone()[0]
        applied_sql.append(f"-- {p['name']} ({p['orig']} -> {p['uni']}): "
                           f"{len(p['clone_ids'])} ranks appended after {tail}")
        rollback_sql.append(f"-- {p['name']} ({p['orig']} -> {p['uni']})")
        for i, (native_id, clone_id) in enumerate(zip(p['missing'], p['clone_ids'])):
            cur.execute(
                f"SELECT {', '.join(RANK_COLS)} FROM aa_ranks WHERE id = %s", (native_id,))
            vals = cur.fetchone()
            prev_id = tail if i == 0 else p['clone_ids'][i - 1]
            next_id = p['clone_ids'][i + 1] if i + 1 < len(p['clone_ids']) else -1
            col_list = ', '.join(['id'] + RANK_COLS + ['prev_id', 'next_id'])
            cur.execute(
                f"INSERT INTO aa_ranks ({col_list}) VALUES ({', '.join(['%s'] * (len(RANK_COLS) + 3))})",
                (clone_id, *vals, prev_id, next_id))
            applied_sql.append(
                f"INSERT INTO aa_ranks ({col_list}) SELECT {clone_id}, {', '.join(RANK_COLS)}, "
                f"{prev_id}, {next_id} FROM aa_ranks WHERE id = {native_id};")
            cur.execute(
                f"INSERT INTO aa_rank_effects (rank_id, {', '.join(effect_cols)}) "
                f"SELECT %s, {', '.join(effect_cols)} FROM aa_rank_effects WHERE rank_id = %s",
                (clone_id, native_id))
            applied_sql.append(
                f"INSERT INTO aa_rank_effects (rank_id, {', '.join(effect_cols)}) "
                f"SELECT {clone_id}, {', '.join(effect_cols)} FROM aa_rank_effects WHERE rank_id = {native_id};")
            cur.execute("SELECT COUNT(*) FROM aa_rank_prereqs WHERE rank_id = %s", (native_id,))
            if cur.fetchone()[0]:
                cur.execute(
                    f"INSERT INTO aa_rank_prereqs (rank_id, {', '.join(prereq_cols)}) "
                    f"SELECT %s, {', '.join(prereq_cols)} FROM aa_rank_prereqs WHERE rank_id = %s",
                    (clone_id, native_id))
                applied_sql.append(
                    f"INSERT INTO aa_rank_prereqs (rank_id, {', '.join(prereq_cols)}) "
                    f"SELECT {clone_id}, {', '.join(prereq_cols)} FROM aa_rank_prereqs WHERE rank_id = {native_id};")
            all_clone_ids.append(clone_id)
        cur.execute("UPDATE aa_ranks SET next_id = %s WHERE id = %s", (p['clone_ids'][0], tail))
        applied_sql.append(f"UPDATE aa_ranks SET next_id = {p['clone_ids'][0]} WHERE id = {tail};")
        rollback_sql.append(f"DELETE FROM aa_rank_effects WHERE rank_id IN ({', '.join(map(str, p['clone_ids']))});")
        rollback_sql.append(f"DELETE FROM aa_rank_prereqs WHERE rank_id IN ({', '.join(map(str, p['clone_ids']))});")
        rollback_sql.append(f"DELETE FROM aa_ranks WHERE id IN ({', '.join(map(str, p['clone_ids']))});")
        rollback_sql.append(f"UPDATE aa_ranks SET next_id = {old_tail_next} WHERE id = {tail};")

    conn.commit()
    print(f"Applied: {len(all_clone_ids)} ranks cloned across {len(plans)} pairs.")

    mismatches = 0
    cur.execute("SELECT original_aa_id, universal_aa_id, aa_name FROM aa_custom_mapping")
    for orig, uni, name in cur.fetchall():
        cur.execute("SELECT first_rank_id FROM aa_ability WHERE id = %s", (orig,))
        r = cur.fetchone()
        n = len(chain(cur, r[0])) if r else 0
        cur.execute("SELECT first_rank_id FROM aa_ability WHERE id = %s", (uni,))
        r = cur.fetchone()
        u = len(chain(cur, r[0])) if r else 0
        if n != u:
            mismatches += 1
            print(f"  STILL MISMATCHED: {name} ({orig}->{uni}) native={n} tome={u}")
    print(f"Post-apply mismatch count: {mismatches}")

    if '--sql-out' in sys.argv:
        out_path = sys.argv[sys.argv.index('--sql-out') + 1]
        with open(out_path, 'w', encoding='utf-8', newline='\n') as f:
            f.write("-- Applied 2026-10-04 by tome_chain_parity.py --apply\n")
            f.write('\n'.join(applied_sql) + '\n')
        rb_path = out_path.replace('.sql', '_rollback.sql')
        with open(rb_path, 'w', encoding='utf-8', newline='\n') as f:
            f.write("-- Rollback for tome chain parity clones (2026-10-04)\n")
            f.write('\n'.join(rollback_sql) + '\n')
        print(f"SQL written: {out_path}, {rb_path}")


if __name__ == '__main__':
    main()
