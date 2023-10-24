unit raylib_app;
interface
uses app, raylib, gfx_ext, engine;

implementation
uses wasm_embedded_backend, game;

procedure Raylib_App_Main; alias: 'main';
begin
	InitWasmEmbeddedBackend;

	InitDriver;

	InitWindow(320 * 3, 240 * 3, 'raylib [core] example - basic window');

	SetTraceLogLevel(LOG_WARNING);
    
    SetTargetFPS(30);

	R_Init;

	G_Init;

	repeat
        G_RunFrame;
        BeginDrawing;
            // ClearBackground(RAYWHITE);
            // DrawText('Congrats! You created your first window!', 190, 200, 20, LIGHTGRAY);

            ImageClearBackground(@mainImage, RED);
            G_Draw;

        R_SwapBuffers;
        EndDrawing;    
	until WindowShouldClose;

    CloseWindow;
end;

end.