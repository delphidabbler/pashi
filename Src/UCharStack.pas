{
 * UCharStack.pas
 *
 * Implements a stack of characters.
 *
 * v1.0 of 28 May 2005  - Original version.
 * v1.1 of 29 May 2009  - Removed all except $WARN compiler directives.
 *
 *
 * ***** BEGIN LICENSE BLOCK *****
 *
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is UCharStack.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2005-2009 Peter
 * Johnson. All Rights Reserved.
 *
 * ***** END LICENSE BLOCK *****
}


unit UCharStack;

{$WARN UNSAFE_TYPE OFF}

interface


uses
  // Delphi
  Contnrs;


type

  {
  TCharStack:
    A stack of characters.
  }
  TCharStack = class(TStack)
  public
    function Peek: Char;
      {Gets character at top of stack.
        @return character at top of stack.
      }
    function Pop: Char;
      {Pops character from stack.
        @return character popped from stack.
      }
    procedure Push(AChar: Char);
      {Pushes character onto stack.
        @param AChar [in] Character to push on stack.
      }
  end;


implementation


{ TCharStack }

function TCharStack.Peek: Char;
  {Gets character at top of stack.
    @return character at top of stack.
  }
begin
  Result := Char(inherited Peek);
end;

function TCharStack.Pop: Char;
  {Pops character from stack.
    @return character popped from stack.
  }
begin
  Result := Char(inherited Pop);
end;

procedure TCharStack.Push(AChar: Char);
  {Pushes character onto stack.
    @param AChar [in] Character to push on stack.
  }
begin
  inherited Push(Pointer(AChar));
end;

end.

