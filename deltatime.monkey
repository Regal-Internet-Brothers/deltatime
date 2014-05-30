Strict

Public

' Imports:
#If BRL_GAMETARGET_IMPLEMENTED
	Import mojo.app
#Else
	Import time
#End

' Classes:
Class DeltaTime
	' Constant & Global variable(s):
	Global Default_FPS:Int = 60
	Global Default_DeltaLog_Size:Int = 20
	
	' Constructor(s):
	Method New(FPS:IntObject=Null)
		' Ensure we have a frame-rate to work with:
		If (FPS = Null) Then
			FPS = UpdateRate()
			
			If (FPS <> Null And FPS <> 0) Then
				Self.UseUpdateRate = True
			Endif
		Endif
		
		If (FPS = Null Or FPS = 0) Then FPS = Default_FPS
		
		' Assign the ideal frame-rate to the input.
		Self.IdealFPS = FPS
		
		' Set the ideal interval to 1.0 / the number of milliseconds per-frame.
		Self.IdealInterval = 1/(1000/Float(FPS))
		
		' Set the previous frame's time value to the current time.
		Self.TimePreviousFrame = Millisecs()
		
		' Assign the current frame's time-value to the same as the previous frame.
		Self.TimeCurrentFrame = Self.TimePreviousFrame ' Millisecs()
	End
	
	' Destructor(s):
	' Nothing so far.
	
	' Methods:
	Method Reset:Void(FPS:IntObject=Null, CatchUp:Bool=False)
		If (FPS <> Null) Then
			IdealFPS = FPS
			IdealInterval = 1/(1000/Float(IdealFPS))
		Endif
		
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
		
		' Assign the value of the inverted delta.
		InvDelta = 1.0 / Delta
		
		Return
	End
	
	' Fields:
	
	' Ideal values:
	Field IdealFPS:Int
	Field IdealInterval:Float
	
	' Intervals:
	Field TimePreviousFrame:Int
	Field TimeCurrentFrame:Int
	
	' Delta values:
	Field DeltaLog:Float[Default_DeltaLog_Size]
	Field DeltaNode:Int
	Field Delta:Float
	Field InvDelta:Float
	
	' Flags:
	Field UseUpdateRate:Bool
End

' Functions:
' Nothing so far.