# Attribution and source provenance

The achievement engine, reward-selection facility and protocol serializers derive from **fryguy503**'s [EQEmu pull request5119](https://github.com/EQEmu/EQEmu/pull/5119), “RoF2 achievement system and reusable Select Reward support.”

- EQEmu upstream: https://github.com/EQEmu/EQEmu
- Pinned base: `c9c8747ac949deddb140d196d241fa4e777500c7`
- Pinned PR head: `c68d0074bbc35974b6413c208c4523dd7fd21954`
- Patch0001: production subset of that base-to-head change, excluding tests/fixtures, reward examples, the legacy ToB coverage report and its broad criteria repair.
- Patches0002–0004: reviewed follow-up changes reconstructed onto the clean PR head. These do not import the separate local housing, fellowship or Spirit Shroud implementations.
- Protocol source excerpt: `common/achievements.cpp` from that pinned PR head. Full canonical source is in patch0001; follow-up eligibility logic is in patch0002.
- `LICENSE` is copied from the pinned upstream base's GNU General Public License version3 document. Existing source notices are retained through patches.

No Daybreak client binaries, textures, UI assets, raw exported client catalogues or packet captures are redistributed. Unknown protocol fields retain neutral names. No rights to EverQuest trademarks are asserted.
