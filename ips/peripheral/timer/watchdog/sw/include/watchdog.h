#ifndef WATCHDOG_H
#define WATCHDOG_H
#include "watchdog_regs.h"
/* Bus callbacks must report bus faults (including APB PSLVERR) as nonzero.
 * Caller serializes ALL users of the global mailbox and indirect selectors.
 * Every read/write callback includes the platform's MMIO ordering barrier. */
typedef struct {
  void *ctx;
  int (*read)(void *, uint32_t, uint32_t *);
  int (*write)(void *, uint32_t, uint32_t);
  uint32_t pending_seq;
  unsigned pending;
} watchdog_t;
enum { WDT_DRIVER_OK=0, WDT_DRIVER_IO=-1, WDT_DRIVER_BUSY=-2,
       WDT_DRIVER_TIMEOUT=-3, WDT_DRIVER_PENDING=-4, WDT_DRIVER_ARGUMENT=-5 };
enum { WDT_OP_COMMIT=1, WDT_OP_START=2, WDT_OP_STOP=3,
       WDT_OP_CANCEL=4, WDT_OP_SNAPSHOT=5 };
enum { WDT_RESULT_OK=0, WDT_RESULT_PENDING_APPLY=11 };
#define WDT_KEY1 UINT32_C(0xa5c35a3c)
#define WDT_KEY2 UINT32_C(0x5a3ca5c3)
#define WDT_UNLOCK1 UINT32_C(0xc0de1234)
#define WDT_UNLOCK2 UINT32_C(0x3f21edcb)
/* Success means completed with *result; inspect that value separately.
 * Timeout retains pending_seq. Poll later; NEVER blindly resubmit a command. */
int watchdog_poll(watchdog_t *d, unsigned budget, uint8_t *result);
int watchdog_submit(watchdog_t *d, unsigned channel, uint32_t offset,
                    uint32_t data, unsigned budget, uint8_t *result);
int watchdog_unlock(watchdog_t *d, unsigned channel, unsigned budget);
int watchdog_service(watchdog_t *d, unsigned channel, unsigned client,
                     unsigned type, uint32_t word, unsigned budget, uint8_t *result);
int watchdog_snapshot(watchdog_t *d, unsigned channel, unsigned budget);
int watchdog_snapshot_count(watchdog_t *d, unsigned channel, uint64_t *count);
#endif
