#!/usr/bin/env python3
"""Check/install the Battling Blightfire quest overlay, preserving existing Lua callbacks."""
import argparse,datetime,hashlib,json,pathlib,shutil,sys
ROOT=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--quests',type=pathlib.Path,required=True);p.add_argument('--additional-quests',type=pathlib.Path,action='append',default=[]);p.add_argument('--apply',action='store_true');p.add_argument('--backup',type=pathlib.Path);a=p.parse_args();dest=a.quests.resolve()
def sha(data):return hashlib.sha256(data).hexdigest()
def fail(s):raise SystemExit('STOP: '+s)
for row in json.loads((ROOT/'payload-manifest.json').read_text()):
 f=ROOT/row['path']
 if not f.is_file()or sha(f.read_bytes())!=row['sha256']:fail('Release integrity mismatch: '+row['path'])
roots=[dest]+[x.resolve()for x in a.additional_quests]
if any(not x.is_dir()for x in roots):fail('Every quest root must exist')
changes={};remove=[];requirements=json.loads((ROOT/'provenance/baseline-identities.json').read_text());records=json.loads((ROOT/'quest-manifest.json').read_text());managed={r['path']for r in records}
def safe(root,rel):
 rel=pathlib.PurePosixPath(rel)
 if rel.is_absolute()or'..'in rel.parts:fail('Unsafe relative path')
 cur=root
 for part in rel.parts:
  cur=cur/part
  if cur.is_symlink():fail('Symlink in managed/conflicting path: '+str(cur))
 return cur
for row in records:
 rel=row['path'];source=(ROOT/'quests'/rel).read_bytes();target=safe(dest,rel)
 if target.exists()and target.read_bytes()!=source:
  allowed=requirements.get('accepted_previous_scripts',{}).get(rel,[])
  if sha(target.read_bytes()) not in allowed:fail('Custom managed script requires manual merge: '+rel)
  changes[rel]=source
 if not target.exists():changes[rel]=source
 if rel.startswith('lua_modules/'):
  for root in roots[1:]:
   if safe(root,rel).exists():fail('Module conflict in additional quest root: '+rel)
  continue
 if rel.startswith('global/spells/'):
  stem=pathlib.PurePosixPath(rel).stem
  for root in roots:
   for ext in ('.lua','.pl'):
    for candidate in root.glob('*/spells/'+stem+ext):
     other=candidate.relative_to(root).as_posix()
     if root==dest and other==rel:continue
     safe(root,other)
     fail('Alternate spell callback requires manual merge: '+str(candidate))
  continue
 zone,numeric=rel.split('/');numeric=numeric[:-4];name=requirements['npc_types'][numeric].replace('`','-')
 for root in roots:
  folders=[zone,'global']+[zone+'/'+v.name for v in (root/zone).glob('v*')if v.is_dir()and v.name[1:].isdigit()]
  for folder in folders:
   for stem in (numeric,name,name+'_'+numeric):
    for ext in ('.lua','.pl'):
     other=folder+'/'+stem+ext
     if root==dest and other==rel:continue
     f=safe(root,other)
     if not f.exists():continue
     fail('Alternate NPC callback requires manual merge: '+str(f))
for rel,hook in [('global/global_player.lua','global-player-spirits.fragment.lua'),('moors/player.lua','moors-player-spirits.fragment.lua')]:
 target=safe(dest,rel);text=target.read_text()if target.exists()else'';fragment=(ROOT/'hooks'/hook).read_text()
 marker='-- BEGIN ROF2 BLIGHTFIRE SPIRITS '+hook
 installed=fragment.strip()in text # known installed callback, with or without marker
 if marker in text and not installed:fail('Modified Blightfire hook requires manual merge: '+rel)
 for root in roots:
  alt=safe(root,rel[:-4]+'.pl')
  if alt.exists()and(root!=dest or not target.exists()):fail('Lua hook would shadow a Perl callback: '+str(alt))
  if root!=dest and safe(root,rel).exists():fail('Player callback in additional quest root: '+rel)
 if rel.startswith('moors/'):
  for root in roots:
   for f in list((root/'moors').glob('v*/player.*'))+list((root/'moors').glob('player_v*.*')):
    if f.is_file():fail('Versioned player callback requires composition: '+str(f))
 if installed:continue
 changes[rel]=(text.rstrip()+'\n\n'+marker+'\n'+fragment+'-- END ROF2 BLIGHTFIRE SPIRITS '+hook+'\n').encode()
print('PASS: %d files need installation/composition; %d exact obsolete aliases can be retired.'%(len(changes),len(set(remove))))
if not a.apply:sys.exit(0)
if not a.backup:p.error('--apply requires --backup pointing outside the quest tree')
backup=a.backup.resolve()
if backup==dest or dest in backup.parents:fail('Backup must be outside the quest tree')
backup.mkdir(parents=True,exist_ok=False);receipt=[]
for rel in list(changes)+sorted(set(remove)):
 f=safe(dest,rel);before=f.read_bytes()if f.exists()else None
 receipt.append({'path':rel,'before_sha256':sha(before)if before is not None else None,'after_sha256':sha(changes[rel])if rel in changes else None})
 if before is not None:
  out=backup/rel;out.parent.mkdir(parents=True,exist_ok=True);out.write_bytes(before)
(backup/'changes.json').write_text(json.dumps(receipt,indent=2)+'\n')
try:
 for rel,data in changes.items():
  f=safe(dest,rel);f.parent.mkdir(parents=True,exist_ok=True);f.write_bytes(data)
 for rel in set(remove):safe(dest,rel).unlink()
except Exception:
 for row in reversed(receipt):
  f=safe(dest,row['path']);old=backup/row['path']
  if old.exists():f.write_bytes(old.read_bytes())
  elif f.exists():f.unlink()
 raise
print('Installed all quest wrappers/modules and composed player hooks. Existing items/player state were not changed.')
