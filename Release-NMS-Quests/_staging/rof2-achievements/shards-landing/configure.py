#!/usr/bin/env python3
"""Change labelled Lua reconstruction defaults in this release; no server/database access."""
import argparse,pathlib,json,hashlib,re
ROOT=pathlib.Path(__file__).resolve().parent;p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--radius',type=float);p.add_argument('--extractor-chance',type=int);p.add_argument('--sermon-seconds',type=int);p.add_argument('--meditation-seconds',type=int);a=p.parse_args()
changes={k:v for k,v in vars(a).items()if v is not None}
if not changes:p.error('Specify at least one reconstruction setting.')
for key,value in changes.items():
 if key=='extractor_chance'and not 1<=value<=100:p.error('extractor chance must be1..100')
 if key!='extractor_chance'and not 0<value<=3600:p.error('radius/timer settings must be greater than0 and at most3600')
rel='lua_modules/shards_partisan_config.lua';f=ROOT/'quests'/rel;before=hashlib.sha256(f.read_bytes()).hexdigest();text=f.read_text()
for key,value in changes.items():
 pattern=r'(\["'+re.escape(key)+r'"\]=)[0-9]+(?:\.[0-9]+)?'
 text,count=re.subn(pattern,lambda m:m[1]+str(value),text)
 if count!=1:raise RuntimeError('Ambiguous/missing config field: '+key)
f.write_text(text);after=hashlib.sha256(f.read_bytes()).hexdigest()
manifest=ROOT/'quest-manifest.json';records=json.loads(manifest.read_text())
for row in records:
 if row['path']==rel:
  accepted=row.setdefault('accepted_before_sha256',[])
  if before!=after and before not in accepted:accepted.append(before)
  row['after_sha256']=after
manifest.write_text(json.dumps(records,indent=2)+'\n')
payload=ROOT/'payload-manifest.json';records=json.loads(payload.read_text())
for row in records:
 if row['path']in {'quests/'+rel,'quest-manifest.json'}:row['sha256']=hashlib.sha256((ROOT/row['path']).read_bytes()).hexdigest()
payload.write_text(json.dumps(records,indent=2)+'\n');print('Updated package configuration and its hashes; no runtime or database changes.')
