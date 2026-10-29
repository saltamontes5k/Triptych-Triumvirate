#!/usr/bin/env python3
"""Render offline Baker SQL defaults; never connects to a database."""
import json,pathlib,hashlib
root=pathlib.Path(__file__).resolve().parent
cfg=json.loads((root/'config.json').read_text())
xp=cfg['xp_per_completion'];chance=cfg['truffle_drop_percent']
if isinstance(xp,bool)or not isinstance(xp,int)or not 0<=xp<=2147483647:raise ValueError('Invalid XP default')
if isinstance(chance,bool)or not isinstance(chance,(int,float))or not 0<chance<=100:raise ValueError('Drop percent must be greater than0 and at most100')
text=(root/'content-template.sql').read_text().replace('@XP@',str(xp)).replace('@DROP@',str(chance))
(root.parent.parent/'sql/050-baker-quests.sql').write_text(text)
manifest=root.parent.parent/'payload-manifest.json'
if manifest.exists():
 rows=json.loads(manifest.read_text())
 for row in rows:
  if row['path']in {'sql/050-baker-quests.sql','configuration/baker/config.json'}:
   row['sha256']=hashlib.sha256((root.parent.parent/row['path']).read_bytes()).hexdigest()
 manifest.write_text(json.dumps(rows,indent=2)+'\n')
print('Rendered sql/050-baker-quests.sql and updated its configuration hashes; no database or runtime changes.')
