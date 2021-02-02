import React from 'react';
import { FaFolderPlus } from 'react-icons/fa';

function Addfolder(props){
  const [open, setOpen]=React.useState(false);

    return(
    <>
    <button  onClick={()=>setOpen(!open)} className="flex py-2 focus:outline-none"><FaFolderPlus size = {30}/>Folder Baru </button>
    {open && props.children}
    </>
    )
}
export default Addfolder