#!/usr/bin/env python3
"""Elaborate the three PQC configurations, check capability encoding, reject invalid parameters.
This verifies RTL parameters; it is not synthesis or a PPA measurement.
"""
import argparse,json,subprocess,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
CONFIGS = {
    "CFG_TINY": {
        "NTT_LANES": 1,
        "KECCAK_ROUNDS_PER_CYCLE": 1,
        "LOCAL_SRAM_KIB": 32,
        "DMA_DATA_WIDTH": 64,
        "KEY_SLOT_NUM": 8,
        "SCA_LEVEL": 1,
    },
    "CFG_BALANCED": {
        "NTT_LANES": 2,
        "KECCAK_ROUNDS_PER_CYCLE": 2,
        "LOCAL_SRAM_KIB": 64,
        "DMA_DATA_WIDTH": 128,
        "KEY_SLOT_NUM": 8,
        "SCA_LEVEL": 1,
    },
    "CFG_THROUGHPUT": {
        "NTT_LANES": 4,
        "KECCAK_ROUNDS_PER_CYCLE": 2,
        "LOCAL_SRAM_KIB": 96,
        "DMA_DATA_WIDTH": 256,
        "KEY_SLOT_NUM": 16,
        "SCA_LEVEL": 1,
    },
}

ILLEGAL = {
    "CFG_BAD_LANES": {"NTT_LANES": 3},
    "CFG_BAD_ROUNDS": {"KECCAK_ROUNDS_PER_CYCLE": 24},
}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path)
    args=parser.parse_args()
    work=args.output or Path(tempfile.mkdtemp(prefix='pqc_param_'))
    work.mkdir(parents=True,exist_ok=True)
    sources=[str(ROOT/s.strip()) for s in (ROOT/'rtl/filelist.f').read_text().splitlines() if s.strip()]
    records=[]
    for name,params in {**CONFIGS,**ILLEGAL}.items():
        out=work/name;out.mkdir(exist_ok=True)
        overrides=','.join('.%s(%d)'%(k,v) for k,v in params.items())
        lane=params.get('NTT_LANES',2); width=params.get('DMA_DATA_WIDTH',128)
        tb=out/'cfg.sv'
        tb.write_text("""module cfg;
logic clk=0;always #5 clk=~clk;logic rst_n=0;
pqc_top #(%s) dut(.clk(clk),.rst_n(rst_n),.s_apb_psel(1'b0),.s_apb_penable(1'b0),
 .s_apb_pwrite(1'b0),.s_apb_pprot(3'd0),.km_begin(1'b0),.km_valid(1'b0),.km_revoke(1'b0),
 .zeroize_req_in(1'b0),.tamper_in(1'b0),.lifecycle_strap(1'b0),.fault_inject_ecc_ue(1'b0),
 .fault_inject_ctrl(1'b0),.entropy_valid(1'b0),.entropy_health_ok(1'b1),.privileged(1'b1),
 .m_r_valid(1'b0),.m_b_valid(1'b0));
initial begin repeat(2) @(negedge clk);rst_n=1;repeat(5) @(negedge clk);
 if(dut.hwif_out.CAPABILITY0.ntt_lanes.value !== 2'd%d ||
    dut.hwif_out.CAPABILITY1.dma_data_width.value !== 8'd%d) $fatal(1,"CAPABILITY_MISMATCH");
 $display("CONFIG_PASS");$finish;end
endmodule
"""%(overrides,0 if lane==4 else lane,0 if width==256 else width))
        cmd=['vcs','-full64','-sverilog','-timescale=1ns/1ps','-top','cfg',
             '+incdir+'+str(ROOT/'rtl/include'),*sources,str(tb),'-o',str(out/'simv')]
        with (out/'compile.log').open('w') as log:
            compile_rc=subprocess.run(cmd,cwd=out,stdout=log,stderr=subprocess.STDOUT,timeout=240).returncode
        logtext='';run_rc=None
        if compile_rc==0:
            with (out/'run.log').open('w') as log:
                run_rc=subprocess.run([str(out/'simv')],cwd=out,stdout=log,stderr=subprocess.STDOUT,timeout=60).returncode
            logtext=(out/'run.log').read_text()
        ok=(compile_rc==0 and (('Fatal:' in logtext and 'PQC_INVALID_PARAMETERS' in logtext and 'CONFIG_PASS' not in logtext) if name in ILLEGAL else (run_rc==0 and 'CONFIG_PASS' in logtext)))
        records.append(dict(config=name,passed=ok,compile_exit=compile_rc,run_exit=run_rc,command=cmd))
        print(name,'PASS' if ok else 'FAIL',flush=True)
        (work/'results.json').write_text(json.dumps(records,indent=2))
    print('PQC_PARAM_ELAB '+('PASS' if all(r['passed'] for r in records) else 'FAIL'))
    return int(not all(r['passed'] for r in records))
if __name__=='__main__': raise SystemExit(main())
