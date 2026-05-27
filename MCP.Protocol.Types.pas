unit MCP.Protocol.Types;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections,
  Common.Logging;

type
  TMCPProtocolVersion = string;

const
  MCP_PROTOCOL_VERSION = '2025-11-25';

type
  TMCPClientInfo = record
    Name: string;
    Version: string;
    function ToJSON: TJSONObject;
    class function FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPClientInfo; static;
    function ToString: string;
  end;

  TMCPServerInfo = record
    Name: string;
    Version: string;
    function ToJSON: TJSONObject;
    class function FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPServerInfo; static;
    function ToString: string;
  end;

  TMCPToolsCapability = record
    ListChanged: Boolean;
    function ToJSON: TJSONObject;
    class function FromJSON(AJson: TJSONObject): TMCPToolsCapability; static;
    function ToString: string;
  end;

  TMCPCapabilities = record
    Tools: TMCPToolsCapability;
    HasTools: Boolean;
    Resources: TMCPToolsCapability;
    HasResources: Boolean;
    Prompts: TMCPToolsCapability;
    HasPrompts: Boolean;
    Roots: TMCPToolsCapability;
    HasRoots: Boolean;
    HasSampling: Boolean;
    function ToJSON: TJSONObject;
    class function FromJSON(AJson: TJSONObject): TMCPCapabilities; static;
    function ToString: string;
    function GetEnabledCapabilities: TArray<string>;
  end;

  TMCPInitializeParams = record
    ProtocolVersion: TMCPProtocolVersion;
    Capabilities: TMCPCapabilities;
    ClientInfo: TMCPClientInfo;
    function ToJSON: TJSONObject;
    class function FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPInitializeParams; static;
    function ToString: string;
  end;

  TMCPInitializeResult = record
    ProtocolVersion: TMCPProtocolVersion;
    Capabilities: TMCPCapabilities;
    ServerInfo: TMCPServerInfo;
    Instructions: string;
    HasInstructions: Boolean;
    function ToJSON: TJSONObject;
    class function FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPInitializeResult; static;
    function ToString: string;
  end;

  TMCPToolInputSchema = class
  public
    SchemaType: string;
    Properties: TJSONObject; // Owned
    Required: TArray<string>;
    constructor Create;
    destructor Destroy; override;
    function ToJSON: TJSONObject;
    class function FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPToolInputSchema; static;
    function ToString: string;
  end;

  TMCPTool = class
  public
    Name: string;
    Description: string;
    InputSchema: TMCPToolInputSchema; // Owned, optional
    constructor Create;
    destructor Destroy; override;
    function ToJSON: TJSONObject;
    class function FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPTool; static;
    function ToString: string;
  end;

  TMCPToolCallParams = class
  public
    Name: string;
    Arguments: TJSONObject; // Owned
    constructor Create;
    destructor Destroy; override;
    function ToJSON: TJSONObject;
    class function FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPToolCallParams; static;
    function ToString: string;
  end;

  TMCPContentItem = class
  public
    ContentType: string; // "text", "image", "resource"
    Text: string;
    Data: string; // base64 for image
    MimeType: string;
    constructor Create;
    destructor Destroy; override;
    function ToJSON: TJSONObject;
    class function FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPContentItem; static;
    function ToString: string;
  end;

  TMCPToolCallResult = class
  public
    Content: TObjectList<TMCPContentItem>; // Owned
    IsError: Boolean;
	constructor Create;
    destructor Destroy; override;
    function ToJSON: TJSONObject;
    class function FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPToolCallResult; static;
    function ToString: string;
    function GetContentText: string;
  end;

implementation

{ TMCPClientInfo }

function TMCPClientInfo.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('name', Name);
  Result.AddPair('version', Version);
end;

class function TMCPClientInfo.FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPClientInfo;
begin
  Result.Name := '';
  Result.Version := '';
  IsValid := False;
  if not Assigned(AJson) then
    Exit;
  IsValid :=
    AJson.TryGetValue<string>('name', Result.Name) and
    AJson.TryGetValue<string>('version', Result.Version);
end;

function TMCPClientInfo.ToString: string;
begin
  Result := Format('Client: %s v%s', [Name, Version]);
end;

