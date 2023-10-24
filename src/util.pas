unit Util;

{$inline on}
interface
function fix32ToInt(val: longint): longint; {$ifndef WASM} inline; {$endif}
function intToFix32(val: longint): longint; {$ifndef WASM} inline; {$endif}

implementation


function fix32ToInt(val: longint): longint; {$ifndef WASM} inline; {$endif}
begin
    fix32ToInt := val shr 3;
end;

function intToFix32(val: longint): longint; {$ifndef WASM} inline; {$endif}
begin
     intToFix32 := val shl 3;
end;


end.

