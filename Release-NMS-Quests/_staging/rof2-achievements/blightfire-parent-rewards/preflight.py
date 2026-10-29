#!/usr/bin/env python3
"""Check all reward identities and conflicts without persistent writes."""
import argparse,hashlib,json,pathlib,re,subprocess,sys
ROOT=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--mysql-command-json',required=True,help='JSON array for MariaDB client, using a protected credentials/options file');a=p.parse_args();cmd=json.loads(a.mysql_command_json)
if not isinstance(cmd,list)or not cmd or not all(isinstance(v,str)for v in cmd):raise SystemExit('Expected a nonempty command array')
for r in json.loads((ROOT/'payload-manifest.json').read_text()):
 f=ROOT/r['path']
 if not f.is_file()or hashlib.sha256(f.read_bytes()).hexdigest()!=r['sha256']:raise SystemExit('Release hash mismatch: '+r['path'])
sql=(ROOT/'sql/010-parent-rewards.sql').read_text();guards=sql.split('START TRANSACTION;',1)[0]
# Guard prefix contains SET and connection-local TEMPORARY TABLE statements only.
if re.search(r'\b(?:UPDATE|DELETE\s+FROM|INSERT\s+INTO)\s+(?!_blight_parent_guard\b)',guards,re.I):raise SystemExit('Unexpected persistent guard statement')
r=subprocess.run(cmd,input=guards,text=True,capture_output=True)
if r.returncode:print('Preflight failed; no persistent import performed. Check schema and guard identity/conflict label.\n'+r.stderr,file=sys.stderr);raise SystemExit(1)
print('PASS: required achievements/items and reward namespace are compatible. No persistent writes. Import the complete SQL file with game services stopped.')
