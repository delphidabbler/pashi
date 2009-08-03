{
 * UStrStreamWriter.pas
 *
 * Implements a class that can write strings to a wrapped stream.
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
 * The Original Code is UStrStreamWriter.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2005-2009 Peter
 * Johnson. All Rights Reserved.
 *
 * ***** END LICENSE BLOCK *****
}


unit UStrStreamWriter;

{$WARN UNSAFE_TYPE OFF}

interface


uses
  // DelphiDabbler code library
  PJStreamWrapper;


type
  {
  TStrStreamWriter:
    Class that facilitates writing of formatted and unformatted strings to a
    wrapped stream.
  }
  TStrStreamWriter = class(TPJStreamWrapper)
  public
    procedure WriteStr(const Msg: string); overload;
      {Writes a string to wrapped stream.
        @param Msg [in] String to be written.
      }
    procedure WriteStr(const Fmt: string; const Args: array of const);
      overload;
      {Formats array of arguments as string and writes to wrapped stream.
        @param Fmt [in] Format string.
        @param Args [in] Arguments to be formatted.
      }
    procedure WriteStrLn; overload;
      {Writes newline to wrapped stream.
      }
    procedure WriteStrLn(const Msg: string); overload;
      {Writes a string followed by newline to wrapped string.
        @param Msg [in] String to be written.
      }
    procedure WriteStrLn(const Fmt: string; const Args: array of const);
      overload;
      {Formats array of arguments as string followed by newline and writes to
      wrapped stream.
        @param Fmt [in] Format string.
        @param Args [in] Arguments to be formatted.
      }
  end;


implementation


uses
  // Delphi
  SysUtils;


{ TStrStreamWriter }

procedure TStrStreamWriter.WriteStr(const Msg: string);
  {Writes a string to wrapped stream.
    @param Msg [in] String to be written.
  }
begin
  if (Msg <> '') then
    Self.BaseStream.WriteBuffer(PChar(Msg)^, Length(Msg));
end;

procedure TStrStreamWriter.WriteStr(const Fmt: string;
  const Args: array of const);
  {Formats array of arguments as string and writes to wrapped stream.
    @param Fmt [in] Format string.
    @param Args [in] Arguments to be formatted.
  }
begin
  WriteStr(Format(Fmt, Args));
end;

procedure TStrStreamWriter.WriteStrLn;
  {Writes newline to wrapped stream.
  }
begin
  WriteStr(#13#10);
end;

procedure TStrStreamWriter.WriteStrLn(const Msg: string);
  {Writes a string followed by newline to wrapped string.
    @param Msg [in] String to be written.
  }
begin
  WriteStr(Msg);
  WriteStrLn;
end;

procedure TStrStreamWriter.WriteStrLn(const Fmt: string;
  const Args: array of const);
  {Formats array of arguments as string followed by newline and writes to
  wrapped stream.
    @param Fmt [in] Format string.
    @param Args [in] Arguments to be formatted.
  }
begin
  WriteStr(Fmt, Args);
  WriteStrLn;
end;

end.

