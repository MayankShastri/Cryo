# Windows Non-Elevated Background Services & Autostart

This reference guide documents a reliable, non-elevated (standard user) pattern for running persistent local background services (such as OmniRoute, Supermemory, or local web servers) silently on Windows logon, bypassing Task Scheduler admin barriers.

## The Problem: Task Scheduler Elevation Bar
Many developer guides suggest using Windows Task Scheduler (`schtasks` or `Register-ScheduledTask`) with a `LogonTrigger` to autostart background processes. However, in non-elevated environments (like Git Bash/MSYS shells running without Administrator permissions), attempting to register a scheduled task results in `Access is denied (HRESULT 0x80070005)`.

## The Solution: HKCU Run Key + Silent VBS Launcher
By writing to the Current User's Run registry hive (`HKCU\Software\Microsoft\Windows\CurrentVersion\Run`), any standard user can register startup programs. To prevent command prompt/console windows from flashing or staying open on the desktop, we wrap the executable/script launch in a silent VBScript launcher.

---

### Step 1: Create a Silent VBScript Launcher

Create a `.vbs` script in a local directory (e.g., `~/AppData/Local/hermes/service_name_service/start.vbs`).

#### Template for Node.js / CLI Utilities (e.g. OmniRoute):
```vbs
Dim sh
Set sh = CreateObject("WScript.Shell")
' Set the working directory where the process or dependencies resolve
sh.CurrentDirectory = "C:\Users\<user>\AppData\Roaming\npm"
' Run node.exe silently (0 = hide window, False = run asynchronously)
sh.Run "node.exe ""C:\Users\<user>\AppData\Roaming\npm\node_modules\omniroute\bin\omniroute.mjs"" serve", 0, False
```

#### Template for Native Executables (e.g. Supermemory):
```vbs
Dim sh
Set sh = CreateObject("WScript.Shell")
' Set the working directory to the config / binary directory
sh.CurrentDirectory = "C:\Users\<user>\.supermemory"
' Run the compiled binary silently
sh.Run "C:\Users\<user>\.supermemory\bin\supermemory-server.exe", 0, False
```

*Note: Ensure all absolute paths are resolved to their true physical drive representation (e.g., `C:\Users\username\...` rather than shell aliases like `~/`).*

---

### Step 2: Register in Current User Run Key

Execute the following standard `reg` command in any terminal session (no administrator elevation required):

```bash
# Register OmniRoute
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" \
  /v "OmniRoute_Server" \
  /t REG_SZ \
  /d "wscript.exe //B //Nologo \"C:\Users\<user>\AppData\Local\hermes\omniroute_service\OmniRoute_Start.vbs\"" \
  /f

# Register Supermemory
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" \
  /v "Supermemory_Server" \
  /t REG_SZ \
  /d "wscript.exe //B //Nologo \"C:\Users\<user>\AppData\Local\hermes\supermemory_service\Supermemory_Start.vbs\"" \
  /f
```

### Explaining the Parameters:
*   `wscript.exe`: Executes the VBScript.
*   `//B`: Batch mode; suppresses script errors and prompts.
*   `//Nologo`: Prevents showing the banner on execution.
*   `/v`: Specifies the Registry Value name.
*   `/t REG_SZ`: Specifies a String registry type.
*   `/f`: Force overwrites any existing value without prompting.

---

## Verification & Management

### 1. View Registered Startup Keys
List all current-user startup applications to verify addition:
```bash
reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
```

### 2. Force Launch (Testing)
Run the launcher immediately from the terminal to verify that it starts without popping up a console window:
```bash
wscript.exe //B //Nologo "C:\Users\<user>\AppData\Local\hermes\service_name_service\start.vbs"
```

Check if the processes are running:
```bash
# In Git Bash / MSYS:
ps -W | grep -E "node|supermemory"
```

### 3. Disable Startup Launch
If a service needs to be removed from startup:
```bash
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "OmniRoute_Server" /f
```
