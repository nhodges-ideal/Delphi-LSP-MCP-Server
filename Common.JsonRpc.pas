unit Common.JsonRpc;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.SyncObjs,
  System.Generics.Collections,
  Common.Logging;

type
  // JSON-RPC 2.0 Error Codes
  TJsonRpcErrorCode = class
  public const
    ParseError = -32700;
    InvalidRequest = -32600;
    MethodNotFound = -32601;
    InvalidParams = -32602;
    InternalError = -32603;
    // Server error range: -32000 to -32099
    ServerErrorStart = -32000;
    ServerErrorEnd = -32099;

    class function GetErrorMessage(ACode: Integer): string; static;
  end;

  // JSON-RPC 2.0 Message Types
  TJsonRpcMessageType = (jmtRequest, jmtResponse, jmtNotification, jmtInvalid);

  // Helper record for parse results
  TJsonRpcParseResult = record
    Success: Boolean;
    MessageType: TJsonRpcMessageType;
    Error: string;
    ObjectType: string;
  end;

  // JSON-RPC 2.0 Error
  TJsonRpcError = class
  private
    FCode: Integer;
    FMessage: string;
    FData: TJSONValue;
    FLogContext: ILogContext;
  public
    constructor Create(ACode: Integer; const AMessage: string; AData: TJSONValue = nil);
    destructor Destroy; override;
    function ToJSON: TJSONObject;
    class function FromJSON(AJson: TJSONObject): TJsonRpcError;
    function ToString: string; override;

    property Code: Integer read FCode write FCode;
    property Message: string read FMessage write FMessage;
    property Data: TJSONValue read FData write FData;
  end;

  // JSON-RPC 2.0 Request
  TJsonRpcRequest = class
  private
    FId: TJSONValue;
    FMethod: string;
    FParams: TJSONValue;
    FLogContext: ILogContext;
    FCreatedAt: TDateTime;
  public
    constructor Create(const AMethod: string; AParams: TJSONValue = nil; AId: TJSONValue = nil);
    destructor Destroy; override;
    function ToJSON: TJSONObject;
    class function FromJSON(AJson: TJSONObject; out AError: string): TJsonRpcRequest;
    function ToString: string; override;

    property Id: TJSONValue read FId write FId;
    property Method: string read FMethod write FMethod;
    property Params: TJSONValue read FParams write FParams;
    property CreatedAt: TDateTime read FCreatedAt;
  end;

  // JSON-RPC 2.0 Response
  TJsonRpcResponse = class
  private
    FId: TJSONValue;
    FResult: TJSONValue;
    FError: TJsonRpcError;
    FLogContext: ILogContext;
    FCreatedAt: TDateTime;
  public
    constructor Create(AId: TJSONValue; AResult: TJSONValue = nil; AError: TJsonRpcError = nil);
    destructor Destroy; override;
    function ToJSON: TJSONObject;
    class function FromJSON(AJson: TJSONObject; out AError: string): TJsonRpcResponse;
    function IsError: Boolean;
    function ToString: string; override;

    property Id: TJSONValue read FId write FId;
    property Result: TJSONValue read FResult write FResult;
    property Error: TJsonRpcError read FError write FError;
    property CreatedAt: TDateTime read FCreatedAt;
  end;

  // JSON-RPC 2.0 Notification
  TJsonRpcNotification = class
  private
    FMethod: string;
    FParams: TJSONValue;
    FLogContext: ILogContext;
    FCreatedAt: TDateTime;
  public
    constructor Create(const AMethod: string; AParams: TJSONValue = nil);
    destructor Destroy; override;
    function ToJSON: TJSONObject;
    class function FromJSON(AJson: TJSONObject; out AError: string): TJsonRpcNotification;
    function ToString: string; override;

    property Method: string read FMethod write FMethod;
    property Params: TJSONValue read FParams write FParams;
    property CreatedAt: TDateTime read FCreatedAt;
  end;

  // Helper class for JSON-RPC operations
  TJsonRpcHelper = class
  private
    class var FNextId: Integer;
    class var FDebugMode: Boolean;
    class var FLogContext: ILogContext;
    class var FStatistics: TDictionary<string, Integer>;
    class procedure UpdateStats(const AOperation: string); static;
    class procedure LogDebug(const Msg: string; const Args: array of const); static;
    class function IdToStr(const AId: TJSONValue): string; static;
  public
    class constructor Create;
    class destructor Destroy;
    class function GenerateId: Integer;
    class function CreateRequest(const AMethod: string; AParams: TJSONValue = nil): TJsonRpcRequest;
    class function CreateNotification(const AMethod: string; AParams: TJSONValue = nil): TJsonRpcNotification;
    class function CreateSuccessResponse(AId: TJSONValue; AResult: TJSONValue): TJsonRpcResponse;
    class function CreateErrorResponse(AId: TJSONValue; ACode: Integer; const AMessage: string; AData: TJSONValue = nil): TJsonRpcResponse;
    class function ParseMessage(const AJsonText: string; out AMessageType: TJsonRpcMessageType; out AError: string): TObject;
    class function CloneJSONValue(AValue: TJSONValue): TJSONValue;
    class function GetStatistics: string; static;
    class property DebugMode: Boolean read FDebugMode write FDebugMode;
  end;

