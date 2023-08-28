#include "raylib.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// extern int pastest();
// extern void ctest();
extern void G_RunFrame();

extern void G_Init();
extern void G_Draw();


// void DrawSubImageTransparent(image_t img, short dstX, short dstY, short srcX, short srcY, short srcWidth, short srcHeight) {
//     if(dstX < 0) {
//         srcX -= dstX;
//         srcWidth += dstX;
//         dstX = 0;
//     }

//     if(dstY < 0) {
//         srcY -= dstY;
//         srcHeight += dstY;
//         dstY = 0;
//     }


//     Rectangle srcRect = {srcX, srcY, srcWidth, srcHeight};
//     Rectangle dstRect = {dstX, dstY, srcWidth, srcHeight};
//     ImageDraw(&mainImage, *(Image*)img.data,
//         srcRect,
//         dstRect,
//         WHITE);
// }

void DrawLineImpl(int x0, int y0, int x1, int y1, int r, int g, int b, int a) {

}


// int main(void)
// {
//     // extern void InitWasmEmbeddedBackend();
//     // InitWasmEmbeddedBackend();

//     extern void Raylib_App_Main();
//     Raylib_App_Main();


//     // InitWindow(320 * 3, 240 * 3, "raylib [core] example - basic window");

//     // mainImage = GenImageColor(320, 240, BLANK);
//     // Texture t = LoadTextureFromImage(mainImage);

//     // SetTraceLogLevel(LOG_WARNING);
//     // SetTargetFPS(30);
//     // ctest();

//     // printf("%d\n", pastest());
    

//     // while (!WindowShouldClose())
//     // {
//     //     G_RunFrame();
        
//     //     BeginDrawing();
//     //         // ClearBackground(RAYWHITE);
//     //         // DrawText("Congrats! You created your first window!", 190, 200, 20, LIGHTGRAY);

//     //         // ImageClearBackground(&mainImage, RED);

//     //         G_Draw();

//     //         UpdateTexture(t, mainImage.data);

//     //         DrawTextureEx(t, (Vector2){0, 0}, 0, 3, WHITE);
//     //     EndDrawing();
//     // }

//     // CloseWindow();

//     return 0;
// }

