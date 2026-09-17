#!/usr/bin/env python3
"""Independent primitive oracles for the 2026-09-16 review regressions."""
import hashlib
from pathlib import Path
out=Path(__file__).resolve().parents[1]/'verification/unit_test/golden/review_fix'
out.mkdir(exist_ok=True)
def emit(name, values, digits):
 (out/name).write_text(''.join(f'{v:0{digits}x}\n' for v in values))
stream=hashlib.shake_256(b'pqc review regression 20260916').digest(8192)
emit('sampler_stream.hex',stream,2)
q=8380417
for case in range(8):
 vals=[]
 if case==0:
  for i in range(0,len(stream)-2,3):
   v=int.from_bytes(stream[i:i+3],'little')&0x7fffff
   if v<q: vals.append(v)
 elif case in (1,2):
  eta=2 if case==1 else 4
  for b in stream:
   for v in (b&15,b>>4):
    if eta==2 and v<15: vals.append((2-v%5)%q)
    if eta==4 and v<9: vals.append((4-v)%q)
 elif case in (3,4):
  g=17 if case==3 else 19; bits=int.from_bytes(stream,'little'); width=g+1
  vals=[((1<<g)-((bits>>(i*width))&((1<<width)-1)))%q for i in range(256)]
 else:
  tau=(39,49,60)[case-5]; vals=[0]*256; signs=int.from_bytes(stream[:8],'little'); pos=8
  for i in range(256-tau,256):
   while True:
    b=stream[pos];pos+=1
    if b<=i: break
   vals[i]=vals[b];vals[b]=(1-2*(signs&1))%q; signs>>=1
 emit(f'sampler_{case}.hex', vals[:256],8)
for fid,rate in [(0,136),(1,72),(2,168),(3,136)]:
 for n in (0,rate-1,rate,rate+1,rate*2,rate*2+17):
  data=bytes(i%256 for i in range(n)); size=32 if fid==0 else 64 if fid==1 else 400
  h=[hashlib.sha3_256,hashlib.sha3_512,hashlib.shake_128,hashlib.shake_256][fid](data)
  emit(f'hash_{fid}_{n}.hex',h.digest() if fid<2 else h.digest(size),2)