implementation

uses
  System.StrUtils;

{ TJsonRpcErrorCode }

class function TJsonRpcErrorCode.GetErrorMessage(ACode: Integer): string;
begin
  case ACode of
    ParseError: Result := 'Parse error';
    InvalidRequest: Result := 'Invalid request';
    MethodNotFound: Result := 'Method not found';
    InvalidParams: Result := 'Invalid params';
    InternalError: Result := 'Internal error';
  else
    if (ACode >= ServerErrorStart) and (ACode <= ServerErrorEnd) then
      Result := 'Server error'
    else
      Result := 'Unknown error';
  end;
end;

{ TJsonRpcError }

constructor TJsonRpcError.Create(ACode: Integer; const AMessage: string; AData: TJSONValue);
begin
  inherited Create;
  FLogContext := Logger.CreateContext('JsonRpcError');
  FCode := ACode;
  FMessage := AMessage;
  FData := TJsonRpcHelper.CloneJSONValue(AData);
  TJsonRpcHelper.LogDebug('Error created: %d - %s', [ACode, AMessage]);
end;

destructor TJsonRpcError.Destroy;
begin
  TJsonRpcHelper.LogDebug('Error destroyed: %d - %s', [FCode, FMessage]);
  FData.Free;
  inherited;
end;

function TJsonRpcError.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('code', TJSONNumber.Create(FCode));
  Result.AddPair('message', FMessage);
  if Assigned(FData) then
    Result.AddPair('data', FData.Clone as TJSONValue);
end;

class function TJsonRpcError.FromJSON(AJson: TJSONObject): TJsonRpcError;
var
  Code: Integer;
  Msg: string;
  Data: TJSONValue;
begin
  if not AJson.TryGetValue<Integer>('code', Code) then
    Code := TJsonRpcErrorCode.InternalError;
  if not AJson.TryGetValue<string>('message', Msg) then
    Msg := 'Unknown error';
  Data := AJson.GetValue('data');
  Result := TJsonRpcError.Create(Code, Msg, Data);
end;

function TJsonRpcError.ToString: string;
begin
  Result := Format('Error(%d): %s', [FCode, FMessage]);
  if Assigned(FData) then
    Result := Result + ' (with data)';
end;

{ TJsonRpcRequest }

constructor TJsonRpcRequest.Create(const AMethod: string; AParams: TJSONValue; AId: TJSONValue);
begin
  inherited Create;
  FLogContext := Logger.CreateContext('JsonRpcRequest');
  FCreatedAt := Now;
  FMethod := AMethod;
  FParams := TJsonRpcHelper.CloneJSONValue(AParams);
  FId := TJsonRpcHelper.CloneJSONValue(AId);
  TJsonRpcHelper.LogDebug('Request created: %s (ID: %s)', [AMethod,
    TJsonRpcHelper.IdToStr(AId)]);
end;

destructor TJsonRpcRequest.Destroy;
begin
  TJsonRpcHelper.LogDebug('Request destroyed: %s', [FMethod]);
  FParams.Free;
  FId.Free;
  inherited;
end;

function TJsonRpcRequest.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('jsonrpc', '2.0');
  Result.AddPair('method', FMethod);
  if Assigned(FParams) then
    Result.AddPair('params', FParams.Clone as TJSONValue);
  if Assigned(FId) then
    Result.AddPair('id', FId.Clone as TJSONValue);
end;

