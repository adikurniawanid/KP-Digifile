import React,{useState} from 'react';
import { FaEdit} from "react-icons/fa";

  
function Rename (props) {
  const [open, setOpen]=useState(false);
    return(
    <div>
        <button onClick={()=>setOpen(!open)} className="-ml-8 mt-10 bg-black text-white rounded-lg p-1 text-border-2 text-border-white"><FaEdit size={12}/></button>
        {open && props.children}
    </div>
    )
}
export default Rename