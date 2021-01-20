import React from 'react';
import { File } from '../../atom';


function Divfile(props) {
    return(
      <div>
        <p>File</p>
        <div className="flex h-auto">
          <File text="File 1"/>
            <File>
              <ul id="list" className="block rounded-lg bg-white border-2 shadow w-36 p-2 space-y-2 ml-20 -mt-16 absolute">
                <li class="dropdown-item"><button className="focus:outline-none">Rename</button></li>
                <li class="dropdown-item"><button className="focus:outline-none">Dalate</button></li>
              </ul>
            </File>
          <File text="File 2"/>
        </div>
     </div>
    )
}

export default Divfile