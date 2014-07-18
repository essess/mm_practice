; -----------------------------------------------------------------------------
; Copyright (c) 2014 Sean Stasiak. All rights reserved.
; Developed by: Sean Stasiak <sstasiak@gmail.com>
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; with the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is furnished
; to do so, subject to the following conditions:
;
;   -Redistributions of source code must retain the above copyright notice,
;    this list of conditions and the following disclaimers.
;
;   -Redistributions in binary form must reproduce the above copyright notice,
;    this list of conditions and the following disclaimers in the documentation
;    and/or other materials provided with the distribution.
;
;   -Neither Sean Stasiak, nor the names of other contributors may be used to
;    endorse or promote products derived from this Software without specific
;    prior written permission.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS WITH
; THE SOFTWARE.
; -----------------------------------------------------------------------------

EnableExplicit

;------------| params: |--------------------
#FNAME = "practice.txt"

;#SEED = $nnnnn
#COLS = 5
#ROWS = 50

#FLD0_WIDTH = 6
#FLD0_MAX = 99999
#FLD0_MIN = 2

;#OP_ADD  = "+"
;#OP_SUB  = "-"
#OP_MULT = "*"
;#OP_DIV  = "/"

#FLD1_WIDTH = 3
#FLD1_MAX = 11
#FLD1_MIN = 11
;-------------------------------------------

Global.i seed
CompilerIf Defined( SEED, #PB_Constant )
  ;use the desired seed if specified
  seed = #SEED
CompilerElse
  CompilerSelect #PB_Compiler_Processor  
    CompilerCase #PB_Processor_x86
      seed = Random( 2147483647 )
    CompilerCase #PB_Processor_x64
      seed = Random( 9223372036854775807 )
    CompilerDefault
      CompilerError "unable to determine max integer value"
  CompilerEndSelect
CompilerEndIf
RandomSeed( seed )

Global.s ops
Global.i opcnt
CompilerIf Defined( OP_ADD, #PB_Constant )
  ops+#OP_ADD
  opcnt+1
CompilerEndIf
CompilerIf Defined( OP_SUB, #PB_Constant )
  ops+#OP_SUB
  opcnt+1
CompilerEndIf
CompilerIf Defined( OP_MULT, #PB_Constant )
  ops+#OP_MULT
  opcnt+1
CompilerEndIf
CompilerIf Defined( OP_DIV, #PB_Constant )
  ops+#OP_DIV
  opcnt+1
CompilerEndIf

Procedure.s op( )
  ProcedureReturn Mid( ops, Random(opcnt,1), 1 )
EndProcedure

Procedure.s params( )
  
  Protected.s sstr = "$"
  CompilerSelect #PB_Compiler_Processor  
    CompilerCase #PB_Processor_x86
      sstr + RSet( Hex(seed, #PB_Long), 8,  "0" )
    CompilerCase #PB_Processor_x64
      sstr + RSet( Hex(seed, #PB_Quad), 16, "0" )
    CompilerDefault
      CompilerError "unable to determine max integer width"
  CompilerEndSelect
  
  ProcedureReturn "file: "+#FNAME+", "+
                    "ops: "+ops+", "+
                    "seed: "+sstr+", "+
                    "#:"+Str(#ROWS*#COLS)
EndProcedure

Procedure.s problem( )
  ProcedureReturn "["+RSet(StrU(Random(#FLD0_MAX, #FLD0_MIN)), #FLD0_WIDTH)+
                    " "+op()+" "+
                    LSet(StrU(Random(#FLD1_MAX, #FLD1_MIN)), #FLD1_WIDTH)+"]"
EndProcedure

#FILE = 0
If CreateFile( #FILE, #FNAME )
  WriteStringN( #FILE, params() )
  WriteStringN( #FILE, "" )
  Define.i row
  For row.i = 1 To #ROWS
    Define.i col
    For col.i = 1 To #COLS
      WriteString( #FILE, problem() )
      If col <> #COLS
        WriteString( #FILE, Space(2) )
      EndIf
    Next
    If row <> #ROWS
      WriteStringN( #FILE, "" )
      WriteStringN( #FILE, "" )
    EndIf
  Next
  CloseFile( #FILE )
EndIf
; IDE Options = PureBasic 5.22 LTS (Windows - x64)
; CursorPosition = 14
; FirstLine = 4
; Folding = -
; EnableUnicode
; EnableXP
; CPU = 1
; EnablePurifier