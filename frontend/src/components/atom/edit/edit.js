import React,{useState} from 'react';
import { FaPenSquare } from "react-icons/fa";

function Edit(props) {
  const [open, setOpen]=useState(false);
    return(
      <>
      <button onClick={()=>setOpen(!open)} className ="bg-gray-400 w-10 h-5 rounded-lg text-sm items-center mt-1 focus:outline-none" type = "submit" name="login"><FaPenSquare className="m-auto"/></button>
      {open && props.children}
      </>
    )
}

export default Edit