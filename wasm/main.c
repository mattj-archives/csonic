#include "raylib.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// extern int pastest();
// extern void ctest();
extern void G_RunFrame();

extern void G_Init();
extern void G_Draw();

Image mainImage;

typedef struct image_t {
    unsigned short width;
    unsigned short height;
    void *data;
} image_t;

void Image_Load_Impl(const char *filename, image_t *img) {
    printf("Image_Load_Impl %s\n", filename);

    Image i = LoadImage(filename);

    img->width = i.width;
    img->height = i.height;

    img->data = malloc(sizeof(Image));
    memcpy(img->data, &i, sizeof(Image));
}

void DrawSubImageTransparent(image_t img, short dstX, short dstY, short srcX, short srcY, short srcWidth, short srcHeight) {
    if(dstX < 0) {
        srcX -= dstX;
        srcWidth += dstX;
        dstX = 0;
    }

    if(dstY < 0) {
        srcY -= dstY;
        srcHeight += dstY;
        dstY = 0;
    }

    //if (srcWidth <= 0) return;


    Rectangle srcRect = {srcX, srcY, srcWidth, srcHeight};
    Rectangle dstRect = {dstX, dstY, srcWidth, srcHeight};
    ImageDraw(&mainImage, *(Image*)img.data,
        srcRect,
        dstRect,
        WHITE);
}

void DrawLineImpl(int x0, int y0, int x1, int y1, int r, int g, int b, int a) {
    Color c = {r, g, b, a};
    ImageDrawLine(&mainImage, x0, y0, x1, y1, c);
}

void DrawTextImpl(int x, int y, const char *str) {
    ImageDrawText(&mainImage, str, x, y, 12, WHITE);
}

int main(void)
{
    extern void InitWasmEmbeddedBackend();
    InitWasmEmbeddedBackend();

    extern void InitDriver();
    InitDriver();

    G_Init();

    InitWindow(320 * 2, 240 * 2, "raylib [core] example - basic window");

    mainImage = GenImageColor(320, 240, BLANK);
    Texture t = LoadTextureFromImage(mainImage);

    SetTraceLogLevel(LOG_WARNING);
    SetTargetFPS(30);
    // ctest();

    // printf("%d\n", pastest());
    

    while (!WindowShouldClose())
    {
        G_RunFrame();
        
        BeginDrawing();
            // ClearBackground(RAYWHITE);
            // DrawText("Congrats! You created your first window!", 190, 200, 20, LIGHTGRAY);

            // ImageClearBackground(&mainImage, RED);

            G_Draw();

            UpdateTexture(t, mainImage.data);

            DrawTextureEx(t, (Vector2){0, 0}, 0, 2, WHITE);
        EndDrawing();
    }

    CloseWindow();

    return 0;
}