class function TJsonRpcRequest.FromJSON(AJson: TJSONObject; out AError: string): TJsonRpcRequest;
var
  Method: string;
  Params, Id: TJSONValue;
begin
  Result := nil;
  AError := '';

  if not AJson.TryGetValue<string>('method', Method) then
  begin
    AError := 'Missing "method" field';
    Exit;
  end;

  Params := AJson.GetValue('params');
  Id := AJson.GetValue('id');

  try
    Result := TJsonRpcRequest.Create(Method, Params, Id);
  except
    on E: Exception do
      AError := 'Failed to create request: ' + E.Message;
  end;
end;

function TJsonRpcRequest.ToString: string;
begin
  Result := Format('Request(method=%s, id=%s, hasParams=%s)',
    [FMethod,
     TJsonRpcHelper.IdToStr(FId),
     BoolToStr(Assigned(FParams), True)]);
end;

{ TJsonRpcResponse }

constructor TJsonRpcResponse.Create(AId: TJSONValue; AResult: TJSONValue; AError: TJsonRpcError);
begin
  inherited Create;
  FLogContext := Logger.CreateContext('JsonRpcResponse');
  FCreatedAt := Now;
  FId := TJsonRpcHelper.CloneJSONValue(AId);
  FResult := TJsonRpcHelper.CloneJSONValue(AResult);
  FError := AError;
  TJsonRpcHelper.LogDebug('Response created for ID: %s (isError=%s)',
    [TJsonRpcHelper.IdToStr(AId), BoolToStr(Assigned(AError), True)]);
end;

destructor TJsonRpcResponse.Destroy;
begin
  TJsonRpcHelper.LogDebug('Response destroyed for ID: %s',
    [TJsonRpcHelper.IdToStr(FId)]);
  FId.Free;
  FResult.Free;
  FError.Free;
  inherited;
end;

function TJsonRpcResponse.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('jsonrpc', '2.0');

  if Assigned(FId) then
    Result.AddPair('id', FId.Clone as TJSONValue)
  else
    Result.AddPair('id', TJSONNull.Create);

  if Assigned(FError) then
    Result.AddPair('error', FError.ToJSON)
  else
  begin
    if Assigned(FResult) then
      Result.AddPair('result', FResult.Clone as TJSONValue)
    else
      Result.AddPair('result', TJSONNull.Create);
  end;
end;

class function TJsonRpcResponse.FromJSON(AJson: TJSONObject; out AError: string): TJsonRpcResponse;
var
  Id, ResultVal: TJSONValue;
  ErrorVal: TJSONValue;
  ErrorObj: TJsonRpcError;
begin
  Result := nil;
  AError := '';
  ErrorObj := nil;

  Id := AJson.GetValue('id');
  ErrorVal := AJson.GetValue('error');
  ResultVal := AJson.GetValue('result');

  if Assigned(ErrorVal) and Assigned(ResultVal) then
  begin
    AError := 'Response cannot have both "result" and "error"';
    Exit;
  end;

  if not Assigned(ErrorVal) and not Assigned(ResultVal) then
  begin
    AError := 'Response must have either "result" or "error"';
    Exit;
  end;

  try
    if Assigned(ErrorVal) and (ErrorVal is TJSONObject) then
      ErrorObj := TJsonRpcError.FromJSON(TJSONObject(ErrorVal));
    Result := TJsonRpcResponse.Create(Id, ResultVal, ErrorObj);
  except
    on E: Exception do
    begin
      ErrorObj.Free;
      AError := 'Failed to create response: ' + E.Message;
    end;
  end;
end;

function TJsonRpcResponse.IsError: Boolean;
begin
  Result := Assigned(FError);
end;

function TJsonRpcResponse.ToString: string;
begin
  if IsError then
    Result := Format('Response(id=%s, error=%s)',
      [TJsonRpcHelper.IdToStr(FId), FError.ToString])
  else
    Result := Format('Response(id=%s, hasResult=%s)',
      [TJsonRpcHelper.IdToStr(FId),
       BoolToStr(Assigned(FResult), True)]);
end;

{ TJsonRpcNotification }

constructor TJsonRpcNotification.Create(const AMethod: string; AParams: TJSONValue);
begin
  inherited Create;
  FLogContext := Logger.CreateContext('JsonRpcNotification');
  FCreatedAt := Now;
  FMethod := AMethod;
  FParams := TJsonRpcHelper.CloneJSONValue(AParams);
  TJsonRpcHelper.LogDebug('Notification created: %s', [AMethod]);
