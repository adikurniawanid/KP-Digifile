import React from 'react';
import {FaFileUpload} from 'react-icons/fa';

function Uploadfile(props){
  const [open, setOpen]=React.useState(false);

    return(
    <>
    <button  onClick={()=>setOpen(!open)} className="flex py-2 focus:outline-none"><FaFileUpload size = {30}/>Upload File</button>
    {open && props.children}
    </>
    )
}
export default Uploadfile