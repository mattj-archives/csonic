unit Util;

{$inline on}
interface
function fix32ToInt(val: longint): longint; {$ifndef WASM} inline; {$endif}
function intToFix32(val: longint): longint; {$ifndef WASM} inline; {$endif}
function floatToFix32(val: Single): longint;
implementation

function fix32ToInt(val: longint): longint; {$ifndef WASM} inline; {$endif}
begin
    //fix32ToInt := (val and $80000000) or ((val and $7fffffff) shr 4);

    fix32ToInt := SarLongint(val, 4);
end;

function intToFix32(val: longint): longint; {$ifndef WASM} inline; {$endif}
begin
     //intToFix32 := val shl 3;

     intToFix32 := (val and $80000000) or ((val and $3fffffff) shl 4);
end;


function floatToFix32(val: Single): longint;
begin
     floatToFix32 := round(val * (1 shl 4));
end;

end.

