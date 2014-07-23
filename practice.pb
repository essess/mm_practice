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
#COLS = 6
#ROWS = 50

#FLD0_DIGRNGMIN = 2
#FLD0_DIGRNGMAX = 2
#FLD0_WIDTH     = #FLD0_DIGRNGMAX+1
#FLD0_DIG0 = "05"
#FLD0_DIG1 = "123456789"
#FLD0_DIG2 = "123456789"
#FLD0_DIG3 = "123456789"
#FLD0_DIG4 = "123456789"
#FLD0_DIG5 = "123456789"

#OPS = "+-/*"

#FLD1_DIGRNGMIN = 2
#FLD1_DIGRNGMAX = 3
#FLD1_WIDTH     = #FLD1_DIGRNGMAX+1
#FLD1_DIG0 = "135"
#FLD1_DIG1 = "123456789"
#FLD1_DIG2 = "123456789"
#FLD1_DIG3 = "123456789"
#FLD1_DIG4 = "123456789"
#FLD1_DIG5 = "123456789"

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

Global.i opcnt = Len(#OPS)
Procedure.s op( )
  ProcedureReturn Mid( #OPS, Random(opcnt,1), 1 )
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
                    "ops: "+#OPS+", "+
                    "seed: "+sstr+", "+
                    "#:"+Str(#ROWS*#COLS)
EndProcedure


Procedure.s problem( )
  Protected.i digrng
  Protected.s problem, fld
  
  ; brute force first field
  digrng = Random( #FLD0_DIGRNGMAX, #FLD0_DIGRNGMIN )
  If digrng>5
    fld + Mid( #FLD0_DIG5, Random(Len(#FLD0_DIG5),1), 1 )
  EndIf
  If digrng>4
    fld + Mid( #FLD0_DIG4, Random(Len(#FLD0_DIG4),1), 1 )
  EndIf
  If digrng>3
    fld + Mid( #FLD0_DIG3, Random(Len(#FLD0_DIG3),1), 1 )
  EndIf
  If digrng>2
    fld + Mid( #FLD0_DIG2, Random(Len(#FLD0_DIG2),1), 1 )
  EndIf
  If digrng>1
    fld + Mid( #FLD0_DIG1, Random(Len(#FLD0_DIG1),1), 1 )
  EndIf
  fld + Mid( #FLD0_DIG0, Random(Len(#FLD0_DIG0),1), 1 )
  problem = "["+RSet(fld, #FLD0_WIDTH)
  ; op
  problem + " "+op()+" "
  ; brute force second field
  digrng = Random( #FLD1_DIGRNGMAX, #FLD1_DIGRNGMIN )
  fld = ""
  If digrng>5
    fld + Mid( #FLD1_DIG5, Random(Len(#FLD1_DIG5),1), 1 )
  EndIf
  If digrng>4
    fld + Mid( #FLD1_DIG4, Random(Len(#FLD1_DIG4),1), 1 )
  EndIf
  If digrng>3
    fld + Mid( #FLD1_DIG3, Random(Len(#FLD1_DIG3),1), 1 )
  EndIf
  If digrng>2
    fld + Mid( #FLD1_DIG2, Random(Len(#FLD1_DIG2),1), 1 )
  EndIf
  If digrng>1
    fld + Mid( #FLD1_DIG1, Random(Len(#FLD1_DIG1),1), 1 )
  EndIf
  fld + Mid( #FLD1_DIG0, Random(Len(#FLD1_DIG0),1), 1 )
  problem + LSet(fld, #FLD1_WIDTH)+"]"
  
  ProcedureReturn problem              
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
; CursorPosition = 42
; FirstLine = 32
; Folding = -
; EnableUnicode
; EnableXP
; CPU = 1
; EnablePurifier