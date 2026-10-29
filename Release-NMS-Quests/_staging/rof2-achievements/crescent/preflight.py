#!/usr/bin/env python3
"""Read-only content preflight. Uses a local MySQL/MariaDB option file; never prints credentials."""
import argparse,hashlib,json,pathlib,subprocess,sys
ROOT=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--client',default='mariadb',help='mysql or mariadb executable')
p.add_argument('--connection-file',required=True,help='MySQL client option file containing connection settings')
p.add_argument('--database',required=True)
p.add_argument('--quests',required=True,help='Existing PEQ quest root')
a=p.parse_args()
def query(sql):
 cmd=[a.client,'--defaults-extra-file='+str(pathlib.Path(a.connection_file).resolve()),'--database='+a.database,'-N','-B','--raw']
 r=subprocess.run(cmd,input=sql,text=True,capture_output=True)
 if r.returncode:raise RuntimeError('Database preflight query failed; verify credentials and schema in your local client option file.')
 return [json.loads(x)for x in r.stdout.splitlines()if x]
def selected(table,col,expected,key="id"):
 vals=','.join(str(int(x))for x in expected)
 return query('SELECT JSON_OBJECT(\'id\',`'+key+'`,\'name\',`'+col+'`) FROM `'+table+'` WHERE `'+key+'` IN('+vals+');')if vals else[]
checks=json.loads((ROOT/'provenance/baseline-identities.json').read_text());errors=[]
created_npcs=set(range(394900,394905))|set(range(394930,394934))
for table,col in [('items','Name'),('npc_types','name'),('tasks','title')]:
 wanted=checks[table];found={str(x['id']):x['name']for x in selected(table,col,wanted)}
 for id,name in wanted.items():
  if id not in found:
   if table=='items'or(table=='npc_types'and int(id)not in created_npcs):errors.append(f'Missing required {table} ID{id} ({name})')
  elif found[id]!=name:errors.append(f'Identity collision in {table} ID{id}: expected {name!r}')
for table,required_columns in checks.get('required_columns',{}).items():
 available=query("SELECT JSON_ARRAYAGG(COLUMN_NAME) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='"+table+"';")
 available=set(available[0] or [])if available else set()
 missing=set(required_columns)-available
 if missing:errors.append('Schema columns missing in '+table+': '+', '.join(sorted(missing)))
# Reject custom component/criterion semantics before any installer SQL is run.
for table,key in [('achievement_components','component_identity_allowlist'),('achievement_criteria','criterion_identity_allowlist')]:
 allowed=checks.get(key,[])
 if not allowed:continue
 cols=list(allowed[0]);expr=','.join("'"+c+"',`"+c+'`'for c in cols)
 current=query('SELECT JSON_OBJECT('+expr+') FROM `'+table+'` WHERE achievement_id IN('+','.join(str(int(x))for x in checks['scoped_achievement_ids'])+');')
 expected={json.dumps(r,sort_keys=True)for r in allowed}
 for row in current:
  if json.dumps(row,sort_keys=True)not in expected:errors.append('Custom or different '+table+' semantics require manual review before replacement: achievement'+str(row['achievement_id']))
for r in json.loads((ROOT/'quest-manifest.json').read_text()):
 rel=pathlib.PurePosixPath(r['path']);src=ROOT/'quests'/rel;dst=pathlib.Path(a.quests)/rel
 if rel.is_absolute()or'..'in rel.parts:errors.append('Unsafe quest path');continue
 if hashlib.sha256(src.read_bytes()).hexdigest()!=r['after_sha256']:errors.append(f'Payload modified: {rel}')
 if dst.exists()and hashlib.sha256(dst.read_bytes()).hexdigest()not in {r['stock_before_sha256'],r['after_sha256']}:errors.append(f'Existing custom/different quest must be merged before replacement: {rel}')
# Catalogue names and all new public world IDs require exact identity matches if present.
for table,info in checks.get('owned_identities',{}).items():
 col=info['column'];wanted=info['values']
 for row in selected(table,col,wanted,info.get('key','id')):
  if wanted[str(row['id'])]!=row['name']:errors.append(f'Owned ID collision: {table} ID{row["id"]}')
for r in json.loads((ROOT/'payload-manifest.json').read_text()):
 f=ROOT/pathlib.PurePosixPath(r['path'])
 if not f.is_file()or hashlib.sha256(f.read_bytes()).hexdigest()!=r['sha256']:errors.append('Release payload hash mismatch: '+r['path'])
if errors:
 for msg in errors:print('STOP: '+msg,file=sys.stderr)
 sys.exit(1)
print('PASS: baseline identities and quest preimages match. This command changed no files or database rows.')
print('Follow README.md to back up your server, apply ordered SQL, and install the listed quest files.')
