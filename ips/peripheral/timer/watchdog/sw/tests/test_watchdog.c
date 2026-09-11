#include "watchdog.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>
typedef struct {uint32_t seq,done,status,writes;int fail;} fake_t;
static int rd(void *p,uint32_t a,uint32_t *v) {
 fake_t *m=p;
 switch(a){case WDT_CMD_STATUS:*v=m->status;break;case WDT_ISSUED_SEQ:*v=m->seq;break;
 case WDT_DONE_SEQ:*v=m->done;break;default:*v=0;break;}return 0;
}
static int wr(void *p,uint32_t a,uint32_t v) {
 fake_t *m=p;(void)a;(void)v;if(m->fail)return -1;m->seq++;m->writes++;m->status=1;return 0;
}
int main(void){fake_t m={0};watchdog_t d={.ctx=&m,.read=rd,.write=wr};uint8_t result=255;
 assert(watchdog_submit(&d,0,WDT_SERVICE,WDT_KEY1,2,&result)==WDT_DRIVER_TIMEOUT);
 assert(d.pending && d.pending_seq==1 && m.writes==1);
 assert(watchdog_submit(&d,0,WDT_SERVICE,WDT_KEY1,2,&result)==WDT_DRIVER_PENDING);
 assert(m.writes==1);
 m.status=2;m.done=0;assert(watchdog_poll(&d,1,&result)==WDT_DRIVER_TIMEOUT);
 m.done=1;m.status=2|(7u<<8);assert(watchdog_poll(&d,1,&result)==0 && result==7 && !d.pending);
 m.fail=1;assert(watchdog_submit(&d,0,WDT_SERVICE,0,2,&result)==WDT_DRIVER_IO && !d.pending);
 m.fail=0;m.seq=UINT32_MAX;m.status=2;
 assert(watchdog_submit(&d,0,WDT_SERVICE,0,2,&result)==WDT_DRIVER_TIMEOUT && d.pending_seq==0);
 m.done=0;m.status=2;assert(watchdog_poll(&d,1,&result)==0 && result==0);
 m.status=1;assert(watchdog_submit(&d,0,WDT_SERVICE,0,2,&result)==WDT_DRIVER_BUSY);
 puts("WATCHDOG_DRIVER_TEST PASS");return 0;}
