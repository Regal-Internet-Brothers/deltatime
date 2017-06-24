Strict

Public

' Imports:
#If BRL_GAMETARGET_IMPLEMENTED
	Import mojo.app
#Else
	Import regal.mojoemulator.app
#End

' Classes:
Class DeltaTime
	' Global variable(s):
	
	' Defualts:
	Global Default_FPS:Int = 60
	Global Default_DeltaLog_Size:Int = 20
	
	Global Default_MinimumDelta:Float = 0.0 ' 0.1
	
	' Constructor(s):
	Method New(MinimumDelta:Float=Default_MinimumDelta, DeltaLog_Size:Int=Default_DeltaLog_Size)
		Construct(MinimumDelta, DeltaLog_Size)
	End
	
	Method New(FPS:Int, MinimumDelta:Float=Default_MinimumDelta, DeltaLog_Size:Int=Default_DeltaLog_Size)
		Construct(FPS, MinimumDelta, DeltaLog_Size)
	End
	
	Method Construct:DeltaTime(MinimumDelta:Float=Default_MinimumDelta, DeltaLog_Size:Int=Default_DeltaLog_Size)
		' Local variable(s):
		Local FPS:= UpdateRate()
		
		If (FPS <> 0) Then
			Self.UseUpdateRate = True
		Endif
		
		' Call the main implementation.
		Return Construct(FPS, MinimumDelta, DeltaLog_Size)
	End
	
	Method Construct:DeltaTime(FPS:Int, MinimumDelta:Float=Default_MinimumDelta, DeltaLog_Size:Int=Default_DeltaLog_Size)
		If (FPS = 0) Then
			FPS = Default_FPS
		Endif
		
		' Assign the ideal frame-rate to the input.
		Self.IdealFPS = FPS
		
		' Set the minimum delta-value.
		Self.MinimumDelta = MinimumDelta
		
		If (DeltaLog_Size > 0) Then
			If (Self.DeltaLog.Length > 0) Then
				Self.DeltaLog = Self.DeltaLog.Resize(DeltaLog_Size)
			Else
				Self.DeltaLog = New Float[DeltaLog_Size]
			Endif
		Else
			If (Self.DeltaLog.Length > 0) Then
				Self.DeltaLog = []
			Endif
		Endif
		
		Self.LogScalar = (((1.5 / Self.DeltaLog.Length)) * 0.75)
		
		Reset()
		
		' Return this object so it may be pooled.
		Return Self
	End
	
	' Destructor(s):
	
	' This is just a quick wrapper for 'Free'.
	Method Discard:DeltaTime()
		Return Free()
	End
	
	Method Free:DeltaTime()
		Reset()
		
		' Return this object so it may be pooled.
		Return Self
	End
	
	' Methods:
	Method Reset:Void(FPS:Int, CatchUp:Bool=False)
		' Set the ideal framerate.
		IdealFPS = FPS
		
		' Call the main implementation.
		Reset(CatchUp)
		
		Return
	End
	
	Method Reset:Void(CatchUp:Bool=False)
		' Set the previous frame's time value to the current time.
		If (Not CatchUp) Then
			TimePreviousFrame = Millisecs()
		Else
			TimePreviousFrame = TimeCurrentFrame
		Endif
		
		' Assign the current frame's time-value to the same as the previous frame.
		TimeCurrentFrame = Millisecs()
		
		' Set our 'Delta' to 1.0.
		Delta = 1.0
		
		' Set the delta-node to zero.
		DeltaNode = 0
		
		' Reset the delta-log.
		ResetLog()
		
		Return
	End
	
	Method ResetLog:Void()
		ResetLog(DeltaLog)
		
		Return
	End
	
	Method ResetLog:Void(DeltaLog:Float[])
		' Set all of the delta-log's elements to 1.0.
		For Local Index:= 0 Until DeltaLog.Length
			DeltaLog[Index] = 1.0
		Next
		
		Return
	End
	
	Method Update:Void()
		' Check if we're supposed to be using the update-rate:
		If (UseUpdateRate) Then
			' Check if the update-rate is different from the ideal framerate.
			If (Self._IdealFPS <> UpdateRate()) Then ' IdealFPS
				' "Reset" using the new update-rate.
				Reset(UpdateRate(), True)
			Endif
		Endif
		
		' Capture the previous time-point, then capture the current one (Milliseconds):
		TimePreviousFrame = TimeCurrentFrame
		TimeCurrentFrame = Millisecs()
		
		' Calculate the current delta:
		
		' Calculate this frame's delta-value.
		Local FrameTime:= (Float(TimeCurrentFrame-TimePreviousFrame) * IdealInterval)
		
		' Check if we have a log to work with:
		If (DeltaLog.Length > 0) Then
			' Update the delta-log based on the current frame-time.
			DeltaLog[DeltaNode] = FrameTime
			
			' Move to the next node in the delta-log.
			DeltaNode = ((DeltaNode+1) Mod DeltaLog.Length)
			
			' Allocate a temporary delta-value.
			Local Value:= 0.0 ' 1.0
			
			' Iterate through the delta-log, and add to our new delta.
			For Local Index:= 0 Until DeltaLog.Length
				Value += DeltaLog[Index] ' *=
			Next
			
			' Fix the our delta, and apply it to this object. (Calculate an average/mean)
			Delta = Max(Value * LogScalar, MinimumDelta)
		Else
			' Use this frame's time-value directly.
			Delta = FrameTime
		Endif
		
		' Assign the value of the inverted delta.
		InvDelta = (1.0 / Delta)
		
		Return
	End
	
	' Properties:
	
	' The 'IdealFPS' property describes the ideal frame-rate/update-rate
	' that math/other using this object was built around:
	Method IdealFPS:Int() Property
		Return Self._IdealFPS
	End
	
	Method IdealFPS:Void(Input:Int) Property
		Self._IdealFPS = Input
		
		CalculateIdealInterval()
		
		Return
	End
	
	' Methods (Protected):
	Protected
	
	Method CalculateIdealInterval:Float()
		If (Self._IdealFPS <> 0) Then ' IdealFPS
			IdealInterval = (Float(Self._IdealFPS) * 0.001) ' 1000 ' IdealFPS
		Else
			IdealInterval = 0.0
		Endif
		
		' Return the calculated interval.
		Return IdealInterval
	End
	
	Public
	
	' Fields (Public):
	
	' The ideal interval this application should run at.
	Field IdealInterval:Float
	
	' These variables are used to take snapshots of the up-time of this
	' application (In milliseconds); they are then used to calculate a "delta-value":
	Field TimePreviousFrame:Int
	Field TimeCurrentFrame:Int
	
	' This acts as a log of "frame-differentials", which are then
	' processed into the active "delta-value" of the current frame.
	Field DeltaLog:Float[]
	
	' The current "node" (Position) in the 'DeltaLog' array.
	Field DeltaNode:Int
	
	' This will act as our scalar when approximating 'Delta'.
	Field LogScalar:Float
	
	' The last delta-value calculated from the 'DeltaLog'.
	Field Delta:Float
	
	' The minimum value 'Delta' can be.
	Field MinimumDelta:Float
	
	' A cache containing the inverse form of 'Delta'.
	Field InvDelta:Float
	
	' Booleans / Flags:
	
	' This describes if the update-rate of the application should be used.
	Field UseUpdateRate:Bool
	
	' Fields (Private):
	Private
	
	' Ideal values:
	
	' This acts as the internal storage for the 'IdealFPS' property.
	Field _IdealFPS:Int
	
	Public
End

' Functions:
' Nothing so far.