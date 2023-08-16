#include "raylib.h"
#include <stdio.h>

// extern int pastest();
// extern void ctest();
extern void G_RunFrame();

extern void G_Init();

typedef struct TFile {
    FILE *file;
} TFile;

bool File_OpenImpl(const char *fileName, TFile *file) {

    file->file = fopen(fileName, "rb");
        printf("File_OpenImpl: %s, %d\n", fileName, file->file);

    return file->file != NULL;
}
//function File_BlockReadImpl(_file: PFile; var buf; size: integer): integer; external;

int File_BlockReadImpl(TFile *file, void *buf, int size) {
    return fread(buf, size, 1, file->file);
}

void ConsoleLogImpl(const char *s) {
    printf("%s\n", s);
}

int main(void)
{
    InitWindow(800, 450, "raylib [core] example - basic window");
    // ctest();

    // printf("%d\n", pastest());
    G_Init();

    while (!WindowShouldClose())
    {
        G_RunFrame();
        
        BeginDrawing();
            ClearBackground(RAYWHITE);
            DrawText("Congrats! You created your first window!", 190, 200, 20, LIGHTGRAY);
        EndDrawing();
    }

    CloseWindow();

    return 0;
}

