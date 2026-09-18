#!/usr/bin/env python3
"""Offline ML-DSA KAT fixtures from a pinned, independent oracle."""
from pathlib import Path
import hashlib
import importlib.metadata
import json
import zlib
from dilithium_py.ml_dsa import ML_DSA_44, ML_DSA_65, ML_DSA_87

ROOT = Path(__file__).resolve().parents[1] / 'verification/vectors/dsa'


def descriptor(case, pset, message_len, context_len, combined_len):
    desc = bytearray(128)
    def put(off, value, size=4):
        desc[off:off+size] = value.to_bytes(size, 'little')
    put(0, 0x10000012 + (pset << 8))
    put(4, 0x44560000 + case)
    put(0x10, 0x10000, 8)
    put(0x18, message_len, 8)
    put(0x20, 0x4000, 8)
    put(0x28, combined_len, 8)
    put(0x30, 0xa000, 8)
    put(0x38, context_len)
    put(0x60, 0x8000, 8)
    put(0x7c, zlib.crc32(desc[:124]))
    return desc


def main():
    ROOT.mkdir(parents=True, exist_ok=True)
    manifest = {'schema': 'pqc-dsa-kat/1', 'oracle': 'dilithium-py',
                'version': importlib.metadata.version('dilithium-py'), 'cases': []}
    for family, alg in enumerate((ML_DSA_44, ML_DSA_65, ML_DSA_87)):
        for n, (mlen, clen) in enumerate(((0, 0), (137, 1), (65537, 255))):
            case = 3*family+n
            pset = family+4
            seed = f'PQC DSA KAT {case}'.encode()
            xi = hashlib.sha256(seed+b'xi').digest()
            message = hashlib.shake_256(seed+b'message').digest(mlen)
            context = hashlib.shake_256(seed+b'context').digest(clen)
            pk, sk = alg.key_derive(xi)
            sig = alg.sign(sk, message, ctx=context, deterministic=True)
            assert alg.verify(pk, message, sig, ctx=context)
            cbytes = (32, 48, 64)[family]
            zbits = 18 if family == 0 else 20
            bad_ct = bytearray(sig); bad_ct[0] ^= 1
            bad_z = bytearray(sig)
            raw = int.from_bytes(bad_z[cbytes:cbytes+3], 'little') & ~((1 << zbits)-1)
            bad_z[cbytes:cbytes+3] = raw.to_bytes(3, 'little')
            bad_hint = bytearray(sig); bad_hint[-1] = 255
            bad_pk = bytearray(pk); bad_pk[0] ^= 1
            bad_msg = bytes([message[0]^1])+message[1:] if message else b'\x5a'
            bad_ctx = bytes([context[0]^1])+context[1:] if context else b'\x5a'
            for bp, bm, bs, bc in [(pk,message,bad_ct,context),(pk,message,bad_z,context),
                                    (pk,message,bad_hint,context),(bad_pk,message,sig,context),
                                    (pk,bad_msg,sig,context),(pk,message,sig,bad_ctx)]:
                assert not alg.verify(bytes(bp), bm, bytes(bs), ctx=bc)
            kgdesc = bytearray(128)
            for off, value, size in [(0,0x10000010+(pset<<8),4),(4,0x4B470000+case,4),
                                     (0x3c,2,4),(0x40,0x2000,8),(0x48,len(pk),8),
                                     (0x50,0x4000,8),(0x58,4,8),(0x60,0x6000,8)]:
                kgdesc[off:off+size]=value.to_bytes(size,'little')
            kgdesc[124:128]=zlib.crc32(kgdesc[:124]).to_bytes(4,'little')
            rnd = hashlib.shake_256(seed+b'hedged').digest(32)
            hedged_sig = alg._sign_internal(sk,bytes([0,clen])+context+message,rnd)
            assert alg.verify(pk,message,hedged_sig,ctx=context)
            sigdescs = {}
            for policy in (0,1):
                sd = bytearray(128)
                for off,value,size in [(0,0x10000011+(pset<<8),4),(4,0x44530000+case,4),
                        (8,0xD5A00000+case,4),(0x10,0x10000,8),(0x18,mlen,8),
                        (0x30,0xa000,8),(0x38,clen,4),(0x3c,policy,4),
                        (0x40,0x4000,8),(0x48,len(sig),8),(0x60,0x8000,8)]:
                    sd[off:off+size]=value.to_bytes(size,'little')
                sd[124:128]=zlib.crc32(sd[:124]).to_bytes(4,'little')
                sigdescs['sign_desc' if policy==0 else 'hedged_desc']=sd
            files = {}
            payloads = dict(**sigdescs, rnd=rnd, hedged_sig=hedged_sig, keygen_desc=kgdesc, xi=xi, pk=pk, sk=sk, sig=sig, message=message, context=context,
                            desc=descriptor(case,pset,mlen,clen,len(pk)+len(sig)),
                            badmsg_desc=descriptor(case,pset,len(bad_msg),clen,len(pk)+len(sig)),
                            badctx_desc=descriptor(case,pset,mlen,len(bad_ctx),len(pk)+len(sig)))
            for kind,data in payloads.items():
                name=f'{case}_{kind}.hex'
                # Empty public inputs are represented by one unused padding byte.
                content=''.join(f'{v:02x}\n' for v in (data or b'\x00'))
                path=ROOT/name
                if path.exists() and path.read_text()!=content:
                    raise ValueError(f'refusing to change frozen fixture: {path}')
                path.write_text(content)
                files[name]=dict(logical_bytes=len(data),sha256=hashlib.sha256(path.read_bytes()).hexdigest())
            manifest['cases'].append(dict(id=case,pset=pset,message_bytes=mlen,context_bytes=clen,
                                          pk_bytes=len(pk),sk_bytes=len(sk),sig_bytes=len(sig),files=files))
    (ROOT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')


if __name__=='__main__':
    main()
