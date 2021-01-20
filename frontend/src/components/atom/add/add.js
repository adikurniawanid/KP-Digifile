import React,{useState} from 'react';
import { FaPlus} from "react-icons/fa";
import Addfolder from '../addfolder/addfolder';
import Folder from '../folder/folder';

  
function Add(props) {
  const [open, setOpen]=useState(false);
    return(
    <div className = "">
      <button onClick={()=>setOpen(!open)} id="btn" className=" flex bg-white rounded-full h-14 w-32 items-center px-2 shadow-md focus:outline-none position-absolute">
        <FaPlus/><p className="mx-2 ">Tambah</p>
      </button>
      {open && props.children}
    </div>
    )
}
export default Add


