program csonic;

{$ifdef fpc}
{$H-}
{$endif}

{$ifdef fpc}
  {$IFDEF DARWIN}
    {$linkFramework SDL2}
    {$linkFramework SDL2_image}
    {$linkFramework SDL2_ttf}
  {$endif}
{$endif}

uses
    {$ifdef UNIX}
    cthreads,
      {$ifdef fpc}
        {$ifndef WASM}
        classes,
        {$endif}
      {$endif}
    {$endif}

  {$ifdef WINDOWS}
  Windows,
  Classes,
  {$endif}
  app;

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

  {$ifdef DARWIN}
  // MacOS Lazarus workaround, for now.
  ChDir('/Users/mattj/games/csonic');
  {$endif}

  app.Main;
end.

