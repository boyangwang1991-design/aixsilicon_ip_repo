#ifndef SPI_MASTER_DRIVER_H
#define SPI_MASTER_DRIVER_H
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "spi_master_regs.h"
typedef struct {
    void *ctx;
    uint32_t (*read32)(void *, size_t);
    void (*write32)(void *, size_t, uint32_t);
    void (*barrier)(void *); /* Platform MMIO ordering, not just a compiler fence. */
    uint64_t (*ticks)(void *); /* Monotonic, independent of IRQ service. */
    void (*lock)(void *);
    void (*unlock)(void *);
} spi_master_io;
typedef enum { SPI_TX=0,SPI_RX=1,SPI_TXRX=2,SPI_DUMMY=3,SPI_RELEASE=4 } spi_master_op;
typedef struct {
    spi_master_op op;
    uint8_t cs,bits;
    uint16_t len,tag;
    bool keep_cs;
    const uint32_t *tx;
    uint32_t *rx;
} spi_master_segment;
typedef struct {
    uint8_t mode; /* conventional CPOL*2+CPHA */
    bool lsb_first;
    uint16_t divider,setup,hold,idle,gap;
    uint32_t dummy;
} spi_master_cs_config;
enum { SPI_OK=0,SPI_EINVAL=-1,SPI_EBUSY=-2,SPI_EIO=-3,SPI_ETIME=-4 };
int spi_master_init(const spi_master_io *,const spi_master_cs_config *,unsigned,uint32_t);
/* Owns the controller lock for the complete chain; data frames permit boundary stalls.
 * deadline_ticks is a total duration; lengths are actual frames, or cycles for DUMMY.
 * On error/timeout requests ABORT and returns. Call recover before reuse. */
int spi_master_execute(const spi_master_io *,const spi_master_segment *,size_t,uint64_t);
int spi_master_recover(const spi_master_io *,uint64_t,bool);
/* Call under the same controller lock. Snapshot + acknowledge only sticky events;
 * service RX even if its tail is below the watermark. Completion count is modulo 2^32. */
uint32_t spi_master_irq_snapshot(const spi_master_io *,uint32_t *,uint32_t *);
#endif
