#pragma once
#include "wire.h"
#include <cstring>
#include <algorithm>
#include <limits>

namespace SpiritShroud::Native {
inline constexpr size_t ProfileSize = 0x4ff8;
// Translate the normal RoF2 encoder's counted profile through the matching
// client's compact-image contract. Live structs and host padding are not used.
// Affects are deliberately empty here. The caller MUST replay the destination
// server buff state through native buff updates before releasing its write fence.
class ProfileReader {
 const Bytes& input; size_t cursor=8; // normal profile checksum and length
public:
 Bytes image=Bytes(ProfileSize,0);
 explicit ProfileReader(const Bytes& bytes):input(bytes) {}
 uint32_t Word() { if(cursor>input.size() || input.size()-cursor<4)throw std::invalid_argument("short shroud profile");auto n=Read32(input.data()+cursor);cursor+=4;return n; }
 void Copy(size_t offset,size_t length) {
  if(cursor>input.size() || length>input.size()-cursor || offset>image.size() || length>image.size()-offset)throw std::invalid_argument("shroud profile range");
  std::copy_n(input.begin()+cursor,length,image.begin()+offset);cursor+=length;
 }
 void Put(size_t offset,uint32_t value) { if(offset>image.size()-4)throw std::invalid_argument("shroud profile destination");for(unsigned n=0;n<4;++n)image[offset+n]=uint8_t(value>>(n*8)); }
 void Count(size_t expected) {if(Word()!=expected)throw std::invalid_argument("shroud profile count");}
 void Array(size_t offset,size_t count,size_t width=4) {Count(count);Copy(offset,count*width);}
 void Name(size_t offset,size_t capacity) {
  size_t begin=cursor;while(cursor<input.size() && input[cursor])++cursor;
  if(cursor==input.size() || cursor-begin>=capacity || offset+capacity>image.size())throw std::invalid_argument("shroud profile name");
  std::copy(input.begin()+begin,input.begin()+cursor,image.begin()+offset);++cursor;
 }
 void Item(size_t offset) {Name(offset+8,64);Put(offset,Word());Put(offset+4,Word());}
 Bytes Finish() {
  Copy(0,4);Copy(4,4);Copy(8,1);Copy(0xc,4);Copy(0x10,3);
  Array(0x14,5,20);Copy(0x78,8);Array(0x80,10);
  for(auto group:{std::pair<size_t,size_t>{0xa8,22},{0x260,9}}){
   Count(group.second);for(size_t i=0;i<group.second;++i){auto a=Word(),b=Word(),c=Word(),d=Word(),e=Word();auto o=group.first+i*20;Put(o,a);Put(o+4,c);Put(o+8,b);Put(o+12,d);Put(o+16,e);}
  }
  Array(0x314,9);Array(0x338,9);
  Copy(0x35c,2);Copy(0x360,4);Copy(0x364,6);Copy(0x36c,12);Copy(0x378,4);
  Copy(0x37c,4*23); // four dimensions, weapons, points, resources, attributes, heroics
  Array(0x3d8,300,12);Array(0x11e8,100);Array(0x1378,25);Array(0x13dc,300);
  Array(0x188c,20);Array(0x18dc,20);Array(0x192c,100);Array(0x1abc,720);Array(0x25fc,16);Array(0x263c,13);Copy(0x2670,1);
  Count(42);for(size_t i=0;i<42;++i){
   if(cursor>input.size() || input.size()-cursor<80)throw std::invalid_argument("short shroud affects");
   cursor+=80;
   Put(0x2674+i*88+4,0x3f800000); // exact native empty-affect multiplier
  }
  Copy(0x34e4,14*4);Array(0x351c,5);Copy(0x3530,4);Copy(0x3534,2);
  Count(20);for(size_t i=0;i<20;++i){auto o=0x3538+i*320;Name(o,32);for(size_t j=0;j<4;++j)Item(o+32+j*72);}
  Count(5);for(size_t i=0;i<5;++i)Item(0x4e38+i*72);
  Copy(0x4fa0,22*4); // inventory mask, twenty native fields and current endurance
  return image;
 }
};
inline Bytes CompactFromNormal(const Bytes& normal) {return ProfileReader(normal).Finish();}
inline Bytes Envelope(uint32_t spawn,const Bytes& encoded_spawn,const Bytes* profile=nullptr,const Bytes* inventory=nullptr) {
 if(!spawn || encoded_spawn.empty() || encoded_spawn.size()>UINT16_MAX-6)throw std::invalid_argument("shroud transform spawn");
 if((profile==nullptr)!=(inventory==nullptr) || (profile && (profile->size()!=ProfileSize || inventory->size()<4)))throw std::invalid_argument("shroud transform self state");
 Bytes out;Put32(out,spawn);auto offset=uint16_t(6+encoded_spawn.size());out.push_back(uint8_t(offset));out.push_back(uint8_t(offset>>8));
 out.insert(out.end(),encoded_spawn.begin(),encoded_spawn.end());
 if(profile){out.insert(out.end(),profile->begin(),profile->end());out.insert(out.end(),inventory->begin(),inventory->end());}
 return out;
}
}
