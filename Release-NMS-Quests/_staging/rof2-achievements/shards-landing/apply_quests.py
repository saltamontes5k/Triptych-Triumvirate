#!/usr/bin/env python3
"""Check focused Shards quest hooks; use --apply to install after database backup/import."""
import argparse,hashlib,json,pathlib,subprocess,datetime,shutil,sys
ROOT=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--quests',required=True);p.add_argument('--additional-quests',action='append',default=[],help='Other configured quest roots, for conflict checks only; repeat for every additional root');p.add_argument('--apply',action='store_true');p.add_argument('--backup',help='New backup directory required with --apply');a=p.parse_args();dest=pathlib.Path(a.quests).resolve()
def sha(f):return hashlib.sha256(f.read_bytes()).hexdigest()
for item in json.loads((ROOT/'payload-manifest.json').read_text()):
 f=ROOT/pathlib.PurePosixPath(item['path'])
 if not f.is_file()or sha(f)!=item['sha256']:raise RuntimeError('Release integrity mismatch: '+item['path'])
records=json.loads((ROOT/'quest-manifest.json').read_text());index={r['path']:r for r in records};pending=[];errors=[]
for r in records:
 rel=pathlib.PurePosixPath(r['path']);target=dest/rel
 if rel.is_absolute()or'..'in rel.parts:errors.append('Unsafe quest path');continue
 if target.exists():
  h=sha(target)
  if h==r['after_sha256']:continue
  if h not in [r['stock_before_sha256']]+r.get('accepted_before_sha256',[]):errors.append('Different/custom callback must be merged manually: '+str(rel));continue
 pending.append(r['path'])
# The engine selects one local callback, not all Lua/Perl alternatives.
# Mirror its lookup families and refuse scripts that would be shadowed or take priority.
def check_path(root, rel):
 cur=root
 for part in pathlib.PurePosixPath(rel).parts:
  cur=cur/part
  if cur.is_symlink():
   errors.append('Symlink in managed/conflicting quest path: '+str(cur));return False
 return True
roots=[dest]+[pathlib.Path(x).resolve() for x in a.additional_quests]
for root in roots:
 if not root.is_dir():errors.append('Quest root does not exist: '+str(root))
zone_prefix={'shardslanding':'752','eastwastesshard':'755','crystalshard':'756','kaelshard':'754'}
npcs=json.loads((ROOT/'provenance/baseline-identities.json').read_text())['npc_types']
conflicts=set()
def examine(root, stem, installed):
 for ext in ('.lua','.pl'):
  rel=str(stem)+ext
  if root==dest and rel in index:continue # exact preimages checked above
  if not check_path(root,rel):continue
  candidate=root/rel
  if candidate.exists():conflicts.add(str(candidate))
