unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonDown: TButton;
    ButtonUp: TButton;
    ButtonStart: TButton;
    Image1: TImage;
    LabelScore: TLabel;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure InitializeCanvas();
    procedure ResetPickupSize();
    procedure Timer1Timer(Sender: TObject);
    procedure SpawnNewEnemy();
    procedure SpawnNewPickup();
    procedure DrawNewFrame();
    procedure DrawEnemy();
    procedure DrawPickup();
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonDownClick(Sender: TObject);
    procedure ButtonUpClick(Sender: TObject);
    function GetPickup(): boolean;
    function EnemyIsClose(): boolean;
    procedure EndGame();
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

Type
  titik = Record
  x, y : integer;
end;

Type
  car = Record
  x, lane: integer;
end;

Type
  enemy = Record
  x, lane : integer;
  dat : array [1..5] of titik;
end;

Type
  pickup = Record
  x, lane : integer;
  bangun : array [1..5] of titik;
  temp: integer;
end;

var
  objWidth: integer;

  playerObj : car;
  enemyObj : enemy;
  pickupObj : pickup;

  isPlaying: boolean;
  speed: integer;
  startLine: integer;
  endLine: integer;

  startObjX: integer;
  endObjX: integer;
  enemyDisappearX: integer;

  score: integer;

procedure TForm1.FormCreate(Sender: TObject);
begin
     InitializeCanvas();
end;

procedure TForm1.InitializeCanvas();
begin
     objWidth:= 35;
     startLine := 100;
     endLine := 700;
     isPlaying := false;
     speed := 8;
     score := 0;
     timer1.Enabled := isPlaying;

     startObjX:= startLine+objWidth;
     endObjX:= endLine-objWidth;
     enemyDisappearX:= -2 * objWidth;

     //playerObj
     playerObj.x := startObjX;
     playerObj.lane := 2;

     //enemyObj
     randomize;
     enemyObj.x := endObjX;
     enemyObj.lane := random(3)+1;

     enemyObj.dat[1].x := -20;
     enemyObj.dat[2].x := 0;
     enemyObj.dat[3].x := 20;
     enemyObj.dat[4].x := -30;
     enemyObj.dat[5].x := 30;

     enemyObj.dat[1].y := -30;
     enemyObj.dat[2].y := 30;
     enemyObj.dat[3].y := -30;
     enemyObj.dat[4].y := 9;
     enemyObj.dat[5].y := 9;

     //pickupObj
     pickupObj.x := endObjX;
     pickupObj.lane := random(3)+1;
     pickupObj.temp := 1;
     ResetPickupSize;
     //pickup can't spawn on the same line as enemy
     while pickupObj.lane = enemyObj.lane do
     pickupObj.lane := random(3)+1;

     //set white canvas
     Image1.canvas.Pen.Color:= clWhite;
     Image1.canvas.Pen.Style:= psSolid;
     Image1.canvas.Brush.Color:= clWhite;
     Image1.canvas.Brush.Style:= bsSolid;

     Image1.canvas.Rectangle(0, 0, Image1.width, Image1.height);

     //Start and End Lines
     Image1.Canvas.Pen.Color := clRed;
     Image1.Canvas.Pen.Style := psDash;

     Image1.Canvas.MoveTo(endLine+6, 0);
     Image1.Canvas.LineTo(endLine+6, Image1.Height);

     Image1.Canvas.MoveTo(startLine-6, 0);
     Image1.Canvas.LineTo(startLine-6, Image1.Height);

     //Horizontal Lines
     Image1.Canvas.MoveTo(startLine, 50);
     Image1.Canvas.LineTo(endLine, 50);

     Image1.Canvas.MoveTo(startLine-6, 300);
     Image1.Canvas.LineTo(endLine+6, 300);
end;

procedure TForm1.ResetPickupSize();
begin
  pickupObj.bangun[1].x := 0;
  pickupObj.bangun[2].x := -12;
  pickupObj.bangun[3].x := 0;
  pickupObj.bangun[4].x := 12;

  pickupObj.bangun[1].y := -12;
  pickupObj.bangun[2].y := 0;
  pickupObj.bangun[3].y := 12;
  pickupObj.bangun[4].y := 0;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
     enemyObj.x := enemyObj.x - speed;
     pickupObj.x := pickupObj.x - speed;
     SpawnNewEnemy;
     SpawnNewPickup;
     DrawNewFrame;

     if GetPickup then
     begin
        score := score +10;
     end;
     LabelScore.Caption:= IntToStr(score);

     //Check for object crashes
     if EnemyIsClose then
     begin
        if enemyObj.lane = playerObj.lane then
           EndGame;
     end;
end;

// memeriksa apabila enemyObj sejajar dengan playerObj
function TForm1.EnemyIsClose():boolean;
var
  res : boolean;
begin
     res := false;
     if enemyObj.x-objWidth < playerObj.x+objWidth then
     begin
          if enemyObj.x + objWidth > playerObj.x - objWidth then
             res := true;
     end;
     EnemyIsClose := res;
end;

function TForm1.GetPickup():boolean;
var
  res : boolean;
begin
     res := false;
     if pickupObj.x-objWidth < playerObj.x+objWidth then
     begin
          if pickupObj.x + objWidth > playerObj.x - objWidth then
          begin
            if pickupObj.lane = playerObj.lane then
            res := true;
          end;
     end;
     GetPickup := res;
end;

procedure TForm1.SpawnNewEnemy();
begin
     randomize;

     if enemyObj.x <= enemyDisappearX then
     begin
        enemyObj.x := endObjX;
        enemyObj.lane := random(3)+1;
     end;
