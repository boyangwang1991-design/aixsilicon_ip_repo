#include "watchdog.h"
static int valid(const watchdog_t *d) { return d && d->read && d->write; }
int watchdog_poll(watchdog_t *d, unsigned budget, uint8_t *result) {
  if (!valid(d) || !result) return WDT_DRIVER_ARGUMENT;
  if (!d->pending) return WDT_DRIVER_ARGUMENT;
  while (budget--) {
    uint32_t status, done;
    if (d->read(d->ctx, WDT_CMD_STATUS, &status) ||
        d->read(d->ctx, WDT_DONE_SEQ, &done)) return WDT_DRIVER_IO;
    if (!(status & 1u) && (status & 2u) && done == d->pending_seq) {
      *result = (uint8_t)(status >> 8);
      d->pending = 0;
      return WDT_DRIVER_OK;
    }
  }
  return WDT_DRIVER_TIMEOUT;
}
int watchdog_submit(watchdog_t *d, unsigned ch, uint32_t offset,
                    uint32_t data, unsigned budget, uint8_t *result) {
  uint32_t status, seq;
  if (!valid(d) || !result || ch >= 16u || offset >= 0x400u || (offset & 3u))
    return WDT_DRIVER_ARGUMENT;
  if (d->pending) return WDT_DRIVER_PENDING;
  if (d->read(d->ctx, WDT_CMD_STATUS, &status) ||
      d->read(d->ctx, WDT_ISSUED_SEQ, &seq)) return WDT_DRIVER_IO;
  if (status & 1u) return WDT_DRIVER_BUSY;
  if (d->write(d->ctx, WDT_CHANNEL_BASE(ch) + offset, data)) return WDT_DRIVER_IO;
  d->pending_seq = seq + 1u;
  d->pending = 1u;
  return watchdog_poll(d, budget, result);
}
int watchdog_unlock(watchdog_t *d, unsigned ch, unsigned budget) {
  uint8_t result;
  int rc = watchdog_submit(d, ch, WDT_UNLOCK, WDT_UNLOCK1, budget, &result);
  if (rc) return rc;
  if (result) return result;
  rc = watchdog_submit(d, ch, WDT_UNLOCK, WDT_UNLOCK2, budget, &result);
  return rc ? rc : result;
}
int watchdog_service(watchdog_t *d, unsigned ch, unsigned client,
                     unsigned type, uint32_t word, unsigned budget, uint8_t *result) {
  if (!valid(d) || ch >= 16u || client >= 32u || type > 3u) return WDT_DRIVER_ARGUMENT;
  if (d->pending) return WDT_DRIVER_PENDING;
  if (d->write(d->ctx, WDT_CHANNEL_BASE(ch) + WDT_SERVICE_SELECT, client | (type << 8)))
    return WDT_DRIVER_IO;
  return watchdog_submit(d, ch, WDT_SERVICE, word, budget, result);
}
int watchdog_snapshot(watchdog_t *d, unsigned ch, unsigned budget) {
  uint8_t result;
  int rc=watchdog_submit(d,ch,WDT_COMMAND,WDT_OP_SNAPSHOT,budget,&result);
  return rc ? rc : result;
}
int watchdog_snapshot_count(watchdog_t *d, unsigned ch, uint64_t *count) {
  uint32_t valid_snap,lo,hi,seq;
  if (!valid(d) || !count || ch >= 16u) return WDT_DRIVER_ARGUMENT;
  if (d->pending) return WDT_DRIVER_PENDING;
  if (d->read(d->ctx,WDT_CHANNEL_BASE(ch)+WDT_SNAP_META,&valid_snap) ||
      d->read(d->ctx,WDT_CHANNEL_BASE(ch)+WDT_SNAP_SEQ,&seq)) return WDT_DRIVER_IO;
  if (!(valid_snap & 1u) || seq != d->pending_seq) return WDT_DRIVER_ARGUMENT;
  if (d->read(d->ctx,WDT_CHANNEL_BASE(ch)+WDT_COUNT_LO_SNAP,&lo) ||
      d->read(d->ctx,WDT_CHANNEL_BASE(ch)+WDT_COUNT_HI_SNAP,&hi)) return WDT_DRIVER_IO;
  *count=((uint64_t)hi<<32)|lo;
  return WDT_DRIVER_OK;
}
