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

## Scope note

Everything else in the reconstructed stack is settled statically: identical
control flow, identical constants, identical call sequences, with differences
confined to struct layout, __LINE__ values, inlining and constant folding.
These two are the only behaviours whose correctness depends on values that
exist only at runtime.