{ TMCPServerInfo }

function TMCPServerInfo.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('name', Name);
  Result.AddPair('version', Version);
end;

class function TMCPServerInfo.FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPServerInfo;
begin
  Result.Name := '';
  Result.Version := '';
  IsValid := False;
  if not Assigned(AJson) then
    Exit;
  IsValid :=
    AJson.TryGetValue<string>('name', Result.Name) and
    AJson.TryGetValue<string>('version', Result.Version);
end;

function TMCPServerInfo.ToString: string;
begin
  Result := Format('Server: %s v%s', [Name, Version]);
end;

{ TMCPToolsCapability }

function TMCPToolsCapability.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  if ListChanged then
    Result.AddPair('listChanged', TJSONBool.Create(True));
end;

class function TMCPToolsCapability.FromJSON(AJson: TJSONObject): TMCPToolsCapability;
begin
  Result.ListChanged := False;
  if Assigned(AJson) then
    AJson.TryGetValue<Boolean>('listChanged', Result.ListChanged);
end;

function TMCPToolsCapability.ToString: string;
begin
  Result := Format('ToolsCapability(listChanged=%s)', [BoolToStr(ListChanged, True)]);
end;

{ TMCPCapabilities }

function TMCPCapabilities.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  if HasTools then
    Result.AddPair('tools', Tools.ToJSON);
  if HasResources then
    Result.AddPair('resources', Resources.ToJSON);
  if HasPrompts then
    Result.AddPair('prompts', Prompts.ToJSON);
  if HasRoots then
    Result.AddPair('roots', Roots.ToJSON);
  if HasSampling then
    Result.AddPair('sampling', TJSONObject.Create);
end;

class function TMCPCapabilities.FromJSON(AJson: TJSONObject): TMCPCapabilities;
var
  Val: TJSONValue;
begin
  Result.HasTools := False;
  Result.HasResources := False;
  Result.HasPrompts := False;
  Result.HasRoots := False;
  Result.HasSampling := False;
  if not Assigned(AJson) then
    Exit;

  Val := AJson.GetValue('tools');
  if Val is TJSONObject then
  begin
    Result.Tools := TMCPToolsCapability.FromJSON(TJSONObject(Val));
    Result.HasTools := True;
  end;

  Val := AJson.GetValue('resources');
  if Val is TJSONObject then
  begin
    Result.Resources := TMCPToolsCapability.FromJSON(TJSONObject(Val));
    Result.HasResources := True;
  end;

  Val := AJson.GetValue('prompts');
  if Val is TJSONObject then
  begin
    Result.Prompts := TMCPToolsCapability.FromJSON(TJSONObject(Val));
    Result.HasPrompts := True;
  end;

  Val := AJson.GetValue('roots');
  if Val is TJSONObject then
  begin
    Result.Roots := TMCPToolsCapability.FromJSON(TJSONObject(Val));
    Result.HasRoots := True;
  end;

  Result.HasSampling := Assigned(AJson.GetValue('sampling'));
end;

function TMCPCapabilities.GetEnabledCapabilities: TArray<string>;
begin
  SetLength(Result, 0);
  if HasTools then
  begin
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := 'tools';
  end;
  if HasResources then
  begin
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := 'resources';
  end;
  if HasPrompts then
  begin
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := 'prompts';
  end;
  if HasRoots then
  begin
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := 'roots';
  end;
  if HasSampling then
  begin
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := 'sampling';
  end;
end;

function TMCPCapabilities.ToString: string;
var
  Caps: string;
  I: Integer;
  Enabled: TArray<string>;
begin
  Enabled := GetEnabledCapabilities;
  if Length(Enabled) = 0 then
    Caps := 'none'
  else
  begin
    Caps := '';
    for I := 0 to High(Enabled) do
    begin
      if I > 0 then
        Caps := Caps + ', ';
      Caps := Caps + Enabled[I];
    end;
  end;
  Result := Format('Capabilities(%s)', [Caps]);
end;

{ TMCPInitializeParams }

function TMCPInitializeParams.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('protocolVersion', ProtocolVersion);
  Result.AddPair('capabilities', Capabilities.ToJSON);
  Result.AddPair('clientInfo', ClientInfo.ToJSON);
