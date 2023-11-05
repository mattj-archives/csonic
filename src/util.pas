unit Util;

{$inline on}


interface

uses common;


function fix32ToInt(val: longint): longint; {$ifndef WASM} inline; {$endif}
function intToFix32(val: longint): longint; {$ifndef WASM} inline; {$endif}
function fix32Mul(val1, val2: longint): longint; {$ifndef WASM} inline; {$endif}
function floatToFix32(val: single): longint;
function Vector2Make(x, y: longint): TVector2;
procedure Log(const fmt: string; const args: array of const);
implementation
uses sysutils;
function fix32ToInt(val: longint): longint; {$ifndef WASM} inline;
{$endif}
begin
  //fix32ToInt := (val and $80000000) or ((val and $7fffffff) shr 4);

  fix32ToInt := SarLongint(val, FRAC_BITS);
end;

function intToFix32(val: longint): longint; {$ifndef WASM} inline;
{$endif}
begin
  //intToFix32 := val shl 3;

  intToFix32 := (val and $80000000) or ((val and $7fffffff) shl FRAC_BITS);
end;


function floatToFix32(val: single): longint;
begin
  floatToFix32 := round(val * (1 shl FRAC_BITS));
end;

function fix32Mul(val1, val2: longint): longint; {$ifndef WASM} inline;
{$endif}
var
  a, b: longint;
begin
  a := SarLongint(val1, FRAC_BITS shr 1);
  b := SarLongint(val2, FRAC_BITS shr 1);
  Result := a * b;
end;


function Vector2Make(x, y: longint): TVector2;
begin
  Result.x := x;
  Result.y := y;
end;

procedure Log(const fmt: string; const args: array of const);
begin
  writeln(Format(fmt, args));
end;
end.
