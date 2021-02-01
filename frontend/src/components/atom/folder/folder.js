import React, {useState} from 'react';
import { FaFolder } from "react-icons/fa";

function Folder(props) {
const [open, setOpen]=useState(false);
  return(
    <>
      <button onAuxClick={()=>setOpen(!open)} id="btn" className="bg-gray-200 w-32 h-10 rounded-lg m-2 focus:outline-none p-2" type = "submit">
        <FaFolder size={20}/>
      </button>
      {open && props.children}
    </>
    )
}
export default Folder