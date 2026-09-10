#include "spi_master.h"
#define OFF(field) offsetof(spi_master_t,field)
static uint32_t rd(const spi_master_io *d,size_t a){return d->read32(d->ctx,a);}
static void wr(const spi_master_io *d,size_t a,uint32_t v){d->write32(d->ctx,a,v);d->barrier(d->ctx);}
static bool valid(const spi_master_io *d){return d && d->read32 && d->write32 && d->barrier && d->ticks && d->lock && d->unlock;}
static bool expired(const spi_master_io *d,uint64_t start,uint64_t duration){return d->ticks(d->ctx)-start>=duration;}
int spi_master_init(const spi_master_io *d,const spi_master_cs_config *cfg,unsigned n,uint32_t timeout){
    if(!valid(d)||!cfg||n<1||n>8)return SPI_EINVAL;
    for(unsigned i=0;i<n;i++)if(cfg[i].mode>3)return SPI_EINVAL;
    d->lock(d->ctx);
    int result=SPI_OK;
    if(rd(d,OFF(status))&0x41u){result=SPI_EBUSY;goto out;}
    if(n>(rd(d,OFF(capability))&15u)){result=SPI_EINVAL;goto out;}
    wr(d,OFF(ctrl),0);wr(d,OFF(action),32); /* full reset including nonzero defaults */
    for(unsigned i=0;i<n;i++){
        size_t b=OFF(cs)+i*sizeof(spi_master__cs_slot__stride20_t);
        wr(d,b+offsetof(spi_master__cs_slot__stride20_t,cfg),(cfg[i].mode>>1)|((cfg[i].mode&1u)<<1)|((uint32_t)cfg[i].lsb_first<<2));
        wr(d,b+offsetof(spi_master__cs_slot__stride20_t,clkdiv),cfg[i].divider);
        wr(d,b+offsetof(spi_master__cs_slot__stride20_t,timing0),cfg[i].setup|((uint32_t)cfg[i].hold<<16));
        wr(d,b+offsetof(spi_master__cs_slot__stride20_t,timing1),cfg[i].idle|((uint32_t)cfg[i].gap<<16));
        wr(d,b+offsetof(spi_master__cs_slot__stride20_t,dummy),cfg[i].dummy);
    }
    wr(d,OFF(wait_timeout),timeout);wr(d,OFF(ctrl),1);
    if(rd(d,OFF(error_status)))result=SPI_EIO;
out:d->unlock(d->ctx);return result;
}
int spi_master_execute(const spi_master_io *d,const spi_master_segment *s,size_t count,uint64_t duration){
    if(!valid(d)||!s||!count||!duration)return SPI_EINVAL;
    /* Validate the entire chain before the first side effect. */
    for(size_t k=0;k<count;k++){
        bool data=s[k].op<=SPI_TXRX;
        if((int)s[k].op<0 || s[k].op>SPI_RELEASE || s[k].cs>7 ||
           (data && (s[k].bits<1 || s[k].bits>32 || !s[k].len)) ||
           (!data && s[k].bits) || (s[k].op==SPI_DUMMY && !s[k].len) ||
           (s[k].op==SPI_RELEASE && (s[k].len || s[k].keep_cs)) ||
           ((s[k].op==SPI_TX || s[k].op==SPI_TXRX) && !s[k].tx) ||
           ((s[k].op==SPI_RX || s[k].op==SPI_TXRX) && !s[k].rx) ||
           (k && s[k-1].keep_cs && s[k-1].cs!=s[k].cs))return SPI_EINVAL;
    }
    if(s[count-1].keep_cs)return SPI_EINVAL; /* this synchronous API returns with CS released */
    d->lock(d->ctx);int result=SPI_OK;
    uint64_t start=d->ticks(d->ctx);
    uint32_t status=rd(d,OFF(status)),cap=rd(d,OFF(capability));
    if((status&0x41u)||!(status&(1u<<13))){result=SPI_EBUSY;goto out;}
    if(rd(d,OFF(fifo_level))||rd(d,OFF(error_status))){result=SPI_EIO;goto out;}
    for(size_t k=0;k<count;k++)if(s[k].cs>=(cap&15u)){result=SPI_EINVAL;goto out;}
    unsigned depth=1u<<((cap>>4)&15u);
    for(size_t k=0;k<count;k++){
        bool tx=s[k].op==SPI_TX||s[k].op==SPI_TXRX;
        bool rx=s[k].op==SPI_RX||s[k].op==SPI_TXRX;
        unsigned sent=0,received=0;uint32_t before=rd(d,OFF(done_count));
        wr(d,OFF(cmd_cfg),s[k].cs|((uint32_t)s[k].op<<4)|((uint32_t)s[k].bits<<8)|((uint32_t)s[k].keep_cs<<16)|((uint32_t)(s[k].op!=SPI_RELEASE)<<17));
        wr(d,OFF(cmd_len),s[k].len);wr(d,OFF(cmd_tag),s[k].tag);wr(d,OFF(cmd_push),1);
        for(;;){
            if(rd(d,OFF(error_status))){result=SPI_EIO;goto abort;}
            if(expired(d,start,duration)){result=SPI_ETIME;goto abort;}
            uint32_t level=rd(d,OFF(fifo_level));
            /* RX first prevents full-duplex overflow; one bounded operation per loop. */
            if(rx && received<s[k].len && ((level>>9)&511u))s[k].rx[received++]=rd(d,OFF(rxdata));
            if(tx && sent<s[k].len && (level&511u)<depth)wr(d,OFF(txdata),s[k].tx[sent++]);
            uint32_t completed=rd(d,OFF(done_count))-before;
            if(completed>1){result=SPI_EIO;goto abort;}
            if(completed==1 && (!rx||received==s[k].len) && (!tx||sent==s[k].len))break;
        }
    }
    while(rd(d,OFF(status))&1u){if(expired(d,start,duration)){result=SPI_ETIME;goto abort;}}
    if(rd(d,OFF(error_status)))result=SPI_EIO;
    goto out;
abort:wr(d,OFF(action),1);
out:d->unlock(d->ctx);return result;
}
int spi_master_recover(const spi_master_io *d,uint64_t duration,bool discard_rx){
    if(!valid(d)||!duration)return SPI_EINVAL;
    d->lock(d->ctx);uint64_t start=d->ticks(d->ctx);int result=SPI_OK;
    if(rd(d,OFF(status))&1u)wr(d,OFF(action),1);
    while(rd(d,OFF(status))&1u){if(expired(d,start,duration)){result=SPI_ETIME;goto out;}}
    wr(d,OFF(ctrl),0);wr(d,OFF(irq_enable),0);
    if(!discard_rx && ((rd(d,OFF(fifo_level))>>9)&511u)){result=SPI_EBUSY;goto out;}
    wr(d,OFF(error_status),1023);wr(d,OFF(irq_state),7);
    wr(d,OFF(action),2);wr(d,OFF(action),4);wr(d,OFF(action),8);wr(d,OFF(action),16);wr(d,OFF(ctrl),1);
out:d->unlock(d->ctx);return result;
}
uint32_t spi_master_irq_snapshot(const spi_master_io *d,uint32_t *previous,uint32_t *completed){
    uint32_t pending=rd(d,OFF(irq_raw))&rd(d,OFF(irq_enable));
    uint32_t now=rd(d,OFF(done_count));*completed=now-*previous;*previous=now;
    wr(d,OFF(irq_state),pending&7u);return pending;
}
