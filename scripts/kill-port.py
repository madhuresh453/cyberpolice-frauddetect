"""Kill process on specified port."""
import subprocess
import sys
import os
import time

port = 8000

# Find PID using netstat
result = subprocess.run(['netstat', '-ano'], capture_output=True, text=True)
for line in result.stdout.split('\n'):
    if f':{port}' in line and 'LISTENING' in line:
        parts = line.split()
        pid = int(parts[-1])
        print(f"Killing process {pid} on port {port}")
        try:
            subprocess.run(['taskkill', '/PID', str(pid), '/F'], capture_output=True)
        except Exception as e:
            print(f"Error killing: {e}")

time.sleep(2)

# Restart AI gateway
print("Starting AI gateway...")
subprocess.Popen(
    [sys.executable, 'ai/ai-gateway.py'],
    creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
)
time.sleep(4)
print("Done.")