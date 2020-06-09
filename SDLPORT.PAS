unit SDLPort;

interface

  type TPalette = Array[0..255,0..2] of byte;

  procedure Init;
  procedure Deinit;

  procedure SetPalette(input : TPalette);
  procedure Render(buffer : array of byte);
  procedure WaitRaster;

  function KeyPressed : boolean;
  procedure WaitForKeyPress(var ch1, ch2 : char);

  procedure Wait(ms : integer);

implementation

  uses sdl2;
  const xRes = 320;
        yRes = 200;
        targetFrames = 70;
        aspect: real = xRes / yRes;

  var windowMultiplier: integer;
      window: PSDL_Window;
      renderer: PSDL_Renderer;
      originalSurface: PSDL_Surface;
      displaySurface: PSDL_Surface;
      displayTexture: PSDL_Texture;
      palette: array[0..255] of TSDL_Color;
      renderDestRect: TSDL_Rect;

      windowResized: boolean;
      fullScreen: boolean;

      timer: TSDL_TimerID;
      frameCount, lastFrameCount, subFrameCount, lastFrameTick: LongInt;

function TimerCallback(interval: UInt32; param: Pointer): UInt32; cdecl;
var frameIntervalMs, nowMs : LongInt;
begin
  frameIntervalMs := 1000 div targetFrames;
  nowMs := SDL_GetTicks();
  subFrameCount += nowMs - lastFrameTick;
  lastFrameTick := nowMs;

  while (subFrameCount >= frameIntervalMs) do
  begin
    dec(subFrameCount, frameIntervalMs);
    inc(framecount);
  end;

  TimerCallback:=interval;
end;

procedure GetRenderRect(var rect : TSDL_Rect);
var windowW, windowH, h, w: LongInt;
begin
  SDL_GetRendererOutputSize(renderer, @windowW, @windowH);
  if (windowW / windowH <= aspect) then
  begin
    h := round(windowW / aspect);
    rect.x := 0;
    rect.y := (windowH - h) div 2;
    rect.w := windowW;
    rect.h := h;
  end
  else
  begin
    w := round(windowH * aspect);
    rect.x := (windowW - w) div 2;
    rect.y := 0;
    rect.w := w;
    rect.h := windowH;
  end;
end;

procedure RefreshRendering;
begin
  GetRenderRect(renderDestRect);
end;

procedure ResetWindowSize;
begin
  SDL_SetWindowSize(window, xRes * windowMultiplier, yRes * windowMultiplier);
  windowResized := true;
end;

procedure Init;
begin
  windowMultiplier := 2;

  if SDL_Init( SDL_INIT_VIDEO or SDL_INIT_TIMER ) < 0 then HALT;

  window := SDL_CreateWindow('SJ3',
            SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            xRes * windowMultiplier,
            yRes * windowMultiplier,
            SDL_WINDOW_SHOWN);
  if window = nil then Halt;

  renderer := SDL_CreateRenderer(window, -1, 0);
  if renderer = nil then Halt;

  // 8-bit surface for original data
  originalSurface := SDL_CreateRGBSurface(0, xRes, yRes, 8, 0, 0, 0, 0);
  if originalSurface = nil then Halt;

  // 32-bit display surface for converting 8-bit data to 32-bit
  displaySurface := SDL_CreateRGBSurface(0, xRes, yRes, 32, 0, 0, 0, 0);
  if displaySurface = nil then Halt;

  // Finally a texture for displaying 32-bit display data
  displayTexture := SDL_CreateTexture(renderer,
                 SDL_PIXELFORMAT_RGBA8888,
                 SDL_TEXTUREACCESS_STREAMING,
                 xRes,
                 yRes);
  if displayTexture = nil then Halt;

  SDL_SetWindowResizable(window, SDL_TRUE);

  RefreshRendering();

  windowResized := false;
  fullScreen := false;

  frameCount := 0;
  lastFrameCount := 0;
  subFrameCount := 0;
  lastFrameTick := SDL_GetTicks();

  timer := SDL_AddTimer(1, TimerCallback, nil);
end;

procedure Deinit;
begin
  SDL_RemoveTimer(timer);
  SDL_FreeSurface(originalSurface);
  SDL_FreeSurface(displaySurface);
  SDL_DestroyTexture(displayTexture);
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);

  SDL_Quit;
end;

procedure SetPalette(input : TPalette);
var index : integer;
begin
  for index:=0 to 255 do
   begin
     palette[index].r:=input[index,0] shl 2;
     palette[index].g:=input[index,1] shl 2;
     palette[index].b:=input[index,2] shl 2;
  end;

  SDL_SetPaletteColors(originalSurface^.format^.palette, @palette, 0, 256);
end;

procedure Render(buffer : array of byte);
var pixels : Pointer;
    pitch : LongInt;
