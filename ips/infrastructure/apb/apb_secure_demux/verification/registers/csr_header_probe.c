/* Compile-time checks of the generated typical-configuration C layout. */
#include <stddef.h>
#include "apb_secure_demux_regs.h"
_Static_assert(offsetof(apb_secure_demux_t, IP_ID) == 0x000, "IP_ID");
_Static_assert(offsetof(apb_secure_demux_t, COMMIT_MASK) == 0x01c, "COMMIT_MASK");
_Static_assert(offsetof(apb_secure_demux_t, FIRST_FAULT) == 0x0a0, "FIRST_FAULT");
_Static_assert(offsetof(apb_secure_demux_t, port_0) == 0x1000, "port_0");
_Static_assert(offsetof(apb_secure_demux_t, port_7) == 0x2c00, "port_7 stride");
_Static_assert(offsetof(apb_secure_demux__port_0_t, PERM_SHADOW_0) == 0x100, "shadow");
_Static_assert(offsetof(apb_secure_demux__port_0_t, PERM_ACTIVE_15) == 0x23c, "active");
_Static_assert(APB_SECURE_DEMUX__IP_ID__VALUE_reset == 0x41534458, "ID reset");
