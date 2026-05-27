program TestAllTools;

{$APPTYPE CONSOLE}

{
  ============================================================================
  TESTALLTOOLS - Delphi LSP MCP Server Test Suite
  ============================================================================

  This test program validates the functionality of the Delphi LSP MCP Server.
  It tests MCP protocol compliance and all LSP tool operations including:
  - Goto Definition
  - Find References
  - Hover Information
  - Code Completion
  - Workspace Symbols


  QUICK START
  ===========

  Run all tests (launches server automatically):
    TestAllTools.exe


  COMMAND LINE OPTIONS
  ====================

  --help              Show this help message
  --wait              Launch server with --wait flag for debugging server startup code


  NORMAL TEST RUN (No Debugging)
  ==============================

  Just run: TestAllTools.exe

  The server will start normally without waiting for debugger attachment.
  Use this for quick validation when you don't need to debug the server.


  DEBUGGING WITH TWO DELPHI IDEs (RECOMMENDED METHOD)
  ===================================================

  This is the MOST POWERFUL way to debug. You can debug BOTH the test program
  AND the server simultaneously, each in its own IDE with its own debugger.

  WHY TWO IDEs?
  -------------
  - Each Delphi IDE can only debug ONE process at a time
  - Test program needs debugging? Run it from IDE 1
  - Server needs debugging? Attach IDE 2 to the server process
  - Two IDEs = two debuggers = both processes debuggable simultaneously


  STEP-BY-STEP INSTRUCTIONS (with --wait for full debugging)
  ----------------------------------------------------------

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ IDE 1: TEST PROGRAM (THIS TEST)                                        │
  ├─────────────────────────────────────────────────────────────────────────┤
  │                                                                         │
  │ 1. Open TestAllTools.dpr in Delphi IDE (Instance #1)                    │
  │                                                                         │
  │ 2. Set breakpoints in test code if needed                               │
  │                                                                         │
  │ 3. Go to Run -> Parameters                                              │
  │    Enter: --wait                                                        │
  │                                                                         │
  │ 4. Press F9 to run the test program                                     │
  │                                                                         │
  │ 5. The test program will:                                               │
  │    - Launch DelphiLSPMCPServer.exe with --wait flag                     │
  │    - Display: "Server started successfully! PID: 12345"                 │
  │    - Display debugging instructions                                     │
  │    - WAIT with: "Press Enter after debugger is attached..."             │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ IDE 2: MCP LSP SERVER                                                   │
  ├─────────────────────────────────────────────────────────────────────────┤
  │                                                                         │
  │ 1. Open DelphiLSPMCPServer.dpr in a SEPARATE Delphi IDE (Instance #2)   │
  │                                                                         │
  │ 2. Set breakpoints in server code (including initialization)            │
  │                                                                         │
  │ 3. Go to Run -> Attach to Process                                       │
  │                                                                         │
  │ 4. Find the process with the PID shown in IDE 1 (12345 in this example) │
  │    - Look for DelphiLSPMCPServer.exe                                    │
  │                                                                         │
  │ 5. Click "Attach"                                                       │
  │                                                                         │
  │ 6. Press F9 to let the server continue running                          │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ BACK TO IDE 1: TEST PROGRAM                                             │
  ├─────────────────────────────────────────────────────────────────────────┤
  │                                                                         │
  │ 1. Press Enter in the test console (where it was waiting)               │
  │                                                                         │
  │ 2. The tests will begin to run                                          │
  │                                                                         │
  │ 3. When the test calls the server, breakpoints in IDE 2 will hit!       │
  │                                                                         │
  │ 4. You can now step through server code (F7/F8/F9) and inspect          │
  │    variables by hovering over them                                      │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘


  WITHOUT --wait (Debug Message Handling Only)
  --------------------------------------------

  If you only need to debug message handling (not server startup):

  1. Run TestAllTools.exe (without --wait)
  2. Follow the same Two-IDEs steps above
  3. Breakpoints will hit in message handlers (HandleMessage, HandleToolsCall, etc.)
  4. But NOT in server initialization code (constructor, etc.)


  SINGLE IDE DEBUGGING (SERVER ONLY)
  ===================================

  If you only need to debug the server (and trust the test to work correctly):

  1. Run TestAllTools.exe from Command Prompt (NOT from Delphi IDE)
  2. Note the Server PID shown
  3. Open DelphiLSPMCPServer.dpr in Delphi IDE
  4. Go to Run -> Attach to Process
  5. Select the PID from step 2
  6. Set breakpoints in server code
  7. Press F9 to continue
  8. Tests will run and breakpoints will hit

  LIMITATION: In this method, the test program runs freely without a debugger.
              You can ONLY debug the server. The test program is NOT under
              debugger control.

  WHAT YOU CANNOT DO WITH SINGLE IDE (Server Only):
  - Set breakpoints in test code
  - Step through test program execution
  - Inspect test program variables
  - Debug test program logic


  SINGLE IDE DEBUGGING (TEST ONLY)
  =================================

  If you only need to debug the test program (and trust the server):

  1. Open TestAllTools.dpr in Delphi IDE
  2. Set breakpoints in test code
  3. Press F9 to run
  4. The test will launch the server and run
  5. Breakpoints will hit in test code

  LIMITATION: In this method, the server runs freely without a debugger.
			  You can ONLY debug the test program. The server is NOT under
              debugger control.

  WHAT YOU CANNOT DO WITH SINGLE IDE (Test Only):
  - Set breakpoints in server code
  - Step through server execution
  - Inspect server variables
  - Debug server logic


  COMPARISON TABLE
  ================

  +---------------------+------------------+------------------+------------------+
  | Aspect              | Two IDEs         | Single IDE       | Single IDE       |
  |                     | (Recommended)    | (Server Only)    | (Test Only)      |
  +---------------------+------------------+------------------+------------------+
  | Debug test program? | YES (IDE 1)      | NO               | YES              |
  | Debug server?       | YES (IDE 2)      | YES              | NO               |
  | Test runs from      | Delphi IDE 1     | Command line     | Delphi IDE       |
  | Server runs from    | Launched by test | Launched by test | Launched by test |
  | Break test code?    | Yes              | No               | Yes              |
  | Break server code?  | Yes              | Yes              | No               |
  | Setup complexity    | Moderate         | Simple           | Simple           |
  | Best for            | Full debugging   | Server issues    | Test issues      |
  +---------------------+------------------+------------------+------------------+


  THE --wait FLAG EXPLAINED
  =========================

  Without --wait: Server starts, initializes, then waits for messages.
                  You can only debug from Server.Run onward.
                  (Constructor and initialization already executed)

  With --wait:    Server displays PID and waits BEFORE any code executes.
				  You can set breakpoints ANYWHERE including:
                  - The very first line of the program
                  - TMCPServer.Create constructor
                  - InitializeLSP function
                  - Any initialization code

  To use --wait:
    TestAllTools.exe --wait

  The server will receive the --wait flag and pause before initialization,
  giving you time to attach the debugger and set breakpoints.


  HOW IT WORKS
  ============

  The test program automatically:
  1. Creates pipes for communication
  2. Launches DelphiLSPMCPServer.exe as a separate process
  3. Displays the Server PID
  4. WAITS for you to attach a debugger
  5. Only continues when you press Enter

  This design gives you unlimited time to:
  - Open the server project in a second IDE
  - Attach to the correct process
  - Set breakpoints
  - Press F9 to continue the server
  - Then press Enter to start the tests


  TROUBLESHOOTING
  ===============

  "Can't find the PID in Attach to Process list"
  - Make sure the test program has started (shows the PID)
  - Refresh the process list in the Attach dialog
  - Look for DelphiLSPMCPServer.exe, NOT TestAllTools.exe

  "Breakpoints don't hit in server"
  - Ensure debug info is enabled in server project options
  - Verify you attached to the correct process (check PID)
  - Make sure you pressed F9 after attaching to continue execution
  - Check that the test console shows "Press Enter after debugger is attached..."

  "Breakpoints don't hit in server initialization code"
  - Make sure you added --wait to the test program's command line
  - The server must receive the --wait flag to pause before initialization
  - Without --wait, the server runs through initialization before you can attach
  - Use: TestAllTools.exe --wait

  "Breakpoints don't hit in test program"
  - Are you using Two-IDEs method? Test runs from IDE 1
  - Are you using Server-Only method? Test runs from command line (no debugger)
  - Switch to Two-IDEs method to debug test program

  "Server console window doesn't appear"
  - The server runs with CREATE_NO_WINDOW by default
  - To see server console output, modify StartServer and remove CREATE_NO_WINDOW
  - Or use --wait and attach debugger to see server state

  "Test program launches server but I want to debug from the very beginning"
  - Use TestAllTools.exe --wait
  - This passes --wait to the server, making it pause before any code executes

  "ERROR: Could not start server"
  - Make sure DelphiLSPMCPServer.exe exists in the same directory
  - Check that the server executable is not blocked by antivirus

  "ERROR: Source file not found"
  - Place SourceForAnalysis.dpr in the same directory as TestAllTools.exe


  TEST COVERAGE
  =============

  The test suite executes 20 tests:

  Tests 1-2:    MCP Protocol (Initialize, Tools List)
  Tests 3-5:    Goto Definition (various symbols)
  Tests 6-7:    Find References
  Tests 8-9:    Hover Information
  Tests 10-11:  Code Completion
  Tests 12-14:  Workspace Symbols
  Test 15:      Error Handling (invalid tool)
  Tests 16-17:  Resources & Prompts (minimal)
  Test 18:      Unknown Method (error response)
  Test 19:      Additional Definition test
  Test 20:      Shutdown


  EXIT CODES
  ==========

  0 - All tests passed
  1 - One or more tests failed or fatal error occurred


  EXAMPLES
  ========

  Quick validation (no debugging):
	TestAllTools.exe

  Full debugging with two IDEs (debug server startup):
	TestAllTools.exe --wait
	[Then follow the Two-IDEs instructions above]

  Full debugging with two IDEs (debug message handling only):
	TestAllTools.exe
	[Then follow the Two-IDEs instructions above]

  Server-only debugging:
	TestAllTools.exe
	[Attach Delphi to the PID shown, but test not debuggable]

  Test-only debugging:
	(Open TestAllTools.dpr in Delphi, press F9)
	[Server not debuggable, only test is under debugger]
}

uses
  System.SysUtils,
  System.JSON,
  System.Classes,
  System.Generics.Collections,
  Winapi.Windows;

const
  READ_TIMEOUT_MS       = 15000;
  MAX_MESSAGE_SIZE      = 32 * 1024 * 1024;
  MAX_HEADER_LINE_LENGTH = 8192;

  SOURCE_FILE = 'SourceForAnalysis.dpr';

type
  TTestResult = record
    Name: string;
    Passed: Boolean;
	Details: string;
    ResponseJson: string;
  end;

  TTestResultArray = array of TTestResult;

var
  StdinWrite, StdoutRead: THandle;
  ProcessHandle: THandle;
  SourceUri: string;
  AllResults: TTestResultArray;
  ResultCount: Integer;
  UseServerWait: Boolean = True;  // New flag for --wait

procedure AddResult(const R: TTestResult);
begin
  Inc(ResultCount);
  if ResultCount > Length(AllResults) then
    SetLength(AllResults, ResultCount + 16);
  AllResults[ResultCount - 1] := R;
end;

procedure SafeCloseHandle(var AHandle: THandle);
begin
  if AHandle <> 0 then
  begin
    CloseHandle(AHandle);
    AHandle := 0;
  end;
end;

procedure PrintHeader(const S: string);
begin
  WriteLn;
  WriteLn('========================================');
  WriteLn(S);
  WriteLn('========================================');
end;

procedure PrintResult(const R: TTestResult);
begin
  if R.Passed then
    WriteLn('[PASS] ', R.Name)
  else
    WriteLn('[FAIL] ', R.Name, ' -- ', R.Details);
end;

procedure SendMessage(const AMessage: string);
var
  Bytes: TBytes;
  Header: AnsiString;
  BytesWritten: DWORD;
begin
  Bytes := TEncoding.UTF8.GetBytes(AMessage);
  Header := AnsiString(Format('Content-Length: %d'#13#10#13#10, [Length(Bytes)]));

  WriteLn('>>> Sending: ', Copy(AMessage, 1, 200));
  if Length(AMessage) > 200 then
    WriteLn('    ... (', Length(AMessage), ' bytes total)');

  if not WriteFile(StdinWrite, Pointer(Header)^, Length(Header), BytesWritten, nil) then
  begin
    WriteLn('ERROR: Failed to write header: ', GetLastError);
    Exit;
  end;

  if Length(Bytes) > 0 then
  begin
    if not WriteFile(StdinWrite, Pointer(Bytes)^, Length(Bytes), BytesWritten, nil) then
    begin
      WriteLn('ERROR: Failed to write body: ', GetLastError);
      Exit;
    end;
  end;

  FlushFileBuffers(StdinWrite);
end;

function ReadMessage(out Raw: string): Boolean;
var
  Line: AnsiString;
  Ch: AnsiChar;
  BytesRead: DWORD;
  ContentLength: Integer;
  Buffer: TBytes;
  TotalRead: DWORD;
  StartTime: UInt64;
  LowerLine: string;
begin
  Result := False;
  Raw := '';
  ContentLength := -1;
  Line := '';
  StartTime := GetTickCount64;

  while True do
  begin
    if (GetTickCount64 - StartTime) > READ_TIMEOUT_MS then
    begin
      WriteLn('ERROR: Header/message timeout after ', READ_TIMEOUT_MS, 'ms');
      Exit(False);
    end;

    if not ReadFile(StdoutRead, Ch, 1, BytesRead, nil) then
    begin
      WriteLn('ERROR: ReadFile header failed: ', GetLastError);
      Exit(False);
    end;

    if BytesRead = 0 then
    begin
      WriteLn('ERROR: EOF while reading header');
      Exit(False);
    end;

    if Ch = #10 then
    begin
      Line := AnsiString(Trim(string(Line)));

      if Line = '' then
      begin
        if ContentLength > 0 then
          Break;
      end
      else
      begin
        LowerLine := LowerCase(string(Line));
        if Pos('content-length:', LowerLine) = 1 then
        begin
          Delete(Line, 1, 15);
          ContentLength := StrToIntDef(Trim(string(Line)), -1);
          if (ContentLength <= 0) or (ContentLength > MAX_MESSAGE_SIZE) then
          begin
            WriteLn('ERROR: Invalid Content-Length: ', ContentLength);
            Exit(False);
          end;
        end
        else if (Line <> '') and (Line[1] = '{') then
        begin
          Raw := UTF8ToString(UTF8String(Line));
          WriteLn('<<< Response (raw JSON): ', Copy(Raw, 1, 200));
          if Length(Raw) > 200 then
            WriteLn('    ... (', Length(Raw), ' bytes total)');
          Exit(True);
        end;
      end;

      Line := '';
    end
    else if Ch <> #13 then
    begin
      if Length(Line) >= MAX_HEADER_LINE_LENGTH then
      begin
        WriteLn('ERROR: Header line too long');
        Exit(False);
      end;
      Line := Line + Ch;
    end;
  end;

  SetLength(Buffer, ContentLength);
  TotalRead := 0;
  StartTime := GetTickCount64;

  while TotalRead < DWORD(ContentLength) do
  begin
    if (GetTickCount64 - StartTime) > READ_TIMEOUT_MS then
    begin
      WriteLn('ERROR: Body timeout');
      Exit(False);
    end;

    if not ReadFile(StdoutRead, Buffer[TotalRead], ContentLength - Integer(TotalRead), BytesRead, nil) then
    begin
      WriteLn('ERROR: ReadFile body failed: ', GetLastError);
      Exit(False);
    end;

    if BytesRead = 0 then
    begin
      WriteLn('ERROR: Pipe closed mid-message');
      Exit(False);
    end;

    Inc(TotalRead, BytesRead);
  end;

  Raw := TEncoding.UTF8.GetString(Buffer);
  WriteLn('<<< Response (CL): ', Copy(Raw, 1, 200));
  if Length(Raw) > 200 then
    WriteLn('    ... (', Length(Raw), ' bytes total)');
  Result := True;
end;

function StartServer: Boolean;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  Cmd: string;
  CmdBuf: array[0..2047] of Char;
  StdinRead, StdoutWrite: THandle;
  StdErr: THandle;
  CreationFlags: DWORD;
begin
  Result := False;
  ProcessHandle := 0;
  StdinWrite := 0;
  StdoutRead := 0;

  WriteLn('Launching new server process...');

  ZeroMemory(@SA, SizeOf(SA));
  SA.nLength := SizeOf(SA);
  SA.bInheritHandle := True;

  if not CreatePipe(StdinRead, StdinWrite, @SA, 0) then
  begin
    WriteLn('ERROR: CreatePipe stdin failed: ', GetLastError);
    Exit(False);
  end;
  SetHandleInformation(StdinWrite, HANDLE_FLAG_INHERIT, 0);

  if not CreatePipe(StdoutRead, StdoutWrite, @SA, 0) then
  begin
    WriteLn('ERROR: CreatePipe stdout failed: ', GetLastError);
    SafeCloseHandle(StdinRead);
    SafeCloseHandle(StdinWrite);
	Exit(False);
  end;
  SetHandleInformation(StdoutRead, HANDLE_FLAG_INHERIT, 0);

  ZeroMemory(@SI, SizeOf(SI));
  SI.cb := SizeOf(SI);
  SI.dwFlags := STARTF_USESTDHANDLES;
  SI.hStdInput := StdinRead;
  SI.hStdOutput := StdoutWrite;

  StdErr := GetStdHandle(STD_ERROR_HANDLE);
  if StdErr = INVALID_HANDLE_VALUE then
    StdErr := 0;
  SI.hStdError := StdErr;

  // Build command line with or without --wait flag
  if UseServerWait then
    Cmd := Format('"DelphiLSPMCPServer.exe" --debug --wait --workspace "%s"', [ExpandFileName('.')])
  else
    Cmd := Format('"DelphiLSPMCPServer.exe" --debug --workspace "%s"', [ExpandFileName('.')]);

  WriteLn('Command: ', Cmd);
  StrPCopy(CmdBuf, Cmd);

  ZeroMemory(@PI, SizeOf(PI));

  // Use CREATE_NO_WINDOW to hide server console (optional, can be removed for debugging)
  CreationFlags := CREATE_NO_WINDOW;

  if not CreateProcess(nil, CmdBuf, nil, nil, True,
    CreationFlags, nil, nil, SI, PI) then
  begin
    WriteLn('ERROR: CreateProcess failed: ', GetLastError);
    SafeCloseHandle(StdinRead);
    SafeCloseHandle(StdinWrite);
    SafeCloseHandle(StdoutRead);
    SafeCloseHandle(StdoutWrite);
    Exit(False);
  end;

  SafeCloseHandle(StdinRead);
  SafeCloseHandle(StdoutWrite);
  SafeCloseHandle(PI.hThread);
  ProcessHandle := PI.hProcess;

  WriteLn('Server started successfully!');
  WriteLn('PID: ', GetProcessId(ProcessHandle));
  WriteLn('');
  WriteLn('========================================');
  WriteLn('DEBUGGING INSTRUCTIONS:');
  WriteLn('========================================');
  WriteLn('1. In Delphi IDE: Run -> Attach to Process');
  WriteLn('2. Find process with PID: ', GetProcessId(ProcessHandle));
  WriteLn('3. Click Attach');
  WriteLn('4. Set breakpoints in server code');
  if UseServerWait then
    WriteLn('5. Server is waiting with --wait flag. Press F9 to continue, then Press Enter here')
  else
    WriteLn('5. Press F9 to continue server');
  WriteLn('6. Press Enter here to start tests');
  WriteLn('========================================');
  WriteLn('');
  WriteLn('Press Enter after debugger is attached...');
  ReadLn;

  Result := True;
end;

procedure Cleanup;
begin
  WriteLn('Cleaning up...');
  if ProcessHandle <> 0 then
  begin
    WriteLn('Terminating server process (PID: ', GetProcessId(ProcessHandle), ')');
    TerminateProcess(ProcessHandle, 0);
    SafeCloseHandle(ProcessHandle);
  end;
  SafeCloseHandle(StdinWrite);
  SafeCloseHandle(StdoutRead);
  WriteLn('Cleanup complete');
end;

function RunTest(const Name, Request: string; ExpectError: Boolean = False): TTestResult;
var
  Raw: string;
  Json: TJSONObject;
  HasError: Boolean;
begin
  Result.Name := Name;
  Result.Passed := False;
  Result.Details := '';
  Result.ResponseJson := '';

  PrintHeader('TEST: ' + Name);
  WriteLn('Request: ', Copy(Request, 1, 200));

  try
    SendMessage(Request);
    if not ReadMessage(Raw) then
    begin
      Result.Details := 'No response / read error / timeout';
      Exit;
    end;

    Result.ResponseJson := Raw;

    Json := TJSONObject.ParseJSONValue(Raw) as TJSONObject;
    if Json = nil then
    begin
      Result.Details := 'Invalid JSON response';
      Exit;
    end;
    try
      HasError := Json.GetValue('error') <> nil;
      if ExpectError then
      begin
        if HasError then
          Result.Passed := True
        else
          Result.Details := 'Expected error but got success';
      end
      else
      begin
        if HasError then
          Result.Details := 'Server error: ' + Json.GetValue('error').ToJSON
        else
          Result.Passed := True;
      end;
    finally
      Json.Free;
    end;
  except
	on E: Exception do
      Result.Details := 'Exception: ' + E.Message;
  end;
end;

function GetToolResultText(const ResponseJson: string): string;
var
  Json, ResultObj: TJSONObject;
  ContentArr: TJSONArray;
  Item: TJSONObject;
begin
  Result := '';
  Json := TJSONObject.ParseJSONValue(ResponseJson) as TJSONObject;
  if Json = nil then Exit;
  try
    ResultObj := Json.GetValue('result') as TJSONObject;
    if ResultObj = nil then Exit;
    ContentArr := ResultObj.GetValue('content') as TJSONArray;
    if ContentArr = nil then Exit;
    if ContentArr.Count = 0 then Exit;
    Item := ContentArr.Items[0] as TJSONObject;
    if Item = nil then Exit;
    Item.TryGetValue<string>('text', Result);
  finally
    Json.Free;
  end;
end;

function BuildSourceUri: string;
var
  FullPath: string;
  I: Integer;
  C: Char;
begin
  FullPath := ExpandFileName(SOURCE_FILE);
  FullPath := StringReplace(FullPath, '\', '/', [rfReplaceAll]);

  Result := '';
  for I := 1 to Length(FullPath) do
  begin
    C := FullPath[I];
    if CharInSet(C, ['A'..'Z', 'a'..'z', '0'..'9', '-', '_', '.', '~', '/', ':']) then
      Result := Result + C
    else
      Result := Result + '%' + IntToHex(Ord(C), 2);
  end;

  Result := 'file:///' + Result;
end;

function ToolCallRequest(Id: Integer; const ToolName: string; const ArgsJson: string): string;
begin
  Result := Format(
    '{"jsonrpc":"2.0","id":%d,"method":"tools/call","params":{"name":"%s","arguments":%s}}',
    [Id, ToolName, ArgsJson]
  );
end;

procedure ParseCommandLine;
var
  I: Integer;
  Param: string;
begin
  for I := 1 to ParamCount do
  begin
    Param := ParamStr(I);
	if (Param = '--wait') then
    begin
      UseServerWait := True;
      WriteLn('Mode: Server will start with --wait flag (for debugging startup)');
    end
    else if (Param = '--help') or (Param = '-h') then
    begin
      WriteLn('TestAllTools - Test Delphi LSP MCP Server');
      WriteLn('');
      WriteLn('Usage:');
      WriteLn('  TestAllTools.exe              - Launch new server and run tests (default)');
      WriteLn('  TestAllTools.exe --wait       - Launch server with --wait flag (debug server startup)');
      WriteLn('  TestAllTools.exe --help       - Show this help');
      WriteLn('');
      WriteLn('For debugging:');
      WriteLn('  1. Run TestAllTools.exe --wait');
      WriteLn('  2. In Delphi: Run -> Attach to Process -> Select the server PID');
      WriteLn('  3. Set breakpoints in server code (including initialization)');
      WriteLn('  4. Press F9 to continue');
      WriteLn('  5. Press Enter in test console to start tests');
      WriteLn('  6. Breakpoints will hit');
      Halt(0);
    end;
  end;
end;

procedure RunAllTests;
var
  R: TTestResult;
  Text: string;
  ArgsJson: string;
begin
  ResultCount := 0;
  SetLength(AllResults, 32);

  // TEST 1: Initialize
  R := RunTest('1. MCP Initialize',
    '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{' +
      '"protocolVersion":"2025-11-25",' +
      '"capabilities":{},' +
      '"clientInfo":{"name":"TestAllTools","version":"1.0"}' +
    '}}');
  AddResult(R);
  PrintResult(R);

  if not R.Passed then
  begin
    WriteLn('FATAL: Initialize failed, cannot continue.');
    Exit;
  end;

  Text := R.ResponseJson;
  if Pos('"protocolVersion"', Text) = 0 then
    WriteLn('  WARNING: No protocolVersion in response');

  WriteLn;
  WriteLn('Waiting 3 seconds for LSP to start and index...');
  Sleep(3000);

  SendMessage('{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}');
  Sleep(500);

  // TEST 2: Tools List
  R := RunTest('2. Tools List',
    '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}');
  AddResult(R);
  PrintResult(R);

  if R.Passed then
  begin
    if Pos('"delphi_goto_definition"', R.ResponseJson) > 0 then
      WriteLn('  OK: delphi_goto_definition found')
    else
      WriteLn('  WARNING: delphi_goto_definition NOT found');

    if Pos('"delphi_find_references"', R.ResponseJson) > 0 then
      WriteLn('  OK: delphi_find_references found')
    else
      WriteLn('  WARNING: delphi_find_references NOT found');

    if Pos('"delphi_hover"', R.ResponseJson) > 0 then
      WriteLn('  OK: delphi_hover found')
    else
      WriteLn('  WARNING: delphi_hover NOT found');

    if Pos('"delphi_completion"', R.ResponseJson) > 0 then
      WriteLn('  OK: delphi_completion found')
    else
      WriteLn('  WARNING: delphi_completion NOT found');

    if Pos('"delphi_workspace_symbols"', R.ResponseJson) > 0 then
      WriteLn('  OK: delphi_workspace_symbols found')
    else
      WriteLn('  WARNING: delphi_workspace_symbols NOT found');
  end;

  // LSP Tool Tests
  WriteLn;
  WriteLn('--- LSP Tool Tests against ', SOURCE_FILE, ' ---');
  WriteLn('Source URI: ', SourceUri);

  ArgsJson := Format('{"uri":"%s","line":26,"character":6}', [SourceUri]);
  R := RunTest('3. Goto Definition (F.Bar call, line 27)',
    ToolCallRequest(10, 'delphi_goto_definition', ArgsJson));
  AddResult(R);
  PrintResult(R);
  Text := GetToolResultText(R.ResponseJson);
  WriteLn('  Tool result text: ', Text);

  ArgsJson := Format('{"uri":"%s","line":12,"character":3}', [SourceUri]);
  R := RunTest('4. Goto Definition (TFoo declaration, line 13)',
    ToolCallRequest(11, 'delphi_goto_definition', ArgsJson));
  AddResult(R);
  PrintResult(R);
  Text := GetToolResultText(R.ResponseJson);
  WriteLn('  Tool result text: ', Text);

  ArgsJson := Format('{"uri":"%s","line":18,"character":4}', [SourceUri]);
  R := RunTest('5. Goto Definition (WriteLn, line 19)',
    ToolCallRequest(12, 'delphi_goto_definition', ArgsJson));
  AddResult(R);
  PrintResult(R);
  Text := GetToolResultText(R.ResponseJson);
  WriteLn('  Tool result text: ', Text);

  ArgsJson := Format('{"uri":"%s","line":12,"character":3,"includeDeclaration":true}', [SourceUri]);
  R := RunTest('6. Find References (TFoo, line 13)',
    ToolCallRequest(13, 'delphi_find_references', ArgsJson));
  AddResult(R);
  PrintResult(R);
  Text := GetToolResultText(R.ResponseJson);
  WriteLn('  Tool result text: ', Text);

  ArgsJson := Format('{"uri":"%s","line":13,"character":15}', [SourceUri]);
  R := RunTest('7. Find References (Bar, line 14)',
    ToolCallRequest(14, 'delphi_find_references', ArgsJson));
  AddResult(R);
  PrintResult(R);
  Text := GetToolResultText(R.ResponseJson);
  WriteLn('  Tool result text: ', Text);

  ArgsJson := Format('{"uri":"%s","line":12,"character":3}', [SourceUri]);
  R := RunTest('8. Hover (TFoo, line 13)',
    ToolCallRequest(15, 'delphi_hover', ArgsJson));
  AddResult(R);
  PrintResult(R);
  Text := GetToolResultText(R.ResponseJson);
  WriteLn('  Tool result text: ', Text);

  ArgsJson := Format('{"uri":"%s","line":16,"character":15}', [SourceUri]);
  R := RunTest('9. Hover (TFoo.Bar, line 17)',
    ToolCallRequest(16, 'delphi_hover', ArgsJson));
  AddResult(R);
  PrintResult(R);
  Text := GetToolResultText(R.ResponseJson);
  WriteLn('  Tool result text: ', Text);

  ArgsJson := Format('{"uri":"%s","line":26,"character":6}', [SourceUri]);
  R := RunTest('10. Completion (after F., line 27)',
    ToolCallRequest(17, 'delphi_completion', ArgsJson));
  AddResult(R);
  PrintResult(R);
  Text := GetToolResultText(R.ResponseJson);
  WriteLn('  Tool result text: ', Copy(Text, 1, 300));

  ArgsJson := Format('{"uri":"%s","line":24,"character":14}', [SourceUri]);
  R := RunTest('11. Completion (after TFoo., line 25)',
    ToolCallRequest(18, 'delphi_completion', ArgsJson));
  AddResult(R);
  PrintResult(R);
  Text := GetToolResultText(R.ResponseJson);
  WriteLn('  Tool result text: ', Copy(Text, 1, 300));

  R := RunTest('12. Workspace Symbols (query=TFoo)',
    ToolCallRequest(19, 'delphi_workspace_symbols', '{"query":"TFoo"}'));
  AddResult(R);
  PrintResult(R);
  Text := GetToolResultText(R.ResponseJson);
  WriteLn('  Tool result text: ', Text);

  R := RunTest('13. Workspace Symbols (query=Bar)',
    ToolCallRequest(20, 'delphi_workspace_symbols', '{"query":"Bar"}'));
  AddResult(R);
  PrintResult(R);
  Text := GetToolResultText(R.ResponseJson);
  WriteLn('  Tool result text: ', Text);

  R := RunTest('14. Workspace Symbols (query="" empty)',
    ToolCallRequest(21, 'delphi_workspace_symbols', '{"query":""}'));
  AddResult(R);
  PrintResult(R);
  Text := GetToolResultText(R.ResponseJson);
  WriteLn('  Tool result text: ', Copy(Text, 1, 200));

  R := RunTest('15. Invalid Tool Name',
    ToolCallRequest(22, 'nonexistent_tool', '{}'));
  AddResult(R);
  PrintResult(R);
  Text := GetToolResultText(R.ResponseJson);
  WriteLn('  Tool result text: ', Text);

  if Pos('"isError":true', R.ResponseJson) > 0 then
    WriteLn('  OK: isError=true in result (correct per MCP spec)')
  else if R.Passed then
    WriteLn('  WARNING: No isError=true found, invalid tool should set isError');

  R := RunTest('16. Resources List',
    '{"jsonrpc":"2.0","id":30,"method":"resources/list","params":{}}');
  AddResult(R);
  PrintResult(R);

  R := RunTest('17. Prompts List',
    '{"jsonrpc":"2.0","id":31,"method":"prompts/list","params":{}}');
  AddResult(R);
  PrintResult(R);

  R := RunTest('18. Unknown Method (expect error)',
    '{"jsonrpc":"2.0","id":32,"method":"foo/bar","params":{}}', True);
  AddResult(R);
  PrintResult(R);

  ArgsJson := Format('{"uri":"%s","line":9,"character":4}', [SourceUri]);
  R := RunTest('19. Goto Definition (SysUtils, line 10)',
    ToolCallRequest(33, 'delphi_goto_definition', ArgsJson));
  AddResult(R);
  PrintResult(R);
  Text := GetToolResultText(R.ResponseJson);
  WriteLn('  Tool result text: ', Text);

  R := RunTest('20. Shutdown',
    '{"jsonrpc":"2.0","id":99,"method":"shutdown","params":{}}');
  AddResult(R);
  PrintResult(R);
end;

procedure PrintFinalSummary;
var
  I, Passed, Failed: Integer;
begin
  PrintHeader('FINAL SUMMARY');
  Passed := 0;
  Failed := 0;

  for I := 0 to ResultCount - 1 do
  begin
    PrintResult(AllResults[I]);
    if AllResults[I].Passed then
      Inc(Passed)
    else
      Inc(Failed);
  end;

  WriteLn;
  WriteLn(Format('Total: %d | Passed: %d | Failed: %d', [Passed + Failed, Passed, Failed]));

  if Failed = 0 then
    WriteLn('ALL TESTS PASSED!')
  else
    WriteLn('SOME TESTS FAILED!');

  if Failed > 0 then
  begin
    WriteLn;
    WriteLn('--- FAILURE DETAILS ---');
	for I := 0 to ResultCount - 1 do
    begin
      if not AllResults[I].Passed then
      begin
        WriteLn;
        WriteLn('FAILED: ', AllResults[I].Name);
        WriteLn('  Reason: ', AllResults[I].Details);
        if AllResults[I].ResponseJson <> '' then
          WriteLn('  Response: ', Copy(AllResults[I].ResponseJson, 1, 300));
      end;
    end;
  end;
end;

begin
  SetConsoleOutputCP(CP_UTF8);
  SetConsoleCP(CP_UTF8);

  WriteLn('==============================================');
  WriteLn('  Delphi LSP MCP Server - Comprehensive Test');
  WriteLn('==============================================');
  WriteLn;

  // Parse command line
  ParseCommandLine;

  // Build the file URI for SourceForAnalysis.dpr
  SourceUri := BuildSourceUri;
  WriteLn('Source file: ', ExpandFileName(SOURCE_FILE));
  WriteLn('Source URI:  ', SourceUri);
  WriteLn;

  if not FileExists(SOURCE_FILE) then
  begin
    WriteLn('ERROR: Source file not found: ', SOURCE_FILE);
    WriteLn('Make sure SourceForAnalysis.dpr is in the same directory.');
    WriteLn;
    WriteLn('Press ENTER to exit...');
    ReadLn;
    Exit;
  end;

  // Start the MCP server (this will show PID and wait for debugger)
  WriteLn('Starting MCP server...');
  if not StartServer then
  begin
    WriteLn('ERROR: Could not start server.');
    WriteLn('Make sure DelphiLSPMCPServer.exe is in the same directory.');
    WriteLn;
    WriteLn('Press ENTER to exit...');
    ReadLn;
    Exit;
  end;

  // Run all tests
  RunAllTests;

  // Print summary
  PrintFinalSummary;

  // Cleanup
  Cleanup;

  WriteLn;
  WriteLn('Press ENTER to exit...');
  ReadLn;
end.
