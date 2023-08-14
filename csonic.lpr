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
    {$ifdef UNIX}
    cthreads,
    {$ifdef fpc}
    classes,
    {$endif}
    app;
    {$endif}

  {$ifdef WINDOWS}
  Windows,
  classes,
  app, Image;
  {$endif}

  {$ifndef fpc}
  app;
  {$endif}

{$ifdef WINDOWS}
procedure MoveConsoleWindow;
var wnd: HWND;
begin
  wnd := GetConsoleWindow;
  SetWindowPos(wnd, 0, 640 * 2 - 5, 0, 600, 1040, 0);
end;
{$endif}

begin
  {$ifdef WINDOWS}
  MoveConsoleWindow;
  {$endif}
  app.Main;
end.

