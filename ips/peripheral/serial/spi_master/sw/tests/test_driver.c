#include "spi_master.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>
#define O(f) offsetof(spi_master_t,f)
typedef struct {uint32_t reg[128],rx[256];unsigned head,tail,sent,len,op;bool locked,stuck;uint64_t clock;unsigned writes,barriers;} model;
static void lock(void *p){model*m=p;assert(!m->locked);m->locked=true;}
static void unlock(void *p){model*m=p;assert(m->locked);m->locked=false;}
static void barrier(void*p){((model*)p)->barriers++;}
static uint64_t ticks(void*p){return ((model*)p)->clock++;}
static uint32_t read32(void*p,size_t a){model*m=p;assert(m->locked);assert(a%4==0);
    if(a==O(fifo_level))return (m->tail-m->head)<<9;
    if(a==O(rxdata)){assert(m->head<m->tail);return m->rx[m->head++];}
    return m->reg[a/4];}
static void finish(model*m){m->reg[O(done_count)/4]++;m->reg[O(status)/4]=8192|((m->reg[O(cmd_cfg)/4]>>16)&1);}
static void write32(void*p,size_t a,uint32_t v){model*m=p;assert(m->locked);assert(a%4==0);m->writes++;
    if(a==O(action)){
        assert(!v || !(v&(v-1)));
        if(v==32){uint32_t cap=m->reg[1];memset(m->reg,0,sizeof(m->reg));m->reg[1]=cap;}
        if(v==1 && !m->stuck)m->reg[O(status)/4]=64|8192;
        if(v==4)m->head=m->tail=0;
        if(v==16)m->reg[O(status)/4]&=~64u;
        return;
    }
    if(a==O(error_status)||a==O(irq_state)){m->reg[a/4]&=~v;return;}
    m->reg[a/4]=v;
    if(a==O(ctrl))m->reg[O(status)/4]=(m->reg[O(status)/4]&~8192u)|(v<<13);
    if(a==O(cmd_push)){
        m->len=m->reg[O(cmd_len)/4];m->op=(m->reg[O(cmd_cfg)/4]>>4)&7;m->sent=0;
        m->reg[O(status)/4]=8193;
        if(m->stuck)return;
        if(m->op==SPI_RX){for(unsigned i=0;i<m->len;i++)m->rx[m->tail++]=0x80+i;finish(m);}
        if(m->op>=SPI_DUMMY)finish(m);
    }
    if(a==O(txdata) && !m->stuck){
        if(m->op==SPI_TXRX){assert(m->tail-m->head<4);m->rx[m->tail++]=v^0xffu;}
        if(++m->sent==m->len)finish(m);
    }
}
int main(void){
    model m={0};m.reg[1]=1|(2<<4)|(2<<8)|(1<<12);
    spi_master_io io={&m,read32,write32,barrier,ticks,lock,unlock};
    spi_master_cs_config cfg={.mode=3,.divider=1,.dummy=~0u};
    assert(spi_master_init(&io,&cfg,1,100)==SPI_OK);
    assert(m.reg[O(cs)/4]==3 && !m.locked);
    uint32_t tx[128],rx[128];for(unsigned i=0;i<128;i++)tx[i]=i;
    spi_master_segment s={.op=SPI_TXRX,.bits=8,.len=128,.tx=tx,.rx=rx};
    m.reg[O(done_count)/4]=~0u;
    assert(spi_master_execute(&io,&s,1,1000)==SPI_OK);
    for(unsigned i=0;i<128;i++)assert(rx[i]==(tx[i]^0xffu));
    assert(m.reg[O(done_count)/4]==0 && !m.locked);
    unsigned before=m.writes;s.bits=0;
    assert(spi_master_execute(&io,&s,1,1000)==SPI_EINVAL && before==m.writes);s.bits=8;
    m.stuck=true;
    assert(spi_master_execute(&io,&s,1,5)==SPI_ETIME && !m.locked);
    assert(spi_master_recover(&io,5,true)==SPI_ETIME && !m.locked);
    m.stuck=false;
    assert(spi_master_recover(&io,100,true)==SPI_OK && !m.locked);
    assert(m.writes==m.barriers);
    puts("DRIVER_TEST PASS");return 0;
}
