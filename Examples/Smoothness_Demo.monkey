Strict

Public

' Preprocessor related:
#SMOOTHNESS_DEMO_DELTATIME = True ' False

' GLFW configuration:
#GLFW_WINDOW_TITLE="Smoothness Test"
#GLFW_WINDOW_WIDTH=640
#GLFW_WINDOW_HEIGHT=640

#GLFW_WINDOW_SAMPLES=0
#GLFW_WINDOW_RESIZABLE=False
#GLFW_WINDOW_DECORATED=True
#GLFW_WINDOW_FLOATING=False
#GLFW_WINDOW_FULLSCREEN=False

#GLFW_SWAP_INTERVAL=1

#MOJO_AUTO_SUSPEND_ENABLED=False
#MOJO_IMAGE_FILTERING_ENABLED=False

' Imports:
Import mojo2

#If SMOOTHNESS_DEMO_DELTATIME
	Import regal.deltatime
#End

' Classes:
Class Application Extends App Final
	' Constant variable(s):
	' Nothing so far.
	
	' Constructor(s):
	Method OnCreate:Int()
		' Constant variable(s):
		Const Size:Float = 64.0
		
		SetUpdateRate(0)
		
		#If TARGET = "glfw"
			SetSwapInterval(1)
		#End
		
		Graphics = New Canvas()
		
		#If SMOOTHNESS_DEMO_DELTATIME
			DeltaTime = New DeltaTime(60, 0.0, 4)
		#End
		
		Shader.SetDefaultShader(Shader.FastShader())
		
		Rectangles = New List<Rectangle>()
		
		For Local I:= 0 Until (DeviceHeight()/Size)
			Local FI:= Float(I)
			Local P:= (FI*Size)
			
			Rectangles.AddLast(New Rectangle(P, P, Size, Size, 2.0, Rectangle.RIGHT)) ' (Min(FI+2.0, 5.0))
		Next
		
		Capped = True
		
		' Return the default response.
		Return 0
	End
	
	' Methods:
	Method OnUpdate:Int()
		#If SMOOTHNESS_DEMO_DELTATIME
			DeltaTime.Update()
		#End
		
		UpTime = Millisecs()
		
		For Local R:= Eachin Rectangles
			#If SMOOTHNESS_DEMO_DELTATIME
				R.Update(DeltaTime)
			#Else
				R.Update()
			#End
		Next
		
		If (KeyHit(KEY_SPACE)) Then
			If (Not Capped) Then
				SetSwapInterval(1)
				
				Capped = True
			Else
				SetSwapInterval(0)
				
				Capped = False
			Endif
		Endif
		
		' Return the default response.
		Return 0
	End
	
	Method OnRender:Int()
		' Local variable(s):
		Local ColorTime:= (UpTime / 10)
		
		Graphics.Clear(Sin(ColorTime), 0.25, Cos(ColorTime))
		
		For Local R:= Eachin Rectangles
			R.Render(Graphics)
		Next
		
		Graphics.Flush()
		
		' Return the default response.
		Return 0
	End
	
	' Fields:
	Field Graphics:Canvas
	
	#If SMOOTHNESS_DEMO_DELTATIME
		Field DeltaTime:DeltaTime
	#End
	
	Field UpTime:Int
	
	' Collections:
	Field Rectangles:List<Rectangle>
	
	' Booleans / Flags:
	Field Capped:Bool
End

Class Rectangle
	' Constant variable(s):
	Const LEFT:= False
	Const RIGHT:= True
	
	' Constructor(s):
	Method New(X:Float, Y:Float, Width:Float, Height:Float, Speed:Float, Direction:Bool=RIGHT)
		Self.X = X
		Self.Y = Y
		
		Self.Width = Width
		Self.Height = Height
		
		Self.Speed = Speed
		
		Self.Direction = Direction
	End
	
	' Methods:
	#If SMOOTHNESS_DEMO_DELTATIME
		Method Update:Void(DeltaTime:DeltaTime)
			Local Delta:Float = DeltaTime.Delta
	#Else
		Method Update:Void()
			Local Delta:Float = 1.0
	#End
			If ((X+Width) >= DeviceWidth()) Then
				Direction = LEFT
			Elseif (X <= 0.0) Then
				Direction = RIGHT
			Endif
			
			Select Direction
				Case LEFT
					X -= (Speed * Delta)
				Case RIGHT
					X += (Speed * Delta)
			End Select
			
			Return
		End
	
	Method Render:Void(Graphics:DrawList)
		Graphics.SetColor(1.0, 1.0, 1.0)
		
		Graphics.DrawRect(X, Y, Width, Height)
		
		Return
	End
	
	' Fields:
	Field X:Float, Y:Float
	Field Width:Float, Height:Float
	
	Field Speed:Float
	
	' Booleans / Flags:
	Field Direction:Bool
End

' Functions:
Function Main:Int()
	New Application()
	
	' Return the default response.
	Return 0
End