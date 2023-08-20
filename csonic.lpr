program csonic;

{$ifdef fpc}
{$H-}
{$endif}

{$ifdef fpc}
  {$IFDEF DARWIN}
    {$linkFramework SDL2}
    {$linkFramework SDL2_image}
  {$endif}
{$endif}


uses
  app
    {$ifdef UNIX}
    ,cthreads
      {$ifdef fpc}
        {$ifndef WASM}
        ,classes
        {$endif}
      {$endif}
    {$endif}

  {$ifdef WINDOWS}
  ,Windows
  ,Classes
  {$endif}
  ;

{$ifdef WINDOWS}
procedure MoveConsoleWindow;
var wnd: HWND;
begin
  wnd := GetConsoleWindow;
  SetWindowPos(wnd, 0, 740, 0, 1000, 1040, 0);
end;
{$endif}

begin
  {$ifdef WINDOWS}
  MoveConsoleWindow;
  {$endif}
  app.Main;
end.

