if {![info exists ::env(WATCHDOG_IP_ROOT)]} {error "WATCHDOG_IP_ROOT must identify the IP source root"}
read_file -type sgdc [file join $::env(WATCHDOG_IP_ROOT) constraints watchdog.sgdc]
