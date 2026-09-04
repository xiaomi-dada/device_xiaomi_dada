# On-device verification of reconstructed kernel modules

Static Ghidra comparison against the vendor blobs is complete (457/457 in-scope
modules, per-function). Two behaviours could not be settled without hardware,
because they depend on runtime state no static comparison can reach. Both are
marked "untested" in their commit messages.

Run these with the device booted on a build containing the reconstructed
modules, `adb root` available.

## 1. swocp over-current vote (mca_buckchg_jeita)

The blob's software over-current path debounces three consecutive samples, then
votes FCC down by 100 mA, releasing when current recovers by 500 mA. The
reconstructed version had a dead vote; it now engages. Confirm it fires and
releases against real current.

    adb shell 'echo 8 > /proc/sys/kernel/printk'
    adb shell 'dmesg -w | grep -i "jeita.*swocp\|JEITA_SWOCP"' &

Charge at high rate (>4 A) with the display on and a load applied, so measured
current exceeds the effective vote. Expect, in order:

  - three debounce samples before any vote (no vote on a single spike)
  - one vote at (effective_fcc - 100) mA
  - release once current recovers to within 500 mA of the limit

Read the vote directly rather than inferring it from logs:

    adb shell 'cat /sys/class/qcom-battery/fcc_voter' 2>/dev/null || \
    adb shell 'cat /d/mca/fcc_voter/status'

Failure mode to watch for: a vote that engages and never releases pins FCC low
for the rest of the session. That is the regression this test exists to catch.

## 2. USB-C switch device ID (fsa4480-i2c)

Support was added for the DIO4485 variant, which reports device ID 0xF6 and
needs a different register-default table than the FSA4480's 0x00. Which part
this board actually carries is not recorded in the device tree.

    adb shell 'dmesg | grep -i "fsa4480\|dio4485"'

The probe logs the ID it read. Then confirm both audio accessory detection and
USB orientation still work:

  - insert a 3.5 mm headset adapter; check switch state changes
  - insert USB-C in both orientations; check enumeration succeeds both ways

If the ID reads 0x00, this board is a plain FSA4480 and the alternate table is
dormant but harmless. If it reads 0xF6, the alternate table is live and the
above checks are what validate it.

## 3. Fuel-gauge firmware update, MCU auth retry (bq27z561)

The gauge reflash sequence runs seven steps; step 3 authenticates the MCU by
reading register 0x50 and requiring the signature 04 11 83 00 00 'R'. The vendor
driver appears to retry that read up to five times about 2 ms apart, but it
inlines several helpers into one function and the decompile does not separate
the retry from the boot-entry retries that our step 1 already performs. Ours
reads once.

    adb shell 'dmesg -w | grep -i "nfg1000\|ota program step"' &

Trigger a gauge firmware update and watch for "nfg1000 ota program step3 fail".
If step 3 ever fails on a gauge that is otherwise healthy, the read needs
retrying and nfg1000_mcu_auth_ok() should loop like the vendor driver does.

A failure here aborts the update rather than damaging the gauge, so this is safe
to observe rather than pre-emptively change.

## 4. Fuel-gauge full-access unseal and reseal (bq27z561)

Now implemented as the shipped module does it: four keys to
AltManufacturerAccess 3 ms apart (0x303b, 0x8ab9, 0xc32e, 0x5947), the seal
state read back from MAC 0x54, the sequence retried up to three times, and
command 0x0030 to seal the part again once the update finishes or gives up.
Byte 1 of the state masked with 0x03 reads 1 for full access and 3 for sealed.

The values are reproduced from the shipped module and have not been exercised
against the part, so they stay untested until someone runs a gauge update.

    adb shell 'dmesg -w | grep -i "nfg1000\|ota update attempt\|seal"' &

Trigger a gauge firmware update. What should appear: no "unseal fail", the
three "ota update attempt" lines absent or stopping early on success, and no
"ota seal fail" at the end.

"nfg1000 ota unseal fail" means the keys were sent but full access was not
reached; "write alt_mac1/2 fail" means the bus did not carry them at all,
which is a wiring or contention problem rather than a key problem.

"nfg1000 ota seal fail" is the line that matters most: it leaves the gauge
writable by anything that can reach the bus. Check it even when the update
itself reports success.

Failing here aborts the update rather than damaging the gauge, so this is safe
to observe.

## 5. Bus OVP threshold behind the register key (sc8581)

sc8581_set_busovp_th() sends the unlock key sequence before writing BUS_OVP.
The shipped module does not: it writes that threshold with no key at all.

The key is transient -- writing any other register relocks the part -- so the
extra sequence costs three i2c writes and cannot leave anything unlocked. The
question is the other way round: if BUS_OVP really is one of the protected
thresholds, the shipped module's write is being dropped and its bus
overvoltage limit is whatever the part powers up with.

    adb shell 'cat /sys/class/xm_power/cp_master/reg_dump' 2>/dev/null

Read register 0x08 back after boot and compare it against bus-ovp-threshold in
the device tree for the current mode. If it matches, the key is not needed for
this register and the unlock can go. If it reads the reset default while the
device tree asks for something else, the unlock is doing real work and the
shipped module has been running without that limit.

Left in place meanwhile: an unnecessary key sequence is harmless, and dropping
a protection threshold is not.

## 6. Flash read-back protocol (bq27z561)

The read command frame now carries the right address, but the transfer that
reads the data back still differs. Ours writes a three byte preamble
(0xaa, addr low, 0xab) and reads the whole section in one go. The shipped
module loops instead, writing a single register selector that counts up from
0x32 and reading a chunk per pass.

Which one the part answers cannot be settled from the decompile: the message
lengths in the shipped module survive only as packed decompiler output, and
guessing at them during a flash is not worth it.

    adb shell 'dmesg -w | grep -i "nfg1000\|read flash step"' &

Trigger a gauge firmware update. nfg1000_update_flash_step() reads each page
back and compares it with what it wrote, so if the read-back protocol is
wrong every page fails that comparison and the update reports failure without
having damaged anything. If the update completes, the single transfer is
being answered and this can be closed.

## Scope note

The six items above are the ones whose correctness depends on values that
exist only at runtime, and none of them can be settled from the decompile.

The rest of the reconstructed stack is settled statically, function by
function, against the vendor binary: matching control flow, constants and
call sequences, with differences confined to struct layout, __LINE__ values,
inlining and constant folding. Where that comparison turned up a real
divergence it was fixed rather than recorded here -- an adapter voltage
ceiling that compounded on every pass, aging revisions applied to the wrong
jeita band, a suspend gate written by every i2c transfer, a QC settle band
read as a timeout, and a driver published through a global before its probe
had succeeded.

Only the charging stack was reconstructed from a binary. Every other module
on the device builds from source that is already published, so a difference
there is two builds of the same source disagreeing rather than a
reconstruction that drifted.