end;

class function TMCPInitializeParams.FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPInitializeParams;
var
  Val: TJSONValue;
  OkClient: Boolean;
begin
  IsValid := False;
  if not Assigned(AJson) then
    Exit;

  IsValid := AJson.TryGetValue<string>('protocolVersion', Result.ProtocolVersion);
  if not IsValid then
    Exit;

  Val := AJson.GetValue('capabilities');
  if Val is TJSONObject then
    Result.Capabilities := TMCPCapabilities.FromJSON(TJSONObject(Val))
  else
    Exit;

  Val := AJson.GetValue('clientInfo');
  if Val is TJSONObject then
    Result.ClientInfo := TMCPClientInfo.FromJSON(TJSONObject(Val), OkClient)
  else
    Exit;

  IsValid := OkClient;
end;

function TMCPInitializeParams.ToString: string;
begin
  Result := Format('InitializeParams(version=%s, %s, %s)',
    [ProtocolVersion, ClientInfo.ToString, Capabilities.ToString]);
end;

{ TMCPInitializeResult }

function TMCPInitializeResult.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('protocolVersion', ProtocolVersion);
  Result.AddPair('capabilities', Capabilities.ToJSON);
  Result.AddPair('serverInfo', ServerInfo.ToJSON);
  if HasInstructions then
    Result.AddPair('instructions', Instructions);
end;

class function TMCPInitializeResult.FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPInitializeResult;
var
  Val: TJSONValue;
  OkServer: Boolean;
begin
  IsValid := False;
  Result.HasInstructions := False;
  if not Assigned(AJson) then
    Exit;

  IsValid := AJson.TryGetValue<string>('protocolVersion', Result.ProtocolVersion);
  if not IsValid then
    Exit;

  Val := AJson.GetValue('capabilities');
  if Val is TJSONObject then
    Result.Capabilities := TMCPCapabilities.FromJSON(TJSONObject(Val))
  else
    Exit;

  Val := AJson.GetValue('serverInfo');
  if Val is TJSONObject then
    Result.ServerInfo := TMCPServerInfo.FromJSON(TJSONObject(Val), OkServer)
  else
    Exit;

  IsValid := OkServer;
  Result.HasInstructions := AJson.TryGetValue<string>('instructions', Result.Instructions);
end;

function TMCPInitializeResult.ToString: string;
var
  InstructionsStr: string;
begin
  if HasInstructions then
    InstructionsStr := ', has instructions'
  else
    InstructionsStr := '';
  Result := Format('InitializeResult(version=%s, %s, %s%s)',
    [ProtocolVersion, ServerInfo.ToString, Capabilities.ToString, InstructionsStr]);
end;

{ TMCPToolInputSchema }

constructor TMCPToolInputSchema.Create;
begin
  inherited Create;
  Properties := nil;
  Logger.Debug('[MCP.Protocol] ToolInputSchema created');
end;

destructor TMCPToolInputSchema.Destroy;
begin
  if Assigned(Properties) then
    Logger.Debug('[MCP.Protocol] ToolInputSchema destroyed with %d properties',
      [Properties.Count]);
  Properties.Free;
  inherited;
end;

function TMCPToolInputSchema.ToJSON: TJSONObject;
var
  Arr: TJSONArray;
  I: Integer;
begin
  Result := TJSONObject.Create;
  Result.AddPair('type', SchemaType);
  if Assigned(Properties) then
    Result.AddPair('properties', Properties.Clone as TJSONObject);
  if Length(Required) > 0 then
  begin
    Arr := TJSONArray.Create;
    for I := 0 to High(Required) do
      Arr.Add(Required[I]);
    Result.AddPair('required', Arr);
  end;
end;

class function TMCPToolInputSchema.FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPToolInputSchema;
var
  Arr: TJSONArray;
  I: Integer;
  Val: TJSONValue;
