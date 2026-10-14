#!/usr/bin/env python3
import sys
import time
import pexpect

ISO = "AnimeOS-v1.0-x86_64.iso"

cmd = (
    "qemu-system-x86_64 -m 2048 -smp 2 -nographic "
    "-kernel extracted/vmlinuz -initrd extracted/initrd.img "
    "-append \"boot=live console=ttyS0,115200n8\" "
    f"-cdrom {ISO}"
)


class Tee:
    def __init__(self, *files):
        self.files = files

    def write(self, data):
        for f in self.files:
            f.write(data)

    def flush(self):
        for f in self.files:
            f.flush()


logfile = open("boot_test_full.log", "w")
child = pexpect.spawn(cmd, timeout=300, encoding="utf-8")
child.logfile = Tee(sys.stdout, logfile)

exit_code = 0
try:
    print("\n[*] Waiting for login prompt...")
    child.expect("login:", timeout=240)

    child.sendline("anime")
    child.expect("Password:", timeout=30)
    child.sendline("anime")
    child.expect(r"\$\s*$", timeout=30)
    print("\n[+] Logged in. Starting GUI (startx)...")

    child.sendline("startx > /tmp/x.log 2>&1 &")
    time.sleep(45)

    child.sendline("")
    child.sendline("echo BOOT_TEST_MARKER_DONE")
    child.expect("BOOT_TEST_MARKER_DONE", timeout=30)

    print("\n[*] Dumping startx output (/tmp/x.log):")
    child.sendline("cat /tmp/x.log")
    time.sleep(3)

    child.sendline("echo BOOT_TEST_CAT_DONE")
    child.expect("BOOT_TEST_CAT_DONE", timeout=30)

    print("\n[+] Boot test completed: login + startx attempted successfully.")

except pexpect.exceptions.TIMEOUT:
    print("\n[!] Boot test TIMED OUT waiting for expected output. See log above for where it stopped.")
    exit_code = 1
except pexpect.exceptions.EOF:
    print("\n[!] QEMU exited unexpectedly (crash or kernel panic). See log above.")
    exit_code = 1
finally:
    try:
        child.close(force=True)
    except Exception:
        pass
    logfile.close()

sys.exit(exit_code)
