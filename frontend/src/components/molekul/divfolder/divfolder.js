import React from 'react';
import { Folder } from '../../atom';
import Folderfix from '../folderfix/folderfix';


function Divfolder(props) {
    return(
      <div>
        <p>Folder</p>
        <div className="flex h-auto">
          
            <Folderfix/>

            <Folderfix/>
          {/* <Folder>
            <ul id="list" className="rounded-lg bg-white border-2 shadow w-44 p-2 space-y-2 ml-20 -mt-16 absolute">
              <li class="dropdown-item">Rename</li>
              <li class="dropdown-item mx-5">Dalate</li>
            </ul>
          </Folder>
          <Folder text = "B"/>
          <Folder text = "B"/>
          <Folder text = "B"/>
          <Folder text = "B"/>
          <Folder text = "B"/>
          <Folder text = "B"/>
          <Folder text = "B"/>
          <Folder text = "B"/> */}
        </div>
     </div>
    )
}

export default Divfolder