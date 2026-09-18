#!/usr/bin/env python3
"""Offline fixture generation only. UVM consumes frozen hex, never this model.
Oracle: kyber-py 1.2.0 FIPS 203 ML-KEM; public deterministic test seeds.
"""
from pathlib import Path
import hashlib,json,zlib,importlib.metadata
from encaps_algebra_oracle import encaps
from kyber_py.ml_kem import ML_KEM_512,ML_KEM_768,ML_KEM_1024
root=Path(__file__).resolve().parents[1]/'verification/vectors/encaps'
root.mkdir(parents=True,exist_ok=True)
manifest={'schema':'pqc-encaps-kat/1','crosscheck':'direct inverse Vandermonde and negacyclic convolution; scripts/encaps_algebra_oracle.py','source':'https://github.com/GiacomoPope/kyber-py','oracle':'kyber-py','version':importlib.metadata.version('kyber-py'),'cases':[]}
for n,alg in enumerate((ML_KEM_512,ML_KEM_768,ML_KEM_1024)):
 for sample in range(2):
  case=2*n+sample;seed=f'PQC RTL Encaps KAT {case}'.encode()
  d=hashlib.sha256(seed+b'd').digest();z=hashlib.sha256(seed+b'z').digest();m=hashlib.sha256(seed+b'm').digest()
  ek,dk=alg._keygen_internal(d,z);ss,ct=alg._encaps_internal(ek,m)
  assert alg._decaps_internal(dk,ct)==ss
  assert encaps(ek,m,n+2)==(ss,ct)
  desc=bytearray(128)
  def put(off,x,size=4):desc[off:off+size]=x.to_bytes(size,'little')
  put(0,0x10000001+((n+1)<<8));put(4,0x12340000+case)
  for off,val in [(0x10,0x2000),(0x18,len(ek)),(0x40,0x4000),(0x48,len(ct)),(0x50,0x5000),(0x58,32),(0x60,0x6000)]:put(off,val,8)
  put(0x3c,2);put(0x7c,zlib.crc32(desc[:124]))
  files={}
  for name,data in [('pk',ek),('m',m),('ct',ct),('ss',ss),('desc',desc)]:
   path=root/f'{case}_{name}.hex';path.write_text(''.join(f'{b:02x}\n' for b in data));files[path.name]=hashlib.sha256(path.read_bytes()).hexdigest()
  manifest['cases'].append({'case':case,'parameter_set':(512,768,1024)[n],'d':d.hex(),'z':z.hex(),'m':m.hex(),'pk_bytes':len(ek),'ct_bytes':len(ct),'files':files})
(root/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('Generated 6 independent Encaps fixtures')