for record in records:
 rel=pathlib.PurePosixPath(record['path'])
 check_path(dest,rel)
 if rel.parts[0]=='lua_modules':
  for root in roots[1:]:
   if check_path(root,rel) and (root/rel).exists():conflicts.add(str(root/rel))
  continue
 for root in roots:
  if rel.parts[0] in zone_prefix:
   zone=rel.parts[0];name=rel.stem
   local=root/zone
   versions=[x for x in local.glob('v*') if x.name[1:].isdigit()]
   if name=='player':
    stems=[pathlib.PurePosixPath(zone)/'player',pathlib.PurePosixPath('global/player')]
    stems += [pathlib.PurePosixPath(zone)/x.name/'player' for x in versions]
    stems += [pathlib.PurePosixPath(zone)/x.stem for x in local.glob('player_v*.*') if x.stem[8:].isdigit()]
   else:
    identities=[(k,v.replace('`','-')) for k,v in npcs.items() if k.startswith(zone_prefix[zone]) and v.replace('`','-')==name]
    if not identities:errors.append('Missing lookup identity for '+str(rel));continue
    stems=[]
    for npc_id,npc_name in identities:
     for folder in [pathlib.PurePosixPath(zone),pathlib.PurePosixPath('global')]+[pathlib.PurePosixPath(zone)/x.name for x in versions]:
      stems += [folder/npc_id,folder/npc_name,folder/(npc_name+'_'+npc_id)]
    stems += [pathlib.PurePosixPath(zone)/'default',pathlib.PurePosixPath('global/default')]
    stems += [pathlib.PurePosixPath(zone)/x.name/'default' for x in versions]
  elif rel.parts[:2] in [('global','items'),('global','spells')]:
   kind=rel.parts[1];name=rel.stem
   stems=[rel.with_suffix(''),pathlib.PurePosixPath('global')/kind/'default']
   for zone_dir in root.iterdir():
    if not zone_dir.is_dir() or zone_dir.name in ('global','lua_modules','.git'):continue
    folder=pathlib.PurePosixPath(zone_dir.name)
    stems += [folder/kind/name,folder/kind/'default']
    stems += [folder/x.name/kind/name for x in zone_dir.glob('v*') if x.name[1:].isdigit()]
  else:
   errors.append('Unclassified quest lookup path: '+str(rel));continue
  for stem in set(stems):examine(root,stem,rel)
for conflict in sorted(conflicts):
 errors.append('Alternate/default callback needs a manual merge and lookup review: '+conflict)
aliases=[]
for r in json.loads((ROOT/'obsolete-aliases.json').read_text()):
 old=dest/pathlib.PurePosixPath(r['before'])
 if not check_path(dest,r['before']):continue
 if old.exists():
  if sha(old)!=r['sha256']:errors.append('Different/custom obsolete alias requires manual review: '+r['before'])
  else:aliases.append(r['before'])
if errors:
 print('\n'.join('STOP: '+x for x in errors),file=sys.stderr);sys.exit(1)
# Select only missing/not-yet-installed hook sections, making reruns and partial copies safe.
text=(ROOT/'patches/quest-hooks.patch').read_text();sections=[]
for section in text.split('diff --git ')[1:]:
 first=section.splitlines()[0];rel=first.split(' b/',1)[1]
 if rel in pending:sections.append('diff --git '+section)
patch=''.join(sections)
if patch:
 r=subprocess.run(['git','apply','--check','-'],cwd=dest,input=patch,text=True,capture_output=True)
 if r.returncode:print('STOP: focused patch does not match this quest tree. Merge custom callbacks first.\n'+r.stderr,file=sys.stderr);sys.exit(1)
print(f'PASS: {len(pending)} quest files need installation; {len(aliases)} verified obsolete aliases can be removed.')
if not a.apply:sys.exit(0)
if not a.backup:p.error('--apply requires --backup pointing to a new directory')
backup=pathlib.Path(a.backup).resolve()
if backup==dest or dest in backup.parents:p.error('Backup must be outside the quest directory')
backup.mkdir(parents=True,exist_ok=False)
changes=[]
for rel in pending+aliases:
 f=dest/pathlib.PurePosixPath(rel)
 changes.append({'path':rel,'before_sha256':sha(f)if f.exists()else None})
 if f.exists():out=backup/rel;out.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,out)
(backup/'changes.json').write_text(json.dumps(changes,indent=2)+'\n')
if patch:subprocess.run(['git','apply','-'],cwd=dest,input=patch,text=True,check=True)
for rel in pending:
 src=ROOT/'quests'/pathlib.PurePosixPath(rel)
 if src.is_file():out=dest/rel;out.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,out)
for rel in aliases:(dest/pathlib.PurePosixPath(rel)).unlink()
for r in records:
 if sha(dest/pathlib.PurePosixPath(r['path']))!=r['after_sha256']:raise RuntimeError('Installed hash mismatch: '+r['path'])
print('Installed and verified scoped quest files. Restart/reload through your normal maintenance procedure.')
