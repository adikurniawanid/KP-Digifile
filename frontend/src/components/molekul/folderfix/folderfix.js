import React from 'react';
import { Folder } from '../../atom';


function Folderfix(props) {
    return(
      <div>
        <Folder>
            <ul id="list" className="rounded-lg bg-white border-2 shadow w-36 p-2 space-y-2 ml-20 -mt-16 absolute">
                <li class="dropdown-item"><button className="focus:outline-none">Rename</button></li>
                <li class="dropdown-item"><button className="focus:outline-none">Dalate</button></li>
            </ul>
        </Folder>
     </div>
    )
}

export default Folderfix