begin
  Result := TMCPToolInputSchema.Create;
  IsValid := False;
  if not Assigned(AJson) then
  begin
    FreeAndNil(Result);
    Exit;
  end;

  IsValid := AJson.TryGetValue<string>('type', Result.SchemaType);
  if not IsValid then
  begin
    FreeAndNil(Result);
    Exit;
  end;

  Val := AJson.GetValue('properties');
  if Val is TJSONObject then
    Result.Properties := TJSONObject(Val).Clone as TJSONObject;

  Arr := AJson.GetValue('required') as TJSONArray;
  if Assigned(Arr) then
  begin
    SetLength(Result.Required, Arr.Count);
    for I := 0 to Arr.Count - 1 do
      Result.Required[I] := Arr.Items[I].Value;
  end;
end;

function TMCPToolInputSchema.ToString: string;
var
  PropCount: Integer;
begin
  if Assigned(Properties) then
    PropCount := Properties.Count
  else
    PropCount := 0;
  Result := Format('InputSchema(type=%s, props=%d, required=%d)',
    [SchemaType, PropCount, Length(Required)]);
end;

{ TMCPTool }

constructor TMCPTool.Create;
begin
  inherited Create;
  InputSchema := nil;
  Logger.Debug('[MCP.Protocol] Tool created');
end;

destructor TMCPTool.Destroy;
begin
  if Assigned(InputSchema) then
    Logger.Debug('[MCP.Protocol] Tool "%s" destroyed with schema', [Name])
  else
    Logger.Debug('[MCP.Protocol] Tool "%s" destroyed', [Name]);
  InputSchema.Free;
  inherited;
end;

function TMCPTool.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('name', Name);
  Result.AddPair('description', Description);
  if Assigned(InputSchema) then
    Result.AddPair('inputSchema', InputSchema.ToJSON);
end;

class function TMCPTool.FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPTool;
var
  Val: TJSONValue;
  OkSchema: Boolean;
begin
  Result := TMCPTool.Create;
  IsValid := False;
  if not Assigned(AJson) then
  begin
    FreeAndNil(Result);
    Exit;
  end;

  IsValid :=
    AJson.TryGetValue<string>('name', Result.Name) and
    AJson.TryGetValue<string>('description', Result.Description);
  if not IsValid then
  begin
    FreeAndNil(Result);
    Exit;
  end;

  Val := AJson.GetValue('inputSchema');
  if Val is TJSONObject then
  begin
    Result.InputSchema := TMCPToolInputSchema.FromJSON(TJSONObject(Val), OkSchema);
    IsValid := OkSchema;
    if not IsValid then
    begin
      FreeAndNil(Result);
      Exit;
    end;
  end
  else
    IsValid := True;
end;

function TMCPTool.ToString: string;
begin
  Result := Format('Tool(name="%s", desc="%s", hasSchema=%s)',
    [Name, Copy(Description, 1, 50), BoolToStr(Assigned(InputSchema), True)]);
end;

{ TMCPToolCallParams }

constructor TMCPToolCallParams.Create;
begin
  inherited Create;
  Arguments := nil;
  Logger.Debug('[MCP.Protocol] ToolCallParams created');
end;

destructor TMCPToolCallParams.Destroy;
begin
  if Assigned(Arguments) then
    Logger.Debug('[MCP.Protocol] ToolCallParams for "%s" destroyed with %d arguments',
      [Name, Arguments.Count]);
  Arguments.Free;
  inherited;
end;

function TMCPToolCallParams.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('name', Name);
  if Assigned(Arguments) then
    Result.AddPair('arguments', Arguments.Clone as TJSONObject);
end;

class function TMCPToolCallParams.FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPToolCallParams;
var
  Val: TJSONValue;
begin
  Result := TMCPToolCallParams.Create;
  IsValid := False;
  if not Assigned(AJson) then
  begin
    FreeAndNil(Result);
    Exit;
  end;

  IsValid := AJson.TryGetValue<string>('name', Result.Name);
  if not IsValid then
  begin
    FreeAndNil(Result);
    Exit;
  end;

  Val := AJson.GetValue('arguments');
  if Val is TJSONObject then
    Result.Arguments := TJSONObject(Val).Clone as TJSONObject;
end;

function TMCPToolCallParams.ToString: string;
begin
  Result := Format('ToolCall(name="%s", hasArgs=%s)',
    [Name, BoolToStr(Assigned(Arguments), True)]);
end;

{ TMCPContentItem }

constructor TMCPContentItem.Create;
begin
  inherited Create;
  Logger.Debug('[MCP.Protocol] ContentItem created');