begin
  if (windowResized) then
  begin
    RefreshRendering();
    windowResized := false;
  end;

  SDL_RenderClear(renderer);

  // Actual rendering
  SDL_LockSurface(originalSurface);
  Move(buffer, originalSurface^.pixels^, Sizeof(buffer));
  SDL_UnlockSurface(originalSurface);

  // Blit 8-bit surface to 32-bit surface
  SDL_BlitSurface(originalSurface, nil, displaySurface, nil);

  // Surface to texture
  SDL_LockTexture(displayTexture, nil, @pixels, @pitch);

  SDL_ConvertPixels(displaySurface^.w, displaySurface^.h,
                    displaySurface^.format^.format,
                    displaySurface^.pixels, displaySurface^.pitch,
                    SDL_PIXELFORMAT_RGBA8888,
                    pixels, pitch);

  SDL_UnlockTexture(displayTexture);

  // Render texture to display
  SDL_RenderCopy(renderer, displayTexture, nil, @renderDestRect);
  SDL_RenderPresent(renderer);
end;

procedure WaitRaster;
begin
  while(lastFrameCount = framecount) do
  begin
    SDL_Delay(1);
  end;
  lastFrameCount := framecount;
end;

function KeyPressed : boolean;
var event : TSDL_Event;
    pressed: boolean;
begin
  pressed:=false;

  while SDL_PollEvent(@event) = 1 do
  begin
    if ((event.type_= SDL_WINDOWEVENT) and
     (event.window.event = SDL_WINDOWEVENT_RESIZED)) then
    begin
      windowResized := true;
    end;

    if (event.type_= SDL_QUITEV) then
    begin
      Halt;
    end;

    if event.type_= SDL_KEYDOWN then
    begin
      pressed:=true;
      SDL_PushEvent(@event);
      break;
    end;
  end;
  KeyPressed:=pressed
end;

procedure ToggleFullscreen;
var flags : UInt32;
begin
  windowResized := true;

  fullScreen := not fullScreen;
  if (fullScreen) then flags := SDL_WINDOW_FULLSCREEN_DESKTOP else flags := 0;

  SDL_SetWindowFullscreen(window, flags);
end;

procedure WaitForKeyPress(var ch1, ch2:char);
var event : TSDL_Event;
    keyPressed: TSDL_ScanCode;
begin
  ch1:=#0;
  ch2:=#0;
  while (true) do
  begin
    while SDL_PollEvent(@event) = 1 do
    begin
      if event.type_= SDL_KEYDOWN then
      begin
        keyPressed := event.key.keysym.sym;

        if ((event.key.keysym._mod and KMOD_LALT) > 0) then
        begin
          Case event.key.keysym.scancode of
            SDL_SCANCODE_RETURN :
              begin
                toggleFullscreen;
                exit
              end;
            SDL_SCANCODE_R :
              begin
                ResetWindowSize;
                exit
              end;
            SDL_SCANCODE_KP_PLUS, SDL_SCANCODE_EQUALS :
              begin
                windowMultiplier := windowMultiplier + 1;
                ResetWindowSize;
                exit
              end;
            SDL_SCANCODE_KP_MINUS, SDL_SCANCODE_MINUS :
              begin
                if (windowMultiplier > 1) then
                begin
                  windowMultiplier := windowMultiplier - 1;
                  ResetWindowSize;
                  exit
                end;
              end;
          end;
        end;

        if (keyPressed < SDLK_CAPSLOCK) then ch1:=char(keyPressed);

        Case keyPressed of
          SDLK_LEFT : ch2:=#75;
          SDLK_RIGHT : ch2:=#77;
          SDLK_UP : ch2:=#72;
          SDLK_DOWN : ch2:=#80;

          SDLK_INSERT : ch2:=#82;
          SDLK_DELETE : ch2:=#83;
          SDLK_HOME : ch2:=#71;
          SDLK_END : ch2:=#79;
          SDLK_PAGEUP : ch2:=#73;
          SDLK_PAGEDOWN : ch2:=#81;

          SDLK_a : ch2:=#30;
          SDLK_b : ch2:=#48;
          SDLK_c : ch2:=#46;
          SDLK_d : ch2:=#32;
          SDLK_e : ch2:=#18;
          SDLK_f : ch2:=#33;
          SDLK_g : ch2:=#34;
          SDLK_h : ch2:=#35;
          SDLK_i : ch2:=#23;
          SDLK_j : ch2:=#36;
          SDLK_k : ch2:=#37;
          SDLK_l : ch2:=#38;
          SDLK_m : ch2:=#50;
          SDLK_n : ch2:=#49;
          SDLK_o : ch2:=#24;
          SDLK_p : ch2:=#25;
          SDLK_q : ch2:=#16;
          SDLK_r : ch2:=#19;
          SDLK_s : ch2:=#31;
          SDLK_t : ch2:=#20;
          SDLK_u : ch2:=#22;
          SDLK_v : ch2:=#47;
          SDLK_w : ch2:=#17;
          SDLK_x : ch2:=#45;
          SDLK_y : ch2:=#21;
          SDLK_z : ch2:=#44;
        end;
        exit;
      end;
    end;
    SDL_Delay(10);
  end;
end;

procedure Wait(ms : integer);
begin
  SDL_Delay(ms);
end;

end.

