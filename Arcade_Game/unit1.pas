unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ColorBox;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    ButtonTimer: TButton;
    ColorBox1: TColorBox;
    Image1: TImage;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure InitializeCanvas();
    procedure ButtonTimerClick(Sender: TObject);
    procedure DrawNewFrame();
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

Type
  car = Record
  x, lane, move : integer;
end;

var
  objWidth: integer;

  playerObj : car;
  enemyObj : car;

  speed: integer;
  startLine: integer;
  endLine: integer;

  startObjX: integer;
  endObjX: integer;


procedure TForm1.FormCreate(Sender: TObject);
begin
     InitializeCanvas();
end;

procedure TForm1.Button1Click(Sender: TObject);
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

procedure TForm1.InitializeCanvas();
begin
     objWidth:= 35;
     startLine := 10;
     endLine := 600;
     speed := 10;
     timer1.Enabled := false;

     startObjX:= startLine+objWidth;
     endObjX:= endLine-objWidth;

     //playerObj
     playerObj.x := startObjX;
     playerObj.lane := 1;
     playerObj.move := 0;

     //enemyObj
     enemyObj.x := endObjX;
     enemyObj.lane := 2;
     enemyObj.move := -1;

     Image1.canvas.Pen.Color:= clWhite;
     Image1.canvas.Pen.Style:= psSolid;
     Image1.canvas.Brush.Color:= clWhite;
     Image1.canvas.Brush.Style:= bsSolid;
     Image1.canvas.Rectangle(0, 0, Image1.width, Image1.height);

     Image1.Canvas.Pen.Color := clRed;
     Image1.Canvas.Pen.Style := psDash;

     Image1.Canvas.MoveTo(endLine+6, 0);
     Image1.Canvas.LineTo(endLine+6, Image1.Height);

     Image1.Canvas.MoveTo(startLine-6, 0);
     Image1.Canvas.LineTo(startLine-6, Image1.Height);

     //Horizontal Line
     Image1.Canvas.MoveTo(startLine, 50);
     Image1.Canvas.LineTo(endLine, 50);

     Image1.Canvas.MoveTo(startLine-6, 300);
     Image1.Canvas.LineTo(endLine+6, 300);

     //image1.Canvas.TextOut(x0-12, y0-6, '(0,0,0)');
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
     //set movement from left to right

     if enemyObj.x >= endObjX then
        enemyObj.move := -1;
     if enemyObj.x <= startObjX then
        enemyObj.move := 1;
     enemyObj.x := enemyObj.x + (enemyObj.move * speed);

     DrawNewFrame;
end;

procedure TForm1.DrawNewFrame();
begin

     //delete previous enemy object
     image1.Canvas.Brush.Color := clWhite;
     image1.Canvas.Pen.Color := clWhite;
     image1.Canvas.Pen.Style := psSolid;

     image1.Canvas.Rectangle(
     enemyObj.x-objWidth + (enemyObj.move*(-1 * speed)),
     enemyObj.lane * 75,
     enemyObj.x+objWidth + (enemyObj.move*(-1 * speed)),
     enemyObj.lane * 75 + 50);

     //draw enemy object
     image1.Canvas.Brush.Color := clRed;
     image1.Canvas.Pen.Color := clRed;
     image1.Canvas.Pen.Style := psSolid;

     image1.Canvas.Rectangle(
     enemyObj.x-objWidth,
     enemyObj.lane * 75,
     enemyObj.x+objWidth,
     enemyObj.lane * 75 + 50);

     //draw static object
     image1.Canvas.Brush.Color := ColorBox1.Selected;
     image1.Canvas.Pen.Color := ColorBox1.Selected;
     image1.Canvas.Pen.Style := psSolid;

     image1.Canvas.Rectangle(
     playerObj.x - objWidth,
     playerObj.lane * 75,
     playerObj.x + objWidth,
     playerObj.lane * 75 + 50);
end;

procedure TForm1.ButtonTimerClick(Sender: TObject);
begin
     Timer1.Enabled := not Timer1.Enabled;
end;

end.

