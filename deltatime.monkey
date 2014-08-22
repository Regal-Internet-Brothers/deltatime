Strict

Public

' Imports:
#If BRL_GAMETARGET_IMPLEMENTED
	Import mojo.app
#Else
	Import mojoemulator
#End

' Classes:
Class DeltaTime
	' Constant & Global variable(s):
	Global Default_FPS:Int = 60
	Global Default_DeltaLog_Size:Int = 20
	Global Default_MinimumDelta:Float = 0.0
	
	' Constructor(s):
	Method New(MinimumDelta:Float=Default_MinimumDelta)
		Construct(MinimumDelta)
	End
	
	Method New(FPS:Int, MinimumDelta:Float=Default_MinimumDelta)
		Construct(FPS, MinimumDelta)
	End
	
	Method Construct:DeltaTime(MinimumDelta:Float=Default_MinimumDelta)
		' Local variable(s):
		Local FPS:= UpdateRate()
		
		If (FPS <> 0) Then
			Self.UseUpdateRate = True
		Endif
		
		' Call the main implementation.
		Return Construct(FPS)
	End
	
	Method Construct:DeltaTime(FPS:Int, MinimumDelta:Float=Default_MinimumDelta)
		If (FPS = 0) Then
			FPS = Default_FPS
		Endif
		
		' Assign the ideal frame-rate to the input.
		Self.IdealFPS = FPS
		
		' Set the previous frame's time value to the current time.
		Self.TimePreviousFrame = Millisecs()
		
		' Assign the current frame's time-value to the same as the previous frame.
		Self.TimeCurrentFrame = Self.TimePreviousFrame ' Millisecs()
		
		' Set the minimum delta-value.
		Self.MinimumDelta = MinimumDelta
		
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
		
		' Set the 'delta' to 0.0.
		Delta = 0.0
		
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
		' Set all of the delta-log's elements to 0.0.
		For Local Index:Int = 0 Until DeltaLog.Length()
			DeltaLog[Index] = 0.0
		Next
		
		Return
	End
	
	Method Update:Void()
		' Check if we're supposed to be using the update-rate:
		If (UseUpdateRate) Then
			' Check if the update-rate is different from the ideal framerate.
			If (IdealFPS <> UpdateRate()) Then
				' "Reset" using the new update-rate.
				Reset(UpdateRate(), True)
			Endif
		Endif
		
		' Capture the current time (In milliseconds):
		TimePreviousFrame = TimeCurrentFrame
		TimeCurrentFrame = Millisecs()
		
		' Update intervals:
		DeltaLog[DeltaNode] = Float(TimeCurrentFrame-TimePreviousFrame) * IdealInterval
		DeltaNode = (DeltaNode+1) Mod DeltaLog.Length()
		
		' Calculate the current delta:
		
		' Assign the delta to 0.0 before anything else.
		Delta = 0.0
		
		' Iterate through the delta-log, and add to the delta.
		For Local Index:Int = 0 Until DeltaLog.Length()
			Delta += DeltaLog[Index]
		Next
		
		' Fix the delta value. (Calculate an average/mean)
		Delta /= DeltaLog.Length()
		
		Delta = Max(Delta, MinimumDelta)
		
		' Assign the value of the inverted delta.
		InvDelta = 1.0 / Delta
		
		Return
	End
	
	' Properties:
	Method IdealFPS:Int() Property
		Return Self._IdealFPS
	End
	
	Method IdealFPS:Void(Input:Int) Property
		Self._IdealFPS = Input
		
		If (IdealFPS <> 0) Then
			IdealInterval = 1.0/(1000.0/Float(IdealFPS))
		Else
			IdealInterval = 0.0
		Endif
		
		Return
	End
	
	' Fields (Public):
	
	' Ideal values:
	Field IdealInterval:Float
	
	' Intervals:
	Field TimePreviousFrame:Int
	Field TimeCurrentFrame:Int
	
	' Delta values:
	Field DeltaLog:Float[Default_DeltaLog_Size]
	Field DeltaNode:Int
	
	Field Delta:Float
	Field MinimumDelta:Float
	Field InvDelta:Float
	
	' Flags:
	Field UseUpdateRate:Bool
	
	' Fields (Private):
	Private
	
	' Ideal values:
	Field _IdealFPS:Int
	
	Public
End

' Functions:
' Nothing so far.