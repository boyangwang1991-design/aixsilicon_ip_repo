#include "spi_master.h"
/* All calls use platform-supplied MMIO/lock/barrier/tick hooks. No ACK exists on SPI. */
int example_write_register(const spi_master_io *io,uint8_t address,uint8_t data,uint64_t budget){
    uint32_t tx[]={0x02,address,data};
    spi_master_segment s={.op=SPI_TX,.cs=0,.bits=8,.len=3,.tag=1,.tx=tx};
    return spi_master_execute(io,&s,1,budget);
}
int example_read_with_dummy(const spi_master_io *io,uint32_t *rx,uint16_t n,uint64_t budget){
    uint32_t tx[]={0x0b,0,0,0};
    spi_master_segment s[]={
      {.op=SPI_TX,.bits=8,.len=4,.keep_cs=true,.tag=10,.tx=tx},
      {.op=SPI_DUMMY,.len=8,.keep_cs=true,.tag=11},
      {.op=SPI_RX,.bits=8,.len=n,.tag=12,.rx=rx}};
    return spi_master_execute(io,s,3,budget);
}
int example_long_full_duplex(const spi_master_io *io,const uint32_t *tx,uint32_t *rx,uint16_t n,uint64_t budget){
    spi_master_segment s={.op=SPI_TXRX,.bits=8,.len=n,.tag=20,.tx=tx,.rx=rx};
    int rc=spi_master_execute(io,&s,1,budget);
    if(rc==SPI_ETIME||rc==SPI_EIO){int recovery=spi_master_recover(io,budget,true);if(recovery)return recovery;}
    return rc;
}
/* IRQ service: hold io->lock, call spi_master_irq_snapshot, drain RX including tail,
 * refill TX, inspect ERROR_STATUS, then unlock. Never construct shadow/PUSH concurrently
 * with spi_master_execute. Watermark budget >= worst service latency * f_sclk/frame_bits.
 * A device forbidding frame-boundary pauses needs a preloaded bounded transaction API. */