end;

destructor TMCPContentItem.Destroy;
begin
  Logger.Debug('[MCP.Protocol] ContentItem "%s" destroyed (size=%d)',
    [ContentType, Length(Text) + Length(Data)]);
  inherited;
end;

function TMCPContentItem.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('type', ContentType);
  if ContentType = 'text' then
    Result.AddPair('text', Text)
  else if ContentType = 'image' then
  begin
    Result.AddPair('data', Data);
    Result.AddPair('mimeType', MimeType);
  end;
end;

class function TMCPContentItem.FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPContentItem;
begin
  Result := TMCPContentItem.Create;
  IsValid := False;
  if not Assigned(AJson) then
  begin
    FreeAndNil(Result);
    Exit;
  end;

  IsValid := AJson.TryGetValue<string>('type', Result.ContentType);
  if not IsValid then
  begin
    FreeAndNil(Result);
    Exit;
  end;

  if Result.ContentType = 'text' then
    AJson.TryGetValue<string>('text', Result.Text)
  else if Result.ContentType = 'image' then
  begin
    AJson.TryGetValue<string>('data', Result.Data);
    AJson.TryGetValue<string>('mimeType', Result.MimeType);
  end;
end;

function TMCPContentItem.ToString: string;
begin
  if ContentType = 'text' then
    Result := Format('TextContent(len=%d, preview="%s")',
      [Length(Text), Copy(Text, 1, 50)])
  else if ContentType = 'image' then
    Result := Format('ImageContent(mime=%s, dataLen=%d)', [MimeType, Length(Data)])
  else
    Result := Format('Content(type=%s)', [ContentType]);
end;

{ TMCPToolCallResult }

constructor TMCPToolCallResult.Create;
begin
  inherited Create;
  Content := TObjectList<TMCPContentItem>.Create(True);
  IsError := False;
  Logger.Debug('[MCP.Protocol] ToolCallResult created');
end;

destructor TMCPToolCallResult.Destroy;
begin
  Logger.Debug('[MCP.Protocol] ToolCallResult destroyed (content=%d, isError=%s)',
    [Content.Count, BoolToStr(IsError, True)]);
  Content.Free;
  inherited;
end;

function TMCPToolCallResult.ToJSON: TJSONObject;
var
  Arr: TJSONArray;
  I: Integer;
begin
  Result := TJSONObject.Create;
  Arr := TJSONArray.Create;
  for I := 0 to Content.Count - 1 do
    Arr.Add(Content[I].ToJSON);
  Result.AddPair('content', Arr);
  if IsError then
    Result.AddPair('isError', TJSONBool.Create(True));
end;

class function TMCPToolCallResult.FromJSON(AJson: TJSONObject; out IsValid: Boolean): TMCPToolCallResult;
var
  Arr: TJSONArray;
  I: Integer;
  Item: TMCPContentItem;
  OkItem: Boolean;
begin
  Result := TMCPToolCallResult.Create;
  IsValid := False;
  if not Assigned(AJson) then
  begin
    FreeAndNil(Result);
    Exit;
  end;

  Arr := AJson.GetValue('content') as TJSONArray;
  if not Assigned(Arr) then
  begin
    FreeAndNil(Result);
    Exit;
  end;

  for I := 0 to Arr.Count - 1 do
  begin
    if Arr.Items[I] is TJSONObject then
    begin
      Item := TMCPContentItem.FromJSON(TJSONObject(Arr.Items[I]), OkItem);
      if OkItem then
        Result.Content.Add(Item)
      else
        Item.Free;
    end;
  end;

  Result.IsError := False;
  AJson.TryGetValue<Boolean>('isError', Result.IsError);
  IsValid := True;
end;

function TMCPToolCallResult.ToString: string;
begin
  Result := Format('ToolCallResult(content=%d, isError=%s)',
    [Content.Count, BoolToStr(IsError, True)]);
end;

function TMCPToolCallResult.GetContentText: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Content.Count - 1 do
  begin
    if Content[I].ContentType = 'text' then
    begin
      if Result <> '' then
        Result := Result + sLineBreak;
      Result := Result + Content[I].Text;
    end;
  end;
end;

end.