end;

destructor TJsonRpcNotification.Destroy;
begin
  TJsonRpcHelper.LogDebug('Notification destroyed: %s', [FMethod]);
  FParams.Free;
  inherited;
end;

function TJsonRpcNotification.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('jsonrpc', '2.0');
  Result.AddPair('method', FMethod);
  if Assigned(FParams) then
    Result.AddPair('params', FParams.Clone as TJSONValue);
end;

class function TJsonRpcNotification.FromJSON(AJson: TJSONObject; out AError: string): TJsonRpcNotification;
var
  Method: string;
  Params: TJSONValue;
begin
  Result := nil;
  AError := '';

  if not AJson.TryGetValue<string>('method', Method) then
  begin
    AError := 'Missing "method" field';
    Exit;
  end;

  Params := AJson.GetValue('params');

  try
    Result := TJsonRpcNotification.Create(Method, Params);
  except
    on E: Exception do
      AError := 'Failed to create notification: ' + E.Message;
  end;
end;

function TJsonRpcNotification.ToString: string;
begin
  Result := Format('Notification(method=%s, hasParams=%s)',
    [FMethod, BoolToStr(Assigned(FParams), True)]);
end;

{ TJsonRpcHelper }

class constructor TJsonRpcHelper.Create;
begin
  FNextId := 0;
  FDebugMode := False;
  FLogContext := Logger.CreateContext('JsonRpcHelper');
  FStatistics := TDictionary<string, Integer>.Create;
  LogDebug('JsonRpcHelper initialized', []);
end;

class destructor TJsonRpcHelper.Destroy;
begin
  LogDebug('JsonRpcHelper destroyed - Stats: %s', [GetStatistics]);
  FStatistics.Free;
end;

class function TJsonRpcHelper.IdToStr(const AId: TJSONValue): string;
begin
  if Assigned(AId) then
	Result := AId.ToJSON
  else
	Result := 'null';
end;

class procedure TJsonRpcHelper.LogDebug(const Msg: string; const Args: array of const);
begin
  if FDebugMode then
  begin
	if Length(Args) > 0 then
	  FLogContext.LogFmt(Msg, Args)
	else
	  FLogContext.Log(Msg);
  end;
end;

class procedure TJsonRpcHelper.UpdateStats(const AOperation: string);
var
  Count: Integer;
begin
  if Assigned(FStatistics) then
  begin
    if FStatistics.TryGetValue(AOperation, Count) then
      FStatistics.AddOrSetValue(AOperation, Count + 1)
    else
      FStatistics.Add(AOperation, 1);
  end;
end;

class function TJsonRpcHelper.GetStatistics: string;
var
  Pair: TPair<string, Integer>;
begin
  Result := 'JSON-RPC Statistics: ';
  if Assigned(FStatistics) then
  begin
    for Pair in FStatistics do
      Result := Result + Format('%s=%d ', [Pair.Key, Pair.Value]);
    Result := Trim(Result);
  end;
end;

class function TJsonRpcHelper.GenerateId: Integer;
begin
  Result := TInterlocked.Increment(FNextId);
  LogDebug('Generated ID: %d', [Result]);
end;

class function TJsonRpcHelper.CreateRequest(const AMethod: string; AParams: TJSONValue): TJsonRpcRequest;
begin
  UpdateStats('CreateRequest');
  LogDebug('Creating request: %s', [AMethod]);
  Result := TJsonRpcRequest.Create(AMethod, AParams, TJSONNumber.Create(GenerateId));
end;

class function TJsonRpcHelper.CreateNotification(const AMethod: string; AParams: TJSONValue): TJsonRpcNotification;
begin
  UpdateStats('CreateNotification');
  LogDebug('Creating notification: %s', [AMethod]);
  Result := TJsonRpcNotification.Create(AMethod, AParams);
end;

class function TJsonRpcHelper.CreateSuccessResponse(AId: TJSONValue; AResult: TJSONValue): TJsonRpcResponse;
begin
  UpdateStats('CreateSuccessResponse');
  LogDebug('Creating success response for ID: %s', [IdToStr(AId)]);
  Result := TJsonRpcResponse.Create(AId, AResult, nil);
end;

