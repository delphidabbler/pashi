{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2012, Peter Johnson (www.delphidabbler.com).
 *
 * $Rev$
 * $Date$
 *
 * Defines the interface to all objects that can render all or parts of output
 * documents.
}


unit Renderers.UTypes;

interface

type
  IRenderer = interface(IInterface)
    ['{899344D1-36EA-4F2A-BC10-66C5F7187552}']
    function Render: string;
  end;


implementation

end.