end;

procedure TForm1.SpawnNewPickup();
begin
     if pickupObj.x <= enemyDisappearX then
     begin
        pickupObj.x := endObjX;
        pickupObj.lane := random(3)+1;

        //pickup can't spawn on the same line as enemy
        while pickupObj.lane = enemyObj.lane do
        pickupObj.lane := random(3)+1;
     end;
end;

procedure TForm1.DrawNewFrame();
begin
     image1.Canvas.Pen.Style := psSolid;

     //delete previous enemy object
     image1.Canvas.Brush.Color := clWhite;
     image1.Canvas.Pen.Color := clWhite;

     image1.Canvas.Rectangle(
     enemyObj.x-(objWidth+2) + speed,
     enemyObj.lane * 75 - 11,
     enemyObj.x+(objWidth+2) + speed,
     enemyObj.lane * 75 + 72);

     //delete previous pickup
     image1.Canvas.Brush.Color := clWhite;
     image1.Canvas.Pen.Color := clWhite;

     image1.Canvas.Rectangle(
     pickupObj.x-(objWidth) + speed,
     pickupObj.lane * 75 - 8,
     pickupObj.x+(objWidth) + speed,
     pickupObj.lane * 75 + 66);

     DrawPickup;
     DrawEnemy;

     //draw player object
     image1.Canvas.Brush.Color := clGreen;
     image1.Canvas.Pen.Color := clGreen;

     image1.Canvas.Rectangle(
     playerObj.x - objWidth,
     playerObj.lane * 75,
     playerObj.x + objWidth,
     playerObj.lane * 75 + 50);
end;

procedure TForm1.DrawEnemy();
Var
  hori, vert, i : integer;
  rotSpeed, temp : integer;
  sudutRad : double;
begin
     rotSpeed := 15;
     sudutRad := rotSpeed / 180 * pi;

     hori := enemyObj.x;
     vert := enemyObj.lane * 75 + 25;

     //Rotation
     for i:=1 to 5 do
     begin
       temp := enemyObj.dat[i].x;
       enemyObj.dat[i].x := Round(enemyObj.dat[i].x * cos(sudutRad) - enemyObj.dat[i].y * sin(sudutRad));
       enemyObj.dat[i].y := Round(temp * sin(sudutRad) + enemyObj.dat[i].y * cos(sudutRad));
     end;

     Image1.Canvas.Pen.Color:=clRed;
     Image1.Canvas.Pen.Style:=psSolid;

     Image1.Canvas.MoveTo(hori + enemyObj.dat[5].x, vert - enemyObj.dat[5].y);
     for i:=1 to 5 do
     begin
       Image1.Canvas.LineTo(hori + enemyObj.dat[i].x, vert - enemyObj.dat[i].y);
     end;
end;

procedure TForm1.DrawPickup();
var
     Xver, Yhor, i : integer;
begin
     image1.Canvas.Brush.Color := clBlue;
     image1.Canvas.Pen.Color := clBlue;

     //Scaling
     for i:=1 to 4 do
     begin
       pickupObj.bangun[i].x := Round(pickupObj.bangun[i].x * 1.05);
       pickupObj.bangun[i].y := Round(pickupObj.bangun[i].y * 1.05);
     end;

     pickupObj.temp := pickupObj.temp + 1;

     if pickupObj.temp > 20 then
     begin
       ResetPickupSize();
       pickupObj.temp := 1;
     end;

     Xver:= pickupObj.x;
     Yhor:= pickupObj.lane * 75 + 25;

     Image1.Canvas.MoveTo(Xver+pickupObj.bangun[4].x, Yhor-pickupObj.bangun[4].y);
     for i:=1 to 4 do
     begin
       Image1.Canvas.LineTo(Xver+pickupObj.bangun[i].x, Yhor-pickupObj.bangun[i].y);
     end;
end;

procedure TForm1.ButtonStartClick(Sender: TObject);
begin
     isPlaying := not isPlaying;
     Timer1.Enabled := isPlaying;

     if isPlaying then
         ButtonStart.Caption:='PAUSE'
     else
         ButtonStart.Caption:='START';
end;

procedure TForm1.ButtonUpClick(Sender: TObject);
begin
     if not EnemyIsClose then
     begin
       image1.Canvas.Brush.Color := clWhite;
       image1.Canvas.Pen.Color := clWhite;
       image1.Canvas.Pen.Style := psSolid;

       image1.Canvas.Rectangle(
       playerObj.x-objWidth,
       playerObj.lane * 75,
       playerObj.x+objWidth,
       playerObj.lane * 75 + 50);

       if playerObj.lane > 1 then
          playerObj.lane := playerObj.lane - 1;
     end;
end;

procedure TForm1.ButtonDownClick(Sender: TObject);
begin
     if not EnemyIsClose then
     begin
       image1.Canvas.Brush.Color := clWhite;
       image1.Canvas.Pen.Color := clWhite;
       image1.Canvas.Pen.Style := psSolid;

       image1.Canvas.Rectangle(
       playerObj.x-objWidth,
       playerObj.lane * 75,
       playerObj.x+objWidth,
       playerObj.lane * 75 + 50);

       if playerObj.lane < 3 then
          playerObj.lane := playerObj.lane + 1;
     end;
end;

procedure TForm1.EndGame();
begin
     Timer1.Enabled := false;
     LabelScore.Caption:= 'Game Over, Final Score: ' + IntToStr(score);
end;

end.