class function TJsonRpcHelper.CreateErrorResponse(AId: TJSONValue; ACode: Integer; const AMessage: string; AData: TJSONValue): TJsonRpcResponse;
begin
  UpdateStats('CreateErrorResponse');
  LogDebug('Creating error response: ID=%s, Code=%d, Msg=%s',
    [IdToStr(AId), ACode, AMessage]);
  Result := TJsonRpcResponse.Create(AId, nil, TJsonRpcError.Create(ACode, AMessage, AData));
end;

class function TJsonRpcHelper.ParseMessage(const AJsonText: string; out AMessageType: TJsonRpcMessageType; out AError: string): TObject;
var
  JsonVal: TJSONValue;
  JsonObj: TJSONObject;
  JsonRpcVer: string;
  HasId, HasMethod, HasResult, HasError: Boolean;
begin
  Result := nil;
  AMessageType := jmtInvalid;
  AError := '';

  UpdateStats('ParseMessage');
  LogDebug('Parsing message (length: %d)', [Length(AJsonText)]);

  JsonVal := TJSONObject.ParseJSONValue(AJsonText);
  if not Assigned(JsonVal) then
  begin
    AError := 'Parse error: invalid JSON';
    LogDebug('Parse error: invalid JSON', []);
    Exit;
  end;

  try
    if not (JsonVal is TJSONObject) then
    begin
      AError := 'Parse error: JSON value is not an object';
      LogDebug('Parse error: not an object', []);
      Exit;
    end;

    JsonObj := TJSONObject(JsonVal);

    if not JsonObj.TryGetValue<string>('jsonrpc', JsonRpcVer) or (JsonRpcVer <> '2.0') then
    begin
      AError := 'Invalid Request: missing or invalid "jsonrpc" field, must be "2.0"';
      LogDebug('Parse error: invalid jsonrpc version: %s', [JsonRpcVer]);
      Exit;
    end;

    HasId := Assigned(JsonObj.GetValue('id'));
    HasMethod := Assigned(JsonObj.GetValue('method'));
    HasResult := Assigned(JsonObj.GetValue('result'));
    HasError := Assigned(JsonObj.GetValue('error'));

    LogDebug('Message detection: id=%s, method=%s, result=%s, error=%s',
      [BoolToStr(HasId, True), BoolToStr(HasMethod, True),
       BoolToStr(HasResult, True), BoolToStr(HasError, True)]);

    try
      if HasMethod and HasId then
      begin
        AMessageType := jmtRequest;
        Result := TJsonRpcRequest.FromJSON(JsonObj, AError);
        UpdateStats('ParseRequest');
        if Assigned(Result) then
          LogDebug('Parsed as request: %s', [TJsonRpcRequest(Result).ToString]);
      end
      else if HasMethod and not HasId then
      begin
        AMessageType := jmtNotification;
        Result := TJsonRpcNotification.FromJSON(JsonObj, AError);
        UpdateStats('ParseNotification');
        if Assigned(Result) then
          LogDebug('Parsed as notification: %s', [TJsonRpcNotification(Result).ToString]);
	  end
      else if (HasResult or HasError) then
      begin
        AMessageType := jmtResponse;
        Result := TJsonRpcResponse.FromJSON(JsonObj, AError);
        UpdateStats('ParseResponse');
        if Assigned(Result) then
          LogDebug('Parsed as response: %s', [TJsonRpcResponse(Result).ToString]);
      end
      else
      begin
        AError := 'Invalid Request: cannot determine message type';
        LogDebug('Parse error: cannot determine message type', []);
      end;
    except
      on E: Exception do
      begin
        AError := 'Parse error: ' + E.Message;
        LogDebug('Parse exception: %s - %s', [E.ClassName, E.Message]);
      end;
    end;

    if (AError <> '') and Assigned(Result) then
    begin
      FreeAndNil(Result);
      LogDebug('Parse failed, result freed', []);
    end;

    if AError = '' then
      LogDebug('Parse successful', []);

  finally
    JsonVal.Free;
  end;
end;

class function TJsonRpcHelper.CloneJSONValue(AValue: TJSONValue): TJSONValue;
begin
  if not Assigned(AValue) then
    Exit(nil);
  Result := AValue.Clone as TJSONValue;
  LogDebug('Cloned JSON value: %s', [AValue.ClassName]);
end;

initialization
  TJsonRpcHelper.FNextId := 0;
  TJsonRpcHelper.FDebugMode := False;

end.
