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

    # Log in as root so we can allocate a real VT with openvt.
    child.sendline("root")
    child.expect("Password:", timeout=30)
    child.sendline("anime")
    child.expect(r"#\s*$", timeout=30)
    print("\n[+] Logged in as root. Starting GUI on a real VT via openvt...")

    # openvt gives X a genuine VT (like tty1 on real hardware/Limbo),
    # instead of the serial line we're controlling it from.
    # 'timeout 45' makes sure this returns even if X keeps running.
    child.sendline(
        'timeout 45 openvt -s -w -- su - anime -c "startx > /tmp/x.log 2>&1"'
    )
    child.expect(r"#\s*$", timeout=90)

    print("\n[*] Dumping startx output (/tmp/x.log):")
    child.sendline("cat /tmp/x.log")
    child.expect(r"#\s*$", timeout=30)
    output = child.before

    child.sendline("echo BOOT_TEST_DONE")
    child.expect("BOOT_TEST_DONE", timeout=30)

    if "Fatal server error" in output or "Permission denied" in output:
        print("\n[!] X server reported a fatal error. See log above.")
        exit_code = 1
    else:
        print("\n[+] Boot test completed: X started on a real VT without a fatal error.")

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
