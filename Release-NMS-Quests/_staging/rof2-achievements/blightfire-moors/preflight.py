#!/usr/bin/env python3
"""Read-only content identity checks before importing any Blightfire SQL."""
import argparse,json,pathlib,subprocess
ROOT=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--mysql-command-json',required=True,help='JSON argument array, e.g. ["mariadb","--defaults-extra-file=/private/eq.cnf","peq"]');a=p.parse_args();cmd=json.loads(a.mysql_command_json)
if not isinstance(cmd,list)or not cmd or not all(isinstance(s,str)and s for s in cmd):p.error('Expected nonempty command array')
# SQL submitted by this program is SELECT/DESCRIBE only; do not pass client init commands.
if any(s.startswith(('--execute','--init-command'))or s=='-e'for s in cmd):p.error('Client execute/init options are not supported')
def query(sql):
 r=subprocess.run(cmd+['-N','-B','--raw'],input=sql,text=True,capture_output=True)
 if r.returncode:raise SystemExit('Read-only database query failed: '+r.stderr)
 return[json.loads(v)for v in r.stdout.splitlines()if v]
def quote(s):return "'"+str(s).replace('\\','\\\\').replace("'","''")+"'"
req=json.loads((ROOT/'provenance/baseline-identities.json').read_text());errors=[]
for table,col in [('items','name'),('npc_types','name')]:
 expected=req[table];found=query('SELECT JSON_OBJECT(\'id\',id,\'name\','+col+') FROM '+table+' WHERE id IN('+','.join(expected)+');')
 actual={str(v['id']):v['name']for v in found}
 for key,name in expected.items():
  if actual.get(key)!=name:errors.append(table+' identity missing/different: '+key+' '+name)
for table,want in req['catalogue_rows'].items():
 key='achievement_id'if table=='achievement_category_associations'else'id'
 ids=','.join(str(v[key])for v in want);cols=list(want[0]);expr=','.join(quote(c)+',`'+c+'`'for c in cols)
 for row in query('SELECT JSON_OBJECT('+expr+') FROM '+table+' WHERE '+key+' IN('+ids+');'):
  if row not in want:errors.append('Custom catalogue metadata requires merge: '+table+'/'+str(row[key]))
for table,key in [('tasks','id'),('task_activities','taskid')]:
 expected=req['existing_'+table];cols=list(expected[0]);expr=','.join(quote(c)+',`'+c+'`'for c in cols)
 ids=','.join(req['tasks']);found=query('SELECT JSON_OBJECT('+expr+') FROM '+table+' WHERE '+key+' IN('+ids+');')
 bytask={}
 for row in found:bytask.setdefault(row[key],[]).append(row)
 for task,rows in bytask.items():
  want=[v for v in expected if v[key]==task]
  if sorted(map(lambda r:json.dumps(r,sort_keys=True),rows))!=sorted(map(lambda r:json.dumps(r,sort_keys=True),want)):errors.append('Custom '+table+' rows require merge before import: '+str(task))
expected=req['achievement_components'];ids=','.join({str(r['achievement_id'])for r in expected});cols=list(expected[0]);expr=','.join(quote(c)+',`'+c+'`'for c in cols)
for row in query('SELECT JSON_OBJECT('+expr+') FROM achievement_components WHERE achievement_id IN('+ids+');'):
 if row not in expected:errors.append('Conflicting achievement component: '+str(row['achievement_id'])+'/'+str(row.get('component_id',row.get('id','?'))))
loot=query("SELECT DISTINCT JSON_OBJECT('item',d.item_id) FROM npc_types n JOIN loottable_entries l ON l.loottable_id=n.loottable_id JOIN lootdrop_entries d ON d.lootdrop_id=l.lootdrop_id JOIN spawnentry e ON e.npcid=n.id JOIN spawn2 s ON s.spawngroupID=e.spawngroupID WHERE n.id IN("+','.join(req['npc_types'])+") AND d.item_id IN("+','.join(map(str,req['loot_items']))+") AND d.chance>0 AND d.multiplier>0 AND l.probability>0 AND l.multiplier>0 AND e.chance>0 AND s.zone='moors';")
found={r['item']for r in loot}
for item in req['loot_items']:
 if item not in found:errors.append('No existing positive-chance original Moors acquisition route for item '+str(item))
if errors:raise SystemExit('\n'.join('STOP: '+s for s in errors))
print('PASS: required native items/NPCs and existing task/component identities match. No writes performed.')